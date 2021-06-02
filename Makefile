AUTHOR=flee999
IMAGE_NAME=ntpd-alpine
TAG=${AUTHOR}/${IMAGE_NAME}:latest

# name of container, extra capabilities, on exit remove
NAME= --name ${IMAGE_NAME}
CAPS= --cap-add SYS_TIME --cap-add SYS_NICE
# not necessary --cap-add CAP_SYS_RESOURCE
EXITFLAG= --rm

VOL_FLAG= -v $(shell pwd)/assets/ntpd.conf:/etc/ntpd.conf:ro

# port exposed to outside world
EXPOSED_PORT=123
PORTMAP = -p ${EXPOSED_PORT}:123

# add user to docker group: sudo usermod -aG docker $USER

default: run
build:
	docker build -f Dockerfile --tag=${TAG} .

run-bg: build
	docker run ${CAPS} ${PORTMAP} ${NAME} ${EXITFLAG} ${VOL_FLAG} -d ${TAG}
run-fg: build rm-any-exited
	docker run ${CAPS} ${PORTMAP} ${NAME} ${EXITFLAG} ${VOL_FLAG} -it ${TAG}

## get into console of container running in background
docker-cli-bg:
	docker exec -it ${IMAGE_NAME} /bin/sh

# remove any stopped older image. if none exists, continues normally
# docker compose will leave exited container because it does not have --rm option
rm-any-exited:
	docker rm $(shell docker ps --filter "status=exited" --filter="name=${IMAGE_NAME}" -q) || true

docker-logs:
	docker logs -f ${IMAGE_NAME}

docker-stop:
	docker stop ${IMAGE_NAME}

# build and run using docker-compose and docker-compose.yml
build-compose:
	EXPOSED_PORT=${EXPOSED_PORT} \
        docker-compose --verbose -f docker-compose.yml build
run-compose: build-compose
	EXPOSED_PORT=${EXPOSED_PORT} \
        docker-compose -f docker-compose.yml up -d
runfg-compose: build-compose
	EXPOSED_PORT=${EXPOSED_PORT} \
        docker-compose -f docker-compose.yml up

test-client:
	./ntpdate_test.sh ${IMAGE_NAME} ${EXPOSED_PORT}
