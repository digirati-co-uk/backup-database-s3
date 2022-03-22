FROM alpine:3.15

RUN apk add --update --no-cache --virtual=run-deps \
  python3 \
  py3-pip \
  docker \
  curl \
  ca-certificates \
  && rm -rf /var/cache/apk/*

ENV DATE_FORMAT +%Y%m%d%H%M
ENV ANNOUNCE_SUCCESS=True

RUN pip3 install --no-cache-dir awscli

CMD [ "./backup.sh" ]

COPY backup.sh .
RUN chmod +x backup.sh
