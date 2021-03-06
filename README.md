# Pre-requisites

## AWS user

Create an IAM user granted policy AdministratorAccess.

Under "Security credentials" tab, under "Access keys" section, click Create access key and save the file for later.

Under "Security credentials" tab, under "HTTPS Git credentials for AWS CodeCommit" section, click "Generate credentials" and save the file for later.

## curl

cURL is a command-line tool for getting or sending data including files using URL syntax

```
sudo apt install curl
```

## aws cli version 2

Get the aws cli version by running
```
aws --version
```

If version is 1 (aws-cli/1.x.xx) follow [Installing, updating, and uninstalling the AWS CLI v1](https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-install.html)

On linux/ubuntu commands would be similar to
```
pip3 uninstall awscli
sudo rm -rf /usr/local/aws
sudo rm /usr/local/bin/aws
```

If version is below aws-cli/2.4.x or package is not installed, follow [Installing or updating the latest version of the AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update

```
or
```
python3 -m pip install awscli --upgrade
```
or if the install was a bundle [install linux bundled uninstall](https://docs.aws.amazon.com/cli/v1/userguide/install-linux.html#install-linux-bundled-uninstall)


Then follow [Configuration basics for CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) using values from "new_user_credentials.csv" previously generated in AWS console.
```
aws configure
```

## CodeCommit git

Use file "<user>_codecommit_credentials.csv" previously generated in AWS console.

```
sudo apt-get install git
git config --global user.name <User Name>
git config --global user.email <email>
git config --global user.password <Password>
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.usehttppath true
```

Reference to setup git
[7.14 Git Tools - Credential Storage](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)
[8.1 Customizing Git - Git Configuration](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)
[Troubleshooting Git credentials and HTTPS connections to AWS CodeCommit](https://docs.aws.amazon.com/codecommit/latest/userguide/troubleshooting-gc.html)


## GitHub CLI

```
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

Autenticate

```
gh auth login
```

## jq

jq is a lightweight and flexible command-line JSON processor

Install by running
```
sudo apt install -y jq
```
or follow [Download jq](https://stedolan.github.io/jq/download/)


## eksctl

https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
https://eksctl.io/introduction/#installation
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

export KUBECONFIG=$KUBECONFIG:~/.kube/eksctl/clusters/lafleet-cluster
export EKSCTL_ENABLE_CREDENTIAL_CACHE=1
```

https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

## kubectl

https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
```
curl -LO https://dl.k8s.io/release/v1.21.8/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
kubectl version --short --client
```

## Helm

https://helm.sh/docs/intro/install/
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
or
```
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```


# TODO

## Not scripted yet

Remaining: 
- Alternate domain name on CloudFront with R53
- Helm charts


## Known issues

1. delete-thing break command exists the shell (program stops)
2. Image redis-performance-analytics-py:latest to be renamed redis-performance-analytics-py:latest


# How To Deploy


## First step: Download scripts locally (1 minute)

Create a folder for the project and go inside
```
mkdir LaFleet && cd LaFleet
```

Clone the repository which contains all the scripts
```
git clone https://github.com/Ducharme/infraAsCodeShell
```

Copy/paste file .env.example and rename it to .env.production then replace the mapbox token by yours. You need to create an account on mapbox then go to https://account.mapbox.com/access-tokens/ to get your default public token.


## Second step: Deploy core infrastructure (10 minutes)

Run below script (tested with Lubuntu 20.04 default terminal)

```
sh ./main_create.sh
```
NB: Flags are used in this file to retry particular parts in case of error.

Once completed you should see the map with CloudFront.
[LaFleet PoC - Core](images/LaFleet-core.png?raw=true)


## Third step: Deploy Kubernetes cluster (21 minutes)

Use eksctl by running below script to get an EKS cluster
```
sh ./main_create_k8s.sh
```

Approximate timings:
1. eksctl-lafleet-cluster-cluster (15 minutes)
2. eksctl-lafleet-cluster-addon-iamserviceaccount-default-lafleet-eks-sa-sqsconsumer (2 minutes)
3. eksctl-lafleet-cluster-addon-iamserviceaccount-kube-system-aws-node (2 minutes in // with 2.)
4. eksctl-lafleet-cluster-nodegroup-ng-standard-x64 (4 minutes)
5. eksctl-lafleet-cluster-nodegroup-ng-compute-x64 (4 minutes in // with 4.)


## Fourth step: Deploy pods on EKS cluster (2 minutes)

Run below script
```
sh ./main_create_k8s_apps.sh
```

When ready, launch mock decices with
```
kubectl apply -f ./eks/devices-extreme_job.yml
```
For 2 minutes 30 seconds there will be 20 devices updating value at 10 ms interval.


# Resources created by the scripts


IoT Core (Thing, Security/Policy, Rules)
SQS (1x)
S3 buckets (4x)
CloudFront Distribution & OAI
CloudWatch Log Groups
IAM/roles (13x)
IAM/policies (13x)
CodeCommit (5x)
CodeBuild (5x)
CodePipeline (5x)
ECR (4x)
EC2/Instances
EC2/LoadBalancer
EC2/Auto Scaling Groups
VPC/NAT gateways
EKS
Lambda/Functions
Lambda/Layers

See [RESOURCES](RESOURCES.md) (work in progress)


# Playing with Kubernetes

## Setup the environment once eksctl is deployed

```
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc
```

Run this everytime a new terminal session is opened
```
export EKSCTL_ENABLE_CREDENTIAL_CACHE=1
export KUBECONFIG=~/.kube/eksctl/clusters/lafleet-cluster
```

To retrieve the config from another computer and save it locally
```
eksctl utils write-kubeconfig --cluster=lafleet-cluster --kubeconfig=/home/$USER/.kube/eksctl/clusters/lafleet-cluster
```

## Creating a pod with curl on the cluster

```
NODESELECTOR='{ "apiVersion": "v1", "spec": { "template": { "spec": { "nodeSelector": { "nodegroup-type": "backend-standard" } } } } }'
kubectl run curl --image=radial/busyboxplus:curl -i --rm --tty --overrides="$NODESELECTOR"
```

### To query analytics

Note: Add arguments --raw --show-error --verbose for more details

### For analytics service

Port 5973 exposed to 80
```
curl -s -X GET -H "Content-Type: text/html" http://analytics-service/
curl -s -X GET -H "Content-Type: text/html" http://analytics-service/health
curl -s -X POST -H "Content-Type: application/json" http://analytics-service/devices/data
curl -s -X POST -H "Content-Type: application/json" http://analytics-service/devices/stats
curl -s -X POST -H "Content-Type: text/html" http://analytics-service/devices/stats
curl -s -X DELETE -H "Content-Type: application/json" http://analytics-service/devices
```

#### For redisearch service

Note: External service domain is https://<cloudfront-distribution-domaine-name> which looks like d12acbc34def5g0.cloudfront.net (not to be confused with CloudFront Distribution ID with capital alpha-numeric)

```
curl -s --raw --show-error --verbose -L -X GET http://query-service
curl -s --raw --show-error --verbose -L -X GET http://query-service/health
curl -s --raw --show-error --verbose -L -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"h3resolution":"0","h3indices":["802bfffffffffff","8023fffffffffff"]}' http://query-service/h3/aggregate/device-count
curl -s --raw --show-error --verbose -L -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"longitude":-73.5, "latitude": 45.5, "distance": 200, "distanceUnit": "km"}' http://query-service/location/search/radius/device-list
curl -s --raw --show-error --verbose -L -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"h3resolution":"0","h3indices":["802bfffffffffff","8023fffffffffff"]}' https://d12acbc34def5g0.cloudfront.net/query/h3/aggregate/device-count
```


## Creating a pod with redis on the cluster

Note: Use <Shift>+R to get the prompt to show with redis client otherwise the terminal might not display it
Note: Add arguments --raw --show-error --verbose for more details

```
NODESELECTOR='{ "apiVersion": "v1", "spec": { "template": { "spec": { "nodeSelector": { "nodegroup-type": "backend-standard" } } } } }'
kubectl run redis-cli3 --image=redis:latest --attach --leave-stdin-open --rm -it  --labels="app=redis-cli,project=lafleet" --overrides="$NODESELECTOR" -- redis-cli -h redisearch-service
```

Common commands
```
$ KEYS *
$ FLUSHALL
$ HGETALL DEVLOC:test-123456:topic_1
$ XRANGE STREAMDEV:test-123456:topic_1 - +
```

Using INDEX
```
FT.AGGREGATE topic-h3-idx "@topic:topic_1 @h3r0:{802bfffffffffff | 802bffffffffffw }" GROUPBY 1 @h3r0 REDUCE COUNT 0 AS num_devices
FT.SEARCH topic-lnglat-idx "@topic:topic_1 @lnglat:[-73 45 100 km]" NOCONTENT
```

## To play locally with redisearch

Creating the two INDEX
```
sudo docker run --name redisearch-cli --rm -it -d -p 6379:6379 redislabs/redisearch:latest

INDEX_H3="FT.CREATE topic-h3-idx ON HASH PREFIX 1 DEVLOC: SCHEMA topic TEXT h3r0 TAG h3r1 TAG h3r2 TAG h3r3 TAG h3r4 TAG h3r5 TAG h3r6 TAG h3r7 TAG h3r8 TAG h3r9 TAG h3r10 TAG h3r11 TAG h3r12 TAG h3r13 TAG h3r14 TAG h3r15 TAG dts NUMERIC batt NUMERIC fv TEXT"
INDEX_LOC="FT.CREATE topic-loc-idx ON HASH PREFIX 1 DEVLOC: SCHEMA topic TEXT loc GEO dts NUMERIC batt NUMERIC fv TEXT"

echo "$INDEX_H3" | redis-cli 
echo "$INDEX_LOC" | redis-cli

FT._LIST
```


# License

LaFleet PoC is available under the [MIT license](LICENSE). LaFleet PoC also includes external libraries that are available under a variety of licenses, see [THIRD_PARTY_LICENSES](THIRD_PARTY_LICENSES) for the list.
