# Builder image
ARG ARCH
FROM balenalib/${ARCH}-debian:buster-build as builder
ARG ARCH

# Switch to working directory for our app
WORKDIR /usr/src/app

# Copy all the source code in.
COPY . .

# Compile our source code
RUN make platform=rpi variant=std arch=${ARCH}
RUN make platform=corecell variant=std arch=${ARCH}

# Runner image
FROM balenalib/${ARCH}-debian:buster-run as runner

# Install required runtime packages
RUN install_packages jq vim

# Switch to working directory for our app
WORKDIR /usr/src/app

# Copy fles from builder and repo
COPY --from=builder /usr/src/app/ ./
COPY start* ./

# Launch our binary on container startup.
CMD ["bash", "start.sh"]
