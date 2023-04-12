# Go 1.18 is required for gaiad
FROM golang:1.18-alpine AS build-env

# Set up dependencies
ENV PACKAGES build-base curl make git libc-dev bash gcc linux-headers eudev-dev python3

# Set working directory for the build
WORKDIR /go/src/github.com/vknowable/gaia

# Install dependencies
RUN apk add --update $PACKAGES
RUN apk add linux-headers

# Add source files
COPY go.mod go.sum* ./
RUN go mod download
COPY . .

# Make the binary
RUN CGO_ENABLED=0 make install

# Final image
FROM alpine:3.17.0

# Install ca-certificates
RUN apk add --update ca-certificates jq curl
WORKDIR /

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/gaiad /usr/local/bin/gaiad

# Run gaiad by default
CMD ["gaiad"]
