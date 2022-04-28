# AIO Container Login


## 1.1. Command

```sh
sudo docker exec -it allinone-cluster /bin/sh
```

## 1.2. Check the Service

Then, paste the commands below into you terminal to see if all the services are running.

``` sh
ps -e | grep arbitrator-svc
ps -e | grep eshing-svc
ps -e | grep generic-hashing-svc
ps -e | grep tpp-svc
ps -e | grep scheduling-svc
ps -e | grep exec-svc
ps -e | grep core-svc
ps -e | grep consensus-svc
ps -e | grep storage-svc
ps -e | grep gateway-svc
ps -e | grep frontend-svc
ps -e | grep pool-svc
ps -e | grep eth-api-svc
```

You should be able to see a list of Arcology services running in the testnet container

![alt text](./img/allinone-testnet-docker-svclist.png)

## 2. Reinstall

If you don't see all of them, the  image itself may be damaged. Please redownload the docker image.