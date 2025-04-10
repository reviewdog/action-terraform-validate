#!/bin/sh
set -e

TERRAFORM_VERSION=$1
CLI=$2

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

downloadTerraform() {
  wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}".zip \
      && unzip "./terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -d /usr/local/bin/ \
      && rm -rf "./terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip"
}
downloadOpenTofu() {
  wget -q "https://github.com/opentofu/opentofu/releases/download/v${TERRAFORM_VERSION}/tofu_${TERRAFORM_VERSION}_linux_${ARCH}".zip \
      && unzip "./tofu_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -d /usr/local/bin/ \
      && rm -rf "./tofu_${TERRAFORM_VERSION}_linux_${ARCH}.zip"
}

case "${CLI}" in
  terraform)
    COMMAND=terraform
    downloadTerraform
    ;;
  opentofu)
    COMMAND=tofu
    downloadOpenTofu
    ;;
  *) 
    echo "Unsupported command: ${CLI}. Only terraform and OpenTofu are supported by the action" && exit 1
    ;;
esac

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

$COMMAND init -backend=false
# shellcheck disable=SC2086
$COMMAND validate -json \
  | jq "$jq_script" -c \
  | reviewdog -f="rdjsonl" \
      -name="${INPUT_NAME}" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-level="${INPUT_FAIL_LEVEL}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}
