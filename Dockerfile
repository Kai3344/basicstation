# Builder image
FROM balenalib/aarch64-debian:buster-build as builder

# Switch to working directory for our app
WORKDIR /usr/src/app

# Copy all the source code in.
COPY . .

# Compile our source code
RUN make platform=rpi variant=std arch=aarch64
RUN make platform=corecell variant=std arch=aarch64

# Runner image
FROM balenalib/aarch64-debian:buster-run as runner

# Install required runtime packages
RUN install_packages jq vim

# Switch to working directory for our app
WORKDIR /usr/src/app

# Copy fles from builder and repo
COPY --from=builder /usr/src/app/ ./
COPY start* ./

# Launch our binary on container startup.
CMD ["bash", "start.sh"]
