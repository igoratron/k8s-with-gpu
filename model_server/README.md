# Model

This repository contains the Flask app which exposes some sample pytorch functionality. I'd expect most of the development to occur in this folder, or a sibling if we wanted to have multiple services.

Even though this app uses Flask and Gunicorn, the actual choice of technologies does not matter that much in context of this PoC. The `Dockerfile` defines how the application is built and how it is executed, and the `k8s` folder contains kuberenets configuration for the deployment, service and ingress.

I chose [`skaffold`](https://skaffold.dev/) to manage the local dev experience as well as the build and deployment of the app so that I didn't have to write boilerplate docker build and kubectl pipeline. Although I haven't tested it because I developed everything against a live K8s cluster, it should be possible to run this app (or apps) with a local instance of `minikube` and `skaffold dev`.
