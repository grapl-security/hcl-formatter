#!/usr/bin/env bash

# Find all *.nomad and *.hcl files in the mounted directory and send
# them through `packer fmt`.
#
# This allows us to format more HCL files than `packer` recognizes
# natively. It only looks for `*.pkr.hcl` and `*.pkrvars.hcl` files;
# otherwise we would just use `packer fmt -recursive` and call it a
# day.
#
# This script is written assuming access to busybox implementations of
# common commands, because that is what currently exists in the
# `hashicorp/packer` image we base our image on.

set -euo pipefail

readonly command="${1:-lint}"

case "${command}" in
    lint)
        packer_cmd="packer fmt -check -diff"
        ;;
    format)
        packer_cmd="packer fmt"
        ;;
    *)
        echo "Unrecognized command; use 'format' or 'lint'"
        exit 1
        ;;
esac

find /workdir \
     -type f \
     \( -name "*.nomad" -or -name "*.hcl" \) \
     -print0 \
     | xargs -0 -n1 ${packer_cmd}
