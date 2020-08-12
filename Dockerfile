# Simple usage with a mounted data directory:
# > docker build -t infinitefuture .
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.infinitefutured:/root/.infinitefutured -v ~/.infinitefuturecli:/root/.infinitefuturecli infinitefuture infinitefutured init
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.infinitefutured:/root/.infinitefutured -v ~/.infinitefuturecli:/root/.infinitefuturecli infinitefuture infinitefutured start
FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3

# Set working directory for the build
WORKDIR /go/src/github.com/infinitefuturechain/infinitefuture

# Add source files
COPY . .

# Install minimum necessary dependencies, build Infinitefuture SDK, remove packages
RUN apk add --no-cache $PACKAGES && \
    make tools && \
    make install

# Final image
FROM alpine:edge

# Install ca-certificates
RUN apk add --update ca-certificates
WORKDIR /root

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/infinitefutured /usr/bin/infinitefutured
COPY --from=build-env /go/bin/infinitefuturecli /usr/bin/infinitefuturecli

# Run infinitefutured by default, omit entrypoint to ease using container with infinitefuturecli
CMD ["infinitefutured"]
