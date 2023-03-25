FROM alpine:3.17 as downloader

ENV JQ_VERSION jq-1.6/jq-linux64
LABEL Author="wid.sh"

RUN apk add --no-cache curl ca-certificates

RUN curl -sSfL -o /jq "https://github.com/stedolan/jq/releases/download/${JQ_VERSION}" \
    && chmod +x /jq

FROM scratch
ENV PATH=/
COPY --from=downloader /jq /jq
ENTRYPOINT [ "/jq" ]
