all: deploy

image: helloworld.go
	eval $$(minikube docker-env)
	docker build -t helloworld:dev .

deploy: image
	kubectl apply -f manifests/
	kubectl get svc

tunnel:
	minikube tunnel