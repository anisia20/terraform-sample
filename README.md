# terraform-sample

- need vpc and subnet

``` sh
docker-compose run --rm tf workspace new helloterrra
docker-compose run --rm tf workspace list
docker-compose run --rm tf init ec2_sample/only_ec2
docker-compose run --rm tf apply -var "region=ap-northeast-2" -var "access_key=KEY" -var "secret_key=KEY" ec2_sample/only_ec2
```

## EKS
1. keypair setting
2. create keypair ex) eks-bastion.pem
```sh
docker-compose run --rm tf workspace new eks
docker-compose run --rm tf workspace list
docker-compose run --rm tf -chdir=eks init
docker-compose run --rm tf -chdir=eks plan -var "region=ap-northeast-2" -var "access_key=KEY" -var "secret_key=KEY"
docker-compose run --rm tf -chdir=eks apply -var "region=ap-northeast-2" -var "access_key=KEY" -var "secret_key=KEY"
```
3. bastion 접속
| aws cli 인증키 발급 적용 후 진행
```sh
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.3/2023-11-14/bin/linux/amd64/kubectl
chmod +x ./kubectl
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
kubectl version --client
sudo pip uninstall awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
## 재 접속 진행
aws eks update-kubeconfig --region ap-northeast-2 --name themore-cluster
```

4. istio 세팅
https://devocean.sk.com/blog/techBoardDetail.do?ID=163655
```sh
curl -sL https://istio.io/downloadIstioctl | sh -
cp ~/.istioctl/bin/istioctl ~/bin
istioctl install -f istio-operator.yaml
kubectl get pods -n istio-system
kubectl label namespace default istio-injection=enabled
```

```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: istiocontrolplane
spec:
  profile: default
  components:
    egressGateways:
    - name: istio-egressgateway
      enabled: true
      k8s:
        hpaSpec:
          minReplicas: 2
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        hpaSpec:
          minReplicas: 2
    pilot:
      enabled: true
      k8s:
        hpaSpec:
          minReplicas: 2
  meshConfig:
    enableTracing: true
    defaultConfig:
      holdApplicationUntilProxyStarts: true
    accessLogFile: /dev/stdout
    outboundTrafficPolicy:
      mode: REGISTRY_ONLY
```

5. AWS Load Balancer Controller 세팅
| WAF등의 AWS 서비스를 이용하기 위함

```sh
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

eksctl create iamserviceaccount \
  --cluster=themore-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::776525613317:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
echo 'source <(helm completion bash)' >> ~/.bashrc
source <(helm completion bash)
chmod 600 ~/.kube/config
helm repo add eks https://aws.github.io/eks-charts
helm repo update


helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=themore-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set image.repository=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller
```

6. istio 설정 변경
```sh
kubectl get service istio-ingressgateway -n istio-system -o jsonpath='{.spec.ports[?(@.name=="status-port")].nodePort}'
## 포트 확인 30566 yaml 변경
istioctl install -f istio-operator.yaml
```

```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: istiocontrolplane
spec:
  profile: default
  components:
    egressGateways:
    - name: istio-egressgateway
      enabled: true
      k8s:
        hpaSpec:
          minReplicas: 2
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        hpaSpec:
          minReplicas: 2
        service:
          type: NodePort # ingress gateway 의 NodePort 사용
        serviceAnnotations:  # Health check 관련 정보
          alb.ingress.kubernetes.io/healthcheck-path: /healthz/ready
          alb.ingress.kubernetes.io/healthcheck-port: "30566" # 위에서 얻은 port number를 사용
    pilot:
      enabled: true
      k8s:
        hpaSpec:
          minReplicas: 2
  meshConfig:
    enableTracing: true
    defaultConfig:
      holdApplicationUntilProxyStarts: true
    accessLogFile: /dev/stdout
    outboundTrafficPolicy:
      mode: REGISTRY_ONLY
```

7. ALB생성
```sh

```

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-alb
  namespace: istio-system
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:ap-northeast-2:131231231~~~~"
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
spec:
  rules:
  - http:
      paths:
        - path: /*
          backend:
            serviceName: ssl-redirect
            servicePort: use-annotation
        - path: /*
          backend:
            serviceName: istio-ingressgateway
            servicePort: 80
```
