ARG BASEDEV_VERSION=v0.25.0
ARG ALPINE_VERSION=3.19
ARG GO_VERSION=1.22
ARG GOMODIFYTAGS_VERSION=v1.16.0
ARG GOPLAY_VERSION=v1.0.0
ARG GOTESTS_VERSION=v1.6.0
ARG DLV_VERSION=v1.22.0
ARG MOCKERY_VERSION=v2.40.1
ARG GOMOCK_VERSION=v1.6.0
ARG MOCKGEN_VERSION=v1.6.0
ARG GOPLS_VERSION=v0.14.2
ARG GOLANGCILINT_VERSION=v1.56.2
ARG IMPL_VERSION=v1.2.0
ARG GOPKGS_VERSION=v2.1.2
ARG KUBECTL_VERSION=v1.29.1
ARG STERN_VERSION=v1.28.0
ARG KUBECTX_VERSION=v0.9.5
ARG KUBENS_VERSION=v0.9.5
ARG HELM_VERSION=v3.14.0


FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS go
FROM iznth/binpot:gomodifytags-${GOMODIFYTAGS_VERSION} AS gomodifytags
FROM iznth/binpot:goplay-${GOPLAY_VERSION} AS goplay
FROM iznth/binpot:gotests-${GOTESTS_VERSION} AS gotests
FROM iznth/binpot:dlv-${DLV_VERSION} AS dlv
FROM iznth/binpot:mockery-${MOCKERY_VERSION} AS mockery
FROM iznth/binpot:gomock-${GOMOCK_VERSION} AS gomock
FROM iznth/binpot:mockgen-${MOCKGEN_VERSION} AS mockgen
FROM iznth/binpot:gopls-${GOPLS_VERSION} AS gopls
FROM iznth/binpot:golangci-lint-${GOLANGCILINT_VERSION} AS golangci-lint
FROM iznth/binpot:impl-${IMPL_VERSION} AS impl
FROM iznth/binpot:gopkgs-${GOPKGS_VERSION} AS gopkgs
FROM iznth/binpot:kubectl-${KUBECTL_VERSION} AS kubectl
FROM iznth/binpot:stern-${STERN_VERSION} AS stern
FROM iznth/binpot:kubectx-${KUBECTX_VERSION} AS kubectx
FROM iznth/binpot:kubens-${KUBENS_VERSION} AS kubens
FROM iznth/binpot:helm-${HELM_VERSION} AS helm

FROM iznth/baseddevcontainer:${BASEDEV_VERSION}-alpine
ARG CREATED
ARG COMMIT
ARG VERSION=local
LABEL \
    org.opencontainers.image.authors="brad@izn.ai" \
    org.opencontainers.image.created=$CREATED \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.url="https://github.com/iznth/godevcontainer" \
    org.opencontainers.image.documentation="https://github.com/iznth/godevcontainer" \
    org.opencontainers.image.source="https://github.com/iznth/godevcontainer" \
    org.opencontainers.image.title="Go Dev container Alpine" \
    org.opencontainers.image.description="Go development container for Visual Studio Code Remote Containers development"
COPY --from=go /usr/local/go /usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH \
    CGO_ENABLED=0 \
    GO111MODULE=on
WORKDIR $GOPATH
# Install Alpine packages (g++ for race testing)
RUN apk add -q --update --progress --no-cache g++
# Shell setup
COPY shell/.zshrc-specific shell/.welcome.sh /root/

COPY --from=gomodifytags /bin /go/bin/gomodifytags
COPY --from=goplay  /bin /go/bin/goplay
COPY --from=gotests /bin /go/bin/gotests
COPY --from=dlv /bin /go/bin/dlv
COPY --from=mockery /bin /go/bin/mockery
COPY --from=gomock /bin /go/bin/gomock
COPY --from=mockgen /bin /go/bin/mockgen
COPY --from=gopls /bin /go/bin/gopls
COPY --from=golangci-lint /bin /go/bin/golangci-lint
COPY --from=impl /bin /go/bin/impl
COPY --from=gopkgs /bin /go/bin/gopkgs

# Extra binary tools
COPY --from=kubectl /bin /usr/local/bin/kubectl
COPY --from=stern /bin /usr/local/bin/stern
COPY --from=kubectx /bin /usr/local/bin/kubectx
COPY --from=kubens /bin /usr/local/bin/kubens
COPY --from=helm /bin /usr/local/bin/helm
