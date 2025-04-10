# action-terraform-validate

[![Test](https://github.com/maruLoop/action-terraform-validate/workflows/Test/badge.svg)](https://github.com/maruLoop/action-terraform-validate/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/maruLoop/action-terraform-validate/workflows/reviewdog/badge.svg)](https://github.com/maruLoop/action-terraform-validate/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/maruLoop/action-terraform-validate/workflows/depup/badge.svg)](https://github.com/maruLoop/action-terraform-validate/actions?query=workflow%3Adepup)
[![release](https://github.com/maruLoop/action-terraform-validate/workflows/release/badge.svg)](https://github.com/maruLoop/action-terraform-validate/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/maruLoop/action-terraform-validate?logo=github&sort=semver)](https://github.com/maruLoop/action-terraform-validate/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

![github-pr-review demo](images/pr-comment.png)
![github-pr-check demo](images/pr-check.png)

This action runs [terraform validate](https://developer.hashicorp.com/terraform/cli/commands/validate) with [reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve experience.

## Input

```yaml
inputs:
  github_token:
    description: 'GITHUB_TOKEN'
    default: '${{ github.token }}'
  workdir:
    description: 'Working directory relative to the root directory.'
    default: '.'
  ### Flags for reviewdog ###
  level:
    description: 'Report level for reviewdog [info,warning,error]'
    default: 'error'
  reporter:
    description: 'Reporter of reviewdog command [github-pr-check,github-check,github-pr-review].'
    default: 'github-pr-check'
  filter_mode:
    description: |
      Filtering mode for the reviewdog command [added,diff_context,file,nofilter].
      Default is added.
    default: 'added'
  fail_level:
    description: |
      If set to `none`, always use exit code 0 for reviewdog.
      Otherwise, exit code 1 for reviewdog if it finds at least 1 issue with severity greater than or equal to the given level.
      Possible values: [none,any,info,warning,error]
      Default is `none`.
    default: 'none'
  fail_on_error:
    description: |
      Deprecated, use `fail_level` instead.
      Exit code for reviewdog when errors are found [true,false]
      Default is `false`.
    deprecationMessage: Deprecated, use `fail_level` instead.
    default: 'false'
  name:
    description: |
      Tool name shown in review comment for reviewdog.
      Also acts as an identifier for determining which comments reviewdog should overwrite.
      Useful in monorepos with multiple root modules where terraform validate needs to run multiple times.
    default: 'terraform validate'
  reviewdog_flags:
    description: 'Additional reviewdog flags'
    default: ''
  ### Variables for Terraform  ###
  terraform_version:
    description: 'The terraform version to install and use.'
  cli:
    description: 'Execution tool name. e.g.) "terraform", "opentofu"'
    default: "terraform"
```

## Usage

### For single root module

```yaml
name: reviewdog
on: [pull_request]
jobs:
  terraform_validate:
    name: runner / terraform validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: reviewdog/action-terraform-validate@9903ffe0b439c6fd28a7c91c13168e5d58cc8085 # v1.15.3
        with:
          github_token: ${{ secrets.github_token }}
          # Change reviewdog reporter if you need [github-pr-check,github-check,github-pr-review].
          reporter: github-pr-review
          # Change reporter level if you need.
          # GitHub Status Check won't become failure with warning.
          level: warning
```

### For multiple root modules

```yaml
name: reviewdog
on: [pull_request]
jobs:
  terraform_validate:
    name: runner / terraform validate
    strategy:
      matrix:
        root_module:
          - development
          - production
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
      - uses: reviewdog/action-terraform-validate@9903ffe0b439c6fd28a7c91c13168e5d58cc8085 # v1.15.3
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review
          level: warning
          # Explicitly specify a root module path for each job.
          workdir: ./terraform/${{ matrix.root_module }}
          # Explicitly specify a unique name for each job to prevent reviewdog from overwriting comments across jobs.
          name: terraform validate ${{ matrix.root_module }}
```
