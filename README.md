# HCL Formatter

Repackages the [hashicorp/packer][dockerhub] container into one that
knows how to reformat all `*.hcl` and `*.nomad` files in a directory,
recursively.

Mount your directory at `/workdir` in the container, with write
permissions and as your current machine user, and the container will
format all the HCL files it finds. (If you don't override the user,
you will end up with incorrect file ownership, which is no fun for
anyone.)

You can run it directly with `docker`:

```sh
docker run \
    --rm \
    --mount=type=bind,source="$(pwd)",destination=/workdir \
    --user=$(id -u):$(id -g) \
    docker.cloudsmith.io/grapl/releases/hcl-formatter:latest format
```

Alternatively, you can set up a `docker-compose.yml` file like this:

```yaml
version: "3.8"
services:
  hcl-formatter:
    image: docker.cloudsmith.io/grapl/releases/hcl-formatter:latest
    command: format
    volumes:
      - type: bind
        source: .
        target: /workdir
        read_only: false
```

and invoke the service like so:

```sh
docker-compose run --rm --user=$(id -u):$(id -g) hcl-formatter
```

Changing the command to `lint` will instead invoke `packer fmt -check
-diff` on the files. This invocation does not need write permissions
to the mounted directory, nor does it require a different user to be
set.

## Developing

### Prerequisites
- Docker
- Docker `buildx` plugin
- Docker Compose

### Updating the image version
When new versions of [hashicorp/packer][dockerhub] are available,
update the default value of `PACKER_VERSION` in
[docker-bake.hcl](./docker-bake.hcl) to match and rebuild the image
with `make image`.

[dockerhub]: https://hub.docker.com/r/hashicorp/packer/
