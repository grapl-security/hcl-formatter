ARG PACKER_VERSION
FROM hashicorp/packer:${PACKER_VERSION}
COPY docker_entrypoint.sh /docker_entrypoint.sh
ENTRYPOINT ["/docker_entrypoint.sh"]
