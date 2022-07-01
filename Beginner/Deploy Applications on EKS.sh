#1. DEPLOY NODEJS BACKEND API
    #After Cloning Git Repos in the Pre-Req File
    cd ~/environment/ecsdemo-nodejs
    kubectl apply -f kubernetes/deployment.yaml
    kubectl apply -f kubernetes/service.yaml

    kubectl get deployment ecsdemo-nodejs

#2. DEPLOY CRYSTAL BACKEND API

    cd ~/environment/ecsdemo-crystal
    kubectl apply -f kubernetes/deployment.yaml
    kubectl apply -f kubernetes/service.yaml

    kubectl get deployment ecsdemo-crystal

#3. DEPLOY FRONTEND SERVICE

    cd ~/environment/ecsdemo-frontend
    kubectl apply -f kubernetes/deployment.yaml
    kubectl apply -f kubernetes/service.yaml

    kubectl get deployment ecsdemo-frontend

#4. By Now ALB would be deployed. Go to the console to check the elb & load it in browser or the below alternative should also be fine.

    ELB=$(kubectl get service ecsdemo-frontend -o json | jq -r '.status.loadBalancer.ingress[].hostname')
    curl -m3 -v $ELB

#5. Scale the Deployments

    kubectl scale deployment ecsdemo-nodejs --replicas=3
    kubectl scale deployment ecsdemo-crystal --replicas=3
    kubectl get deployments
    kubectl scale deployment ecsdemo-frontend --replicas=3
    kubectl get deployments
