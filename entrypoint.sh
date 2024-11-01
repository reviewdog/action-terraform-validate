#!/bin/sh
set -e

TERRAFORM_VERSION=$1

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

UNAME_ARCH="$(uname -m)"
case "${UNAME_ARCH}" in
  x86*)      ARCH=amd64;;
  arm64)     ARCH=arm64;;
  aarch64)   ARCH=arm64;;
  *)         echo "Unsupported architecture: ${UNAME_ARCH}. Only AMD64 and ARM64 are supported by the action" && exit 1
esac

wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}".zip \
    && unzip "./terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -d /usr/local/bin/ \
    && rm -rf "./terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"
export TF_TOKEN_app_terraform_io="${INPUT_TERRAFORM_CLOUD_TOKEN}"

jq_script='
.diagnostics[]
| {
  severity: (.severity|ascii_upcase),
  message: "\(.summary)\n\(.detail)",
  location: {
    path: .range.filename,
    range: {
      start: (.range.start|{line, column}),
      end: (.range.end|{line, column})},
    },
}
'

terraform init -backend=false
# shellcheck disable=SC2086
terraform validate -json \
  | jq "$jq_script" -c \
  | reviewdog -f="rdjsonl" \
      -name="${INPUT_NAME}" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}
