variable "PACKER_VERSION" {
  default = "1.8.2"
}

group "default" {
  targets = ["hcl-formatter"]
}

target "hcl-formatter" {
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    PACKER_VERSION = "${PACKER_VERSION}"
  }
  labels = {
    "org.opencontainers.image.authors" = "https://graplsecurity.com"
    "org.opencontainers.image.source"  = "https://github.com/grapl-security/hcl-formatter",
    "org.opencontainers.image.vendor"  = "Grapl, Inc."
  }
  tags = [
    "docker.cloudsmith.io/grapl/raw/hcl-formatter:latest",
    "docker.cloudsmith.io/grapl/raw/hcl-formatter:${PACKER_VERSION}"
  ]
}
