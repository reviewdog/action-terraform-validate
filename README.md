# action-terraform-validate

[![Test](https://github.com/maruLoop/action-terraform-validate/workflows/Test/badge.svg)](https://github.com/maruLoop/action-terraform-validate/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/maruLoop/action-terraform-validate/workflows/reviewdog/badge.svg)](https://github.com/maruLoop/action-terraform-validate/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/maruLoop/action-terraform-validate/workflows/depup/badge.svg)](https://github.com/maruLoop/action-terraform-validate/actions?query=workflow%3Adepup)
[![release](https://github.com/maruLoop/action-terraform-validate/workflows/release/badge.svg)](https://github.com/maruLoop/action-terraform-validate/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/maruLoop/action-terraform-validate?logo=github&sort=semver)](https://github.com/maruLoop/action-terraform-validate/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

![github-pr-review demo](https://user-images.githubusercontent.com/3797062/73162963-4b8e2b00-4132-11ea-9a3f-f9c6f624c79f.png)
![github-pr-check demo](https://user-images.githubusercontent.com/3797062/73163032-70829e00-4132-11ea-8481-f213a37db354.png)

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
  fail_on_error:
    description: |
      Exit code for reviewdog when errors are found [true,false]
      Default is `false`.
    default: 'false'
  reviewdog_flags:
    description: 'Additional reviewdog flags'
    default: ''
  ### Variables for Terraform  ###
  terraform_init_options:
    description: 'options for terraform init to pass backend configuration and so on'
  envvar:
    description: 'Environment variables for terraform init to pass backend configuration'
  terraform_version:
    description: 'The terraform version to install and use. The default is `latest`'
```

## Usage

```yaml
name: reviewdog
on: [pull_request]
jobs:
  terraform_validate:
    name: runner / terraform validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: maruloop/action-terraform-validate@v1
        with:
          github_token: ${{ secrets.github_token }}
          # Change reviewdog reporter if you need [github-pr-check,github-check,github-pr-review].
          reporter: github-pr-review
          # Change reporter level if you need.
          # GitHub Status Check won't become failure with warning.
          level: warning
          envvar: |
            AWS_REGION=ap-northeast-1
```
