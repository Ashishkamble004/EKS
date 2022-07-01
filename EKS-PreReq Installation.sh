##Install Pre-Req:

#1. Install Kubectl:

	sudo curl --silent --location -o /usr/local/bin/kubectl \
	   https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl

	sudo chmod +x /usr/local/bin/kubectl

#2. Update AWS CLI:

	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install

#3. Install jq, envsubst (from GNU gettext utilities) and bash-completion

	sudo yum -y install jq gettext bash-completion moreutils

#4. Install yq for yaml processing

    echo 'yq() {
    docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
    }' | tee -a ~/.bashrc && source ~/.bashrc

#5. Verify the binaries are in the path and executable

    for command in kubectl jq envsubst aws
    do
        which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
    done

#6. Enable kubectl bash_completion

    kubectl completion bash >>  ~/.bash_completion
    . /etc/profile.d/bash_completion.sh
    . ~/.bash_completion

#7. set the AWS Load Balancer Controller version

    echo 'export LBC_VERSION="v2.4.1"' >>  ~/.bash_profile
    echo 'export LBC_CHART_VERSION="1.4.1"' >>  ~/.bash_profile
    .  ~/.bash_profile

#8. Removing AWS Managed Credentials
    
    aws cloud9 update-environment  --environment-id $C9_PID --managed-credentials-action DISABLE
    rm -vf ${HOME}/.aws/credentials

#9. Exporting ACCOUNT_ID, REGION, AZ's as variables

    export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
    export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
    export AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region $AWS_REGION))

    echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
    echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
    echo "export AZS=(${AZS[@]})" | tee -a ~/.bash_profile
    aws configure set default.region ${AWS_REGION}
    aws configure get default.region

#10. Validate IAM Role

     aws sts get-caller-identity --query Arn | grep eksworkshop-admin -q && echo "IAM role valid" || echo "IAM role NOT valid"

#11. Cloning Service Repos

    cd ~/environment
    git clone https://github.com/aws-containers/ecsdemo-frontend.git
    git clone https://github.com/aws-containers/ecsdemo-nodejs.git
    git clone https://github.com/aws-containers/ecsdemo-crystal.git

#12. Install EKSCTL

    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv -v /tmp/eksctl /usr/local/bin

#13. EKSCTL Bash Completion

    eksctl completion bash >> ~/.bash_completion
    . /etc/profile.d/bash_completion.sh
    . ~/.bash_completion

#14. Setup Connection with EKS Cluster

    aws eks update-kubeconfig --name eksworkshop-eksctl --region ap-southeast-1

#15. Export Worker Role Name

    STACK_NAME=$(eksctl get nodegroup --cluster eksworkshop-eksctl -o json | jq -r '.[].StackName')
    ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
    echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile
