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

function usage() {
    echo "hcl-formatter [--help] [--ignore=FILE]* [ACTION]" >&2
    echo >&2
    echo "Options:" >&2
    echo "    --help              Show this help message" >&2
    echo "    --ignore            Specify the path of an HCL file that should not be processed." >&2
    echo "                        Specify the complete literal path within the repository (no wildcards)." >&2
    echo "                        May be repeated multiple times." >&2
    echo >&2
    echo "Actions:" >&2
    echo "    lint                Check that all files are properly formatted." >&2
    echo "                        This is the default action if none is otherwise specified." >&2
    echo "    format              Reformat all files" >&2
}

# Some files are apparently legal HCL (and can be consumed by Nomad,
# Consul, etc.) but for some reason are not able to be parsed by
# Packer's formatter (which is "fine", I guess... we're already
# abusing Packer here as it is). By specifying these files with an
# `--ignore` option, we can filter them out, which still allows us to
# format the bulk of our HCL files.
ignores=()

while :; do
    case "${1:-}" in
        --help)
            usage
            exit
            ;;
        --ignore)
            if [ "${2:-}" ]; then
                ignores+=("${2}")
                shift
            else
                echo "--ignore must have an argument" >&2
                exit 1
            fi
            ;;
        --ignore=?*)
            ignores+=("${1#*=}")
            ;;
        --ignore=)
            echo "--ignore cannot have an empty argument" >&2
            exit 1
            ;;
        --)
            # End of options; stop processing
            shift
            break
            ;;
        -?*)
            echo "Found unrecognized option '${1}'" >&2
            exit 1
            ;;
        *)
            # Found non-option; stop processing
            break
            ;;
    esac
    shift
done

readonly command="${1:-lint}"

# We're using an array for `packer_cmd` for quoting / splitting
# concerns. Yay, Bash!
case "${command}" in
    lint)
        packer_cmd=(packer fmt -check -diff)
        ;;
    format)
        packer_cmd=(packer fmt)
        ;;
    *)
        echo "Unrecognized command; use 'format' or 'lint'"
        exit 1
        ;;
esac

########################################################################
# Now that we've processed the arguments, we need to further process
# any files that should be ignored in a way that `find` can understand.
processed_ignores=()

for ignore in "${ignores[@]}"; do
    processed_ignores+=(\( -not -path "${ignore}" \))
done

########################################################################

find /workdir \
    -type f \
    \( -name "*.nomad" -or -name "*.hcl" \) \
    "${processed_ignores[@]}" \
    -print0 |
    xargs -0 -n1 "${packer_cmd[@]}"
