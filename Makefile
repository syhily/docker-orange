IMAGE_NAME = syhily/orange

build:
	docker build -t $(IMAGE_NAME) .

release:
	docker push $(IMAGE_NAME)

run:
	docker-compose run --service-ports --rm orange
debug-run:
	docker-compose run --service-ports --rm orange bash
