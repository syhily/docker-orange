# Orange in Docker

[![](https://images.microbadger.com/badges/image/syhily/orange.svg)](https://microbadger.com/images/syhily/orange "Get your own image badge on microbadger.com") ![](https://img.shields.io/docker/pulls/syhily/orange.svg) ![](https://img.shields.io/docker/stars/syhily/orange.svg) ![](https://img.shields.io/badge/license-MIT-blue.svg)

This is an unofficial Docker image for Orange distribution.

## What is Orange?

API Gateway based on OpenResty.

## How to use this image

First, orange requires a running mysql cluster before it starts. You can either use the official MySQL containers, or use your own.

### Using docker-compose (Recommend)

* start a Orange container + its dependencies (mysql)

```console
$ docker-compose run --service-ports --rm orange
# or
$ make run
```

---

Run in debug mode (bash) :

```console
$ make debug-run
```

#### Common used commands

1. `docker-compose up` Bootstrap a brand new alert service container. if a old container exists, docker compose would reuse it in case of losing data.
2. `docker-compose down` Destroy all the containers defined in this compose file.
3. `docker-compose start` Start the existed containers.
4. `docker-compose stop` Stop the existed containers.
5. `docker-compose restart` Restart the existed containers, the new configuration would be applied immediately.
6. `docker-compose run -d --service-ports --rm orange` Almost the same with `docker-compose up`.

### Start orange step by step

- Run a MySQL container

```bash
docker run --name orange-database -e MYSQL_ROOT_PASSWORD=your_root_pwd -e MYSQL_DATABASE=orange -p 3306:3306 mysql:5.7
```

This is the only way to get a runing mysql instance for orange.

- Runing a orange instance and initialize database scheme.

Modify the `{block}` content, and execute it.

`ORANGE_INIT_DB` variable would be deployment friendly on production.

```bash
docker run -d --name orange \
    --link orange-database:orange-database \
    -p 7777:7777 \
    -p 8888:80 \
    -p 9999:9999 \
    --security-opt seccomp:unconfined \
    -e ORANGE_DATABASE={your_database_name} \
    -e ORANGE_HOST=orange-database \
    -e ORANGE_PORT={your_database_port} \
    -e ORANGE_USER={your_database_user} \
    -e ORANGE_PWD={your_database_password} \
    syhily/orange
```

Access orange [dashboard](http://127.0.0.1:9999) (Default Username: admin, Default Password: orange_admin)

### Relative Link's

1. [Orange Dashboard](http://127.0.0.1:9999)
2. [Orange API Endpoint](http://127.0.0.1:7777)
3. [Orange Gateway Access Endpoint](http://127.0.0.1:8888)

### Operation Your Orange

```bash
docker exec -it orange orange COMMAND [OPTIONS]

The commands are:

start   Start the Orange Gateway
stop    Stop current Orange
reload  Reload the config of Orange
restart Restart Orange
version Show the version of Orange
help    Show help tips
```

## User Feedback

### Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/syhily/docker-orange/issues).

### Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/syhily/docker-orange/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
