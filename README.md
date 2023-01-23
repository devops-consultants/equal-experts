# Hello World

This application is a simple load-balanced web service demonstrating the deployment of a GoLang application on a kubernetes cluster. It is intended to run on your local machine using the `minikube` tool to launch and manage a minimal kubernetes environment.

---

## Requirements

It is expected that the user will have already installed and working a minikube environment. If you do not have minikube installed, see the instructions [on the minikube website](https://minikube.sigs.k8s.io/docs/start/).

### Start the cluster

From a terminal, run:

```shell
$ minikube start
```

### Kubernetes CLI

If you do not already have the `kubectl` tool installed, you may wish to install it, or alternatively you can setup the following alias and leverage the minikube executable:

```shell
$ alias kubectl="minikube kubectl --"
```

### Checking the cluster is running

Once minikube has finished initialising and downloading the virtualisation images for your configuration, you should be able to run the following command to confirm the cluster is ready for the `helloworld` application to be deployed.

From a terminal, run:

```shell
$ kubectl get pod -A
NAMESPACE              NAME                                        READY   STATUS      RESTARTS        AGE
kube-system            coredns-565d847f94-wmpmf                    1/1     Running     0               29m
kube-system            etcd-minikube                               1/1     Running     0               30m
kube-system            kube-apiserver-minikube                     1/1     Running     0               30m
kube-system            kube-controller-manager-minikube            1/1     Running     0               30m
kube-system            kube-proxy-plwtn                            1/1     Running     0               29m
kube-system            kube-scheduler-minikube                     1/1     Running     0               30m
kube-system            storage-provisioner                         1/1     Running     0               29m
```

---

## Deploying the Hello World web service

First, in a separate terminal window, you will need to run the following command to expose the kubernetes cluster run by minikube to your local machine:

```shell
$ minikube tunnel
✅  Tunnel successfully started

📌  NOTE: Please do not close this terminal as this process must stay alive for the tunnel to be accessible ...
```

From a second terminal, you can now choose from either an automated deployment, or to follow the steps manually.

For an automated deployment, a `Makefile` has been provided, allowing you to just run:

```shell
$ make
```

If you wish to deploy each stage manually, follow these steps:

1. First, to build the image of the golang-based webservice and make the image available to the kubernetes cluster, run the following commands:

```shell
$ eval $(minikube docker-env)
$ docker build -t helloworld:dev .
```

The first command sets up environment variables in your shell to tell the `docker` command how to connect to the minikube environment. The second command then creates the `helloworld` image in the environment.

2. Having built the image, we now use kubernetes manifests to define a deployment and a service on the kubernetes cluster. The deployment will launch 3 replicas of the `helloworld` image, while the service will provide load-balancing over the replicas. From the terminal, run:

```shell
$ kubectl apply -f manifests/
```

The `helloworld` service is deployed as a Load-Balancer service, requiring the `minikube tunnel` command to already be running in a separate terminal.

3. Lastly, we query the deployed `helloworld` service to determine the IP Address we can use to connect to it. From the terminal, run:

```shell
$ kubectl get svc
```

---

## Accessing the Hello World service

Whether using the `Makefile` to automate the deployment, or following the steps manually, the last command should output details of the deployed service similar to this:

```
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
helloworld   LoadBalancer   10.100.183.40   127.0.0.1     8080:30511/TCP   15m
```

If the `EXTERNAL-IP` is showing as `pending` then check that the `minikube tunnel` command is running and not displaying any errors.

Depending on how your minikube environment is deployed, you may have a different external ip address in your output to the example shown above.

You can now use either a web browser, or a command-line tool such as `curl` to make a connection to the web service by using the url:

```
http://<external-ip>:8080/world
```

From the example above, running the following in a terminal will output:

```shell
$ curl http://127.0.0.1:8080/world
Hello, world!

Served by: helloworld-6cf7c4896f-8tsvt
```

The last line of the output shows the name of the replica pod that served the request. Repeating the command multiple times should show different pod names as the load-balancer service distributes the requests across all the replicas.
