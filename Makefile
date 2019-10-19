AUTHOR=flee999
IMAGE_NAME=ntpd-alpine
TAG=${AUTHOR}/${IMAGE_NAME}:latest

# name of container, extra capabilities, on exit remove
NAME= --name ${IMAGE_NAME}
CAPS= --cap-add SYS_TIME --cap-add SYS_NICE
EXITFLAG= --rm

VOL_FLAG= -v $(shell pwd)/assets/ntpd.conf:/etc/ntpd.conf:ro

# port exposed to outside world
EXPOSED_PORT=1123
PORTMAP = -p ${EXPOSED_PORT}:123

default: run

# remove any stopped older image. if none exists, continues normally
# docker compose will leave exited container because it does not have --rm option
rmexited:
	docker rm $(shell docker ps --filter "status=exited" --filter="name=${IMAGE_NAME}" -q) || true

#  build and run using docker and Dockerfile
build:
	docker build -f Dockerfile --tag=${TAG} .
run: build
	docker run ${CAPS} ${PORTMAP} ${NAME} ${EXITFLAG} ${VOL_FLAG} -d ${TAG}
runfg: build rmexited
	docker run ${CAPS} ${PORTMAP} ${NAME} ${EXITFLAG} ${VOL_FLAG} -it ${TAG}


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

test:
	./ntpdate_test.sh ${IMAGE_NAME} ${EXPOSED_PORT}
