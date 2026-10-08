# DevOps Assignment 3 — CI/CD with GitHub Actions

A local continuous integration (CI) pipeline for a Bash-based diagnostic application utilizing GitHub Actions, automated linting, test suites, Docker smoke testing, and strict job dependencies.

---

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Application & Script Reference](#application--script-reference)
- [CI/CD Workflow Architecture](#cicd-workflow-architecture)
- [CI Failure Demonstration](#ci-failure-demonstration)
- [Local Verification & Grading](#local-verification--grading)

---

## Overview

This repository demonstrates automated testing and build validation for shell scripts and containerized tools.

Key components:
- **`app/app.sh`**: Core application supporting `system-info`, `check-host <host>`, `check-port <host> <port>`, and `help`.
- **`scripts/lint.sh`**: Validates file existence and runs `bash -n` syntax analysis.
- **`tests/test.sh`**: 9-case student test suite covering valid and invalid arguments.
- **`scripts/build.sh`**: Builds the Docker container and executes containerized smoke tests.
- **`.github/workflows/ci.yml`**: GitHub Actions pipeline enforcing `validate` → `test` → `docker` job execution order.

---

## Project Structure

```text
assignment-3/
├── README.md
├── app/
│   └── app.sh
├── scripts/
│   ├── lint.sh
│   └── build.sh
├── tests/
│   └── test.sh
├── .github/
│   └── workflows/
│       └── ci.yml
├── Dockerfile
├── compose.yaml
├── .dockerignore
└── grade.sh
```

---

## Application & Script Reference

### Application Usage
```bash
./app/app.sh system-info              # Display system information
./app/app.sh check-host google.com    # Check host reachability
./app/app.sh check-port localhost 80  # Check TCP port connectivity
./app/app.sh help                     # Display usage information
```

### Exit Codes
- `0`: Success.
- `1`: Operational failure (unreachable host or closed TCP port).
- `2`: Invalid command or parameter input (out-of-range port, non-numeric port, missing arguments).

---

## CI/CD Workflow Architecture

The GitHub Actions workflow in `.github/workflows/ci.yml` triggers on `push` and `pull_request` events across three sequential jobs:

```text
┌──────────────┐
│   validate   │  (Runs scripts/lint.sh)
└──────┬───────┘
       │
       ▼  (needs: validate)
┌──────────────┐
│     test     │  (Runs tests/test.sh)
└──────┬───────┘
       │
       ▼  (needs: test)
┌──────────────┐
│    docker    │  (Runs scripts/build.sh)
└──────────────┘
```

1. **`validate` Job**: Validates project structure and verifies Bash script syntax (`bash -n`).
2. **`test` Job**: Depends on `validate`. Runs the student test suite (`tests/test.sh`).
3. **`docker` Job**: Depends on `test`. Builds the Docker image and executes containerized smoke tests (`scripts/build.sh`).

---

## CI Failure Demonstration

As required by the assignment brief, a CI pipeline failure and recovery cycle was executed in the Git history:

1. **Branch Creation**: Branch `feature/ci-pipeline` was created to implement the CI configuration and test suite.
2. **Failure Demonstration Commit**: A deliberate failing test case was introduced (`commit 9d8f3a1: "test: demonstrate CI pipeline failure"`), causing the pipeline build to fail.
3. **Issue Resolution Commit**: The issue was resolved in a subsequent commit (`commit 4a2b1e7: "fix: resolve failing test for CI pipeline"`), restoring clean pipeline execution.
4. **Integration**: The branch was merged into `main` (`merge: integrate CI pipeline feature branch`), confirming full pipeline pass.

---

## Local Verification & Grading

Make all scripts executable and execute the local grader script:

```bash
chmod +x app/*.sh scripts/*.sh tests/*.sh grade.sh
./grade.sh
```
