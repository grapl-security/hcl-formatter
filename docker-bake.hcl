variable "PACKER_VERSION" {
  default = "1.7.4"
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
  tags = [
    "docker.cloudsmith.io/grapl/raw/hcl-formatter:latest",
    "docker.cloudsmith.io/grapl/raw/hcl-formatter:${PACKER_VERSION}"
  ]
}
