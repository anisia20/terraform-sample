# terraform-sample

- need vpc and subnet

``` sh
docker-compose run --rm tf workspace new helloterrra
docker-compose run --rm tf workspace list
docker-compose run --rm tf init ec2_sample/only_ec2
docker-compose run --rm tf apply -var "region=ap-northeast-2" -var "access_key=KEY" -var "secret_key=KEY" ec2_sample/only_ec2
```

## EKS
1. create keypair ex) eks-bastion.pem
```sh
docker-compose run --rm tf workspace new eks
docker-compose run --rm tf workspace list
docker-compose run --rm tf -chdir=eks init
docker-compose run --rm tf -chdir=eks plan -var "region=ap-northeast-2" -var "access_key=KEY" -var "secret_key=KEY"
docker-compose run --rm tf -chdir=eks apply -var "region=ap-northeast-2" -var "access_key=KEY" -var "secret_key=KEY"
```
2. bastion 접속
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
aws eks update-kubeconfig --region ap-northeast-2 --name eks
```
