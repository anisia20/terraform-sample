# terraform-sample

- need vpc and subnet

``` sh
docker-compose run --rm tf workspace new helloterrra
docker-compose run --rm tf workspace list
docker-compose run --rm tf init ec2_sample/only_ec2
docker-compose run --rm tf apply -var "region=ap-northeast-2" -var "access_key=KEY" -var "secret_key=KEY" ec2_sample/only_ec2
```

