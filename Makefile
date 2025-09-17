# Include .env file if it exists
-include .env

# Docker image - read from .env
IMAGE ?= $(error IMAGE not set. Please create .env file with IMAGE=registry/image-name)
TAG ?= latest

# Build the Docker image
.PHONY: build
build:
	docker build -f Dockerfile.daemon -t $(IMAGE):$(TAG) .

# Push the Docker image to the registry
.PHONY: push
push:
	docker push $(IMAGE):$(TAG)

# Build and push in one command
.PHONY: deploy
deploy: build push

# Build with no cache
.PHONY: build-nocache
build-nocache:
	docker build --no-cache -f Dockerfile.daemon -t $(IMAGE):$(TAG) .

# Tag the image with both latest and a specific version
.PHONY: tag-version
tag-version:
	@if [ -z "$(VERSION)" ]; then echo "VERSION not set. Usage: make tag-version VERSION=1.0.0"; exit 1; fi
	docker tag $(IMAGE):$(TAG) $(IMAGE):$(VERSION)
	docker push $(IMAGE):$(VERSION)

# Show current image tags
.PHONY: info
info:
	@echo "Image: $(IMAGE)"
	@echo "Tag: $(TAG)"
	@echo "Full image name: $(IMAGE):$(TAG)"