FROM alpine:3.17

LABEL Author="wid.sh"

# make sure the package repository is up to date
RUN apk update \
 && apk upgrade \
 && apk add bash \
 && apk add jq \
 && rm -rf /var/cache/*/* \
 && echo "" > /root/.ash_history

# change default shell from ash to bash
RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

ENV LC_ALL=en_US.UTF-8

WORKDIR /root