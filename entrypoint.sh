#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

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
  | reviewdog -efm="%f:%l:%c:%m" \
      -name="terraform validate" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}
