#!/bin/bash

set -o errexit

main() {
  check_args "$@"

  if [[ $1 == *?":"?* ]]; then
    local image=$(echo library/$1 | cut -d ':' -f 1)
    local tag=$(echo $1 | cut -d ':' -f 2)
  elif [[ $1 == *?":" ]] || [ $1 != null ]; then
    local image=$(echo library/$1 | cut -d ':' -f 1)
    local tag=latest
  else
    echo "Error:

    Usage:
      docker-hub inpect image:tag

    Aborting."
    exit 1
  fi

  # echo "Retrieving info about $( echo $image | cut -c 9- ):$tag..."
  local token=$(get_token $image)
  local digest=$(get_digest $image $tag $token)

  get_image_configuration $image $token $digest
}

get_image_configuration() {
  local image=$1
  local token=$2
  local digest=$3

#  echo "Retrieving Image Configuration.
#    IMAGE:  $image
#    TOKEN:  $token
#    DIGEST: $digest
#  " >&2

  curl \
    --silent \
    --location \
    --header "Authorization: Bearer $token" \
    "https://registry-1.docker.io/v2/$image/blobs/$digest" \
    | jq -r '.container_config'
}

get_token() {
  local image=$1

#  echo "Retrieving Docker Hub token.
#    IMAGE: $image
#  " >&2

  curl \
    --silent \
    "https://auth.docker.io/token?scope=repository:$image:pull&service=registry.docker.io" \
    | jq -r '.token'
}

# Retrieve the digest, now specifying in the header
# that we have a token (so we can pe...
get_digest() {
  local image=$1
  local tag=$2
  local token=$3

#  echo "Retrieving image digest.
#    IMAGE:  $image
#    TAG:    $tag
#    TOKEN:  $token
#  " >&2

  curl \
    --silent \
    --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    --header "Authorization: Bearer $token" \
    "https://registry-1.docker.io/v2/$image/manifests/$tag" \
    | jq -r '.config.digest'
}

check_args() {
  if (($# != 1)); then
    echo "Error:
    Two arguments must be provided - $# provided.

    Usage:
      docker-hub inpect image:tag

Aborting."
    exit 1
  fi
}

main "$@"
