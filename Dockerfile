FROM alpine

RUN apk add --update --no-cache --virtual=run-deps \
  python3 \
  docker \
  curl \
  ca-certificates \
  && rm -rf /var/cache/apk/*

ENV DATE_FORMAT +%Y%m%d%H%M

RUN pip3 install --no-cache-dir awscli

CMD [ "backup.sh" ]

COPY backup.sh .
