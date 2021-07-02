variable "TAG" { default = "latest" }
variable "VERSION" { default = "latest" }
variable "MAJOR" { default = "latest" }

group "default" {
    targets = ["armv7hf", "aarch64"]
}

target "armv7hf" {
    tags = [
        "docker.io/xoseperez/basicstation:armv7hf-${TAG}",
        "docker.io/xoseperez/basicstation:armv7hf-${MAJOR}",
        "docker.io/xoseperez/basicstation:armv7hf-${VERSION}",
        "docker.io/xoseperez/basicstation:armv7hf-latest",
    ]
    args = {
        "ARCH" = "armv7hf"
    }
    platforms = ["linux/arm/v7"]
}

target "aarch64" {
    tags = [
        "docker.io/xoseperez/basicstation:aarch64-${TAG}",
        "docker.io/xoseperez/basicstation:aarch64-${MAJOR}",
        "docker.io/xoseperez/basicstation:aarch64-${VERSION}",
        "docker.io/xoseperez/basicstation:aarch64-latest",
    ]
    args = {
        "ARCH" = "aarch64"
    }
    platforms = ["linux/arm64"]
}
