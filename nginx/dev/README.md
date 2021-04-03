# Push image to aws ecr

```
$ docker build -t nginx-tls .
$ docker images ls
```

Test the image locally
```
$ docker container run -d -p 8001:443 --name mynginx1 nginx-tls
$ curl https://127.0.0.1:8001 --insecure
$ docker container stop mynginx1
$ docker container rm mynginx1
```


