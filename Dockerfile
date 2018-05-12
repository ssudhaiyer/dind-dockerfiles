FROM docker:latest
RUN apk update && apk add --no-cache bash git openssh
RUN apk add 
ADD build.sh /tmp/build.sh
