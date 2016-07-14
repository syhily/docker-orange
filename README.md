# Orange in Docker

![](https://img.shields.io/docker/pulls/syhily/orange.svg) ![](https://img.shields.io/docker/stars/syhily/orange.svg) ![](https://img.shields.io/badge/license-MIT-blue.svg)

This is an unofficial Docker image for Orange distribution.

## What is Orange?

API Gateway based on OpenResty.

## How to use this image

First, orange requires a running mysql cluster before it starts. You can either use the official MySQL containers, or use your own.

### Link Orange To A MySQL Container

- Run a MySQL container

```bash
docker run --name orange-database -e MYSQL_ROOT_PASSWORD=your_root_pwd -p 3306:3306 mysql:5.7
```

- Create orange user and grant privileges

```sql
CREATE DATABASE orange;

CREATE USER 'orange'@'%' IDENTIFIED BY 'orange';

GRANT ALL PRIVILEGES ON orange.* TO 'orange'@'%';
```

- Import the initial data from a database [dump](https://github.com/sumory/orange/blob/master/install/orange-v0.2.0.sql).

- Link orange to this MySQL container

```bash
docker run -d --name orange \
    --link orange-database:orange-database \
    -p 7777:7777 \
    -p 8888:8888 \
    -p 9999:9999 \
    --security-opt seccomp:unconfined \
    syhily/orange
```

Access orange [dashboard](http://127.0.0.1:9999) (Default Username: admin, Default Password: orange_admin)

### Relative Link's

1. [Orange Dashboard](http://127.0.0.1:9999)
2. [Orange API Endpoint](http://127.0.0.1:7777)
3. [Orange Gateway Access Endpoint](http://127.0.0.1:8888)

### Reload Your Orange

```bash
docker exec -it orange orange reload
```

## User Feedback

### Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/syhily/docker-orange/issues).

### Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/syhily/docker-orange/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
