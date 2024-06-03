FROM alpine:3.20

ARG TERRAFORM_VERSION=1.7.3
ARG REVIEWDOG_VERSION=v0.17.4

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN apk --no-cache add git jq

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

RUN wget -q https://releases.hashicorp.com/terraform/"${TERRAFORM_VERSION}"/terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip \
    && unzip ./terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip -d /usr/local/bin/ \
    && rm -rf ./terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
