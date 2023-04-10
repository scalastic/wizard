
![Wild](./docs/wild.png)

[![License](https://img.shields.io/github/license/scalastic/wild.svg?style=flat-square)](https://github.com/scalastic/wild/blob/master/LICENSE)
[![bash](https://img.shields.io/badge/bash-4.4%2B-brightgreen)](https://www.gnu.org/software/bash/)
[![Test and Code Coverage](https://github.com/scalastic/wild/actions/workflows/workflow.yml/badge.svg?branch=main)](https://github.com/scalastic/wild/actions/workflows/workflow.yml)
[![codecov](https://codecov.io/gh/scalastic/wild/branch/main/graph/badge.svg?token=KO9TRVNQWE)](https://codecov.io/gh/scalastic/wild)

# Wide Integration Locally with Delivery

Wild stands for **Wide Integration Locally with Delivery**. Due to its ***Wild*** nature, it fills the gap between the developer and the CI/CD platform by allowing to run the exact same integration and deployment scripts locally and on the build server.

Developers can test the operation of the CI/CD chain on their local station and no longer have to wait and wonder what will happen once their code is pushed on the integration servers.

**Wild** fills the missing link of the DevOps approach and its *shift-left* principal herein. With **Wild** the shifts are so close to the developer that they no longer exist. This is where **Wild** can be described as a ***shift-less*** framework.

----

## Table of Contents

- [Supported platforms](#supported-platforms)
- [Supported technologies and extensibility](#supported-technologies-and-extensibility)
- [Requirements](#requirements)
- [Installation](#installation)
- [Tutorial](#tutorial)
- [Wild CLI](#wild-cli)
  - [Command options](#command-options)
- [Project directory](#project-directory)
  - [Typical directory structure](#typical-directory-structure)
  - [Options file](#options-file)
- [For developers](#for-developers)
  - [Related projects](#related-projects)
  - [Contributions](#contributions)

## Supported platforms

- Local
- Jenkins
- GitLab-CI

## Supported technologies and extensibility

## Requirements

## Installation

## Tutorial

## Wild CLI

### Command options

## Project directory

### Typical directory structure

```text
<PROJECT-ROOT> directory
├─ .shellspec                       [recommended] 
│
├─ config/
│   ├─ sequence-default.json        [default] Default configuration
│   ├─ sequence-project1.json       [specific] Your specific configuration
│              :
|
├─ coverage/                        [optional] Ignore from version control
|
├─ lib/
│   ├─ your_library1.sh
│              :
│
├─ spec/ (also <HELPERDIR>)
│   ├─ spec_helper.sh               [recommended]
│   ├─ banner[.md]                  [optional]
│   ├─ support/                     [optional]
│   │
│   ├─ bin/
│   │   ├─ your_script1_spec.sh
│   │             :
│   ├─ lib/
│   │   ├─ your_library1_spec.sh
```

### Options file

## For developers

### Related projects

- [getoptions](https://github.com/ko1nksm/getoptions) - An elegant option parser for shell scripts (full support for all POSIX shells).

- [Inline](https://github.com/carlocorradini/inline) - Inline script sources.

- [ShellSpec](https://github.com/shellspec/shellspec) - A full-featured BDD unit testing framework for dash, bash, ksh, zsh and all POSIX shells that provides first-class features such as code coverage, mocking, parameterized test, parallel execution and more.

- [ShellCheck](https://github.com/koalaman/shellcheck) - A static analysis tool for shell scripts.

- [ShellMetrics](https://github.com/shellspec/shellmetrics) - ShellMetrics is Cyclomatic Complexity Analyzer for shell script.

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) - A specification for adding human and machine readable meaning to commit messages.

### Contributions

All contributions are welcome!
