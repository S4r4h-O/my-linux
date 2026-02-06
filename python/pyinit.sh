#!/bin/bash

GREEN="\e[0;32m"
PURPLE="\e[0;35m"
RESET="\e[0m"

#############################
# LSP AND LINT
#############################

PYREFLY=$(
  cat <<PYREFLY_EOF
# Pyrefly documentation: https://pyrefly.org/en/docs/configuration/#configuration-options
# Define directories to type check. Matching the setup of source in "src".
project-includes = ["src"]

# Add "src" to search path to ensure absolute imports resolve correctly.
search-path = ["src"]

# Match the project's Python version requirement.
python-version = "3.12"

# Standard exclusions, augmented with specific project dirs if needed.
project-excludes = ["**/node_modules", "**/__pycache__", "**/.venv", "**/build", "**/dist"]

# Behavior for untyped functions. "check-and-infer-return-type" is similar to Pyright/Ty default.
untyped-def-behavior = "check-and-infer-return-type"

# Configure specific error codes if necessary.
# Defaults are usually sufficient, but overrides go here.
[errors]
# Example: invalid-argument = true
PYREFLY_EOF
)

TY=$(
  cat <<TY_EOF
# Ty documentation: https://docs.astral.sh/ty/

[environment]
python = "./.venv"
python-platform = "all"
python-version = "3.12"
root = [".", "./src"]

[src]
include = ["src", "tests"]
exclude = ["**/generated/**"]
TY_EOF
)

while true; do
  read -r -p "Choose ty (t) or pyrefly (p) as LSP: " answer
  case $answer in
  t)
    printf "ty was chosen\n"
    echo "$TY" >ty.toml
    break
    ;;
  p)
    printf "pyrefly was chosen\n"
    echo "$PYREFLY" >pyrefly.toml
    break
    ;;
  *)
    echo -n "Invalid option"
    ;;
  esac
done

uv init

cat >pyproject.toml <<PYPROJECT_EOF
[project]
name = "project-name"
version = "0.0.1"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.12"
dependencies = []

[tool.setuptools]
packages = ["src"]

[tool.ruff]
line-length = 80
target-version = "py313"
fix = true
exclude = [".git", ".hg", ".pem", ".venv", "_build", "build", "dist"]

[tool.ruff.lint]
select = [
    "E",
    "W",      # pycodestyle
    "F",      # pyflakes
    "I",      # isort
    "UP",     # pyupgrade
    "B",      # bugbear
    "N",      # pep8-naming
    "C90",    # mccabe
    "PL",     # pylint
    "RUF",    # ruff-specific
    "ANN",    # flake8-annotations
    "A",      # flake8-builtins
    "C4",     # flake8-comprehensions
    "T20",    # flake8-print
    "SIM",    # flake8-simplify
    "ARG",    # flake8-unused-arguments
    "PTH",    # flake8-use-pathlib
    "PYI",    # flake8-pyi
    "ERA",    # eradicate (commented code)
    "S",      # flake8-bandit (security)
    "BLE",    # flake8-blind-except
    "FBT",    # flake8-boolean-trap
    "G",      # flake8-logging-format
    "PIE",    # flake8-pie
    "Q",      # flake8-quotes
    "RSE",    # flake8-raise
    "RET",    # flake8-return
    "SLF",    # flake8-self
    "SLOT",   # flake8-slots
    "TID",    # flake8-tidy-imports
    "TC",     # flake8-type-checking
    "PERF",   # perflint
    "FURB",   # refurb
    "LOG",    # flake8-logging
    "TRY",    # tryceratops
    "YTT",    # flake8-2020
    "TD",     # flake8-todos
    "PT",     # flake8-pytest-style
    "INP",    # flake8-no-pep420
    "EM",     # flake8-errmsg
    "ISC",    # flake8-implicit-str-concat
    "FLY",    # flynt
    "PGH",    # pygrep-hooks
    "DOC",    # pydoclint
]
ignore = [
    "D100",    # Missing docstring in public module
    "D101",    # Missing docstring in public class
    "D106",    # Missing docstring in public nested class
    "D104",    # Missing docstring in public package
    "D203",    # 1 blank line required before class docstring
    "D213",    # Multi-line docstring summary should start at the second line
    "RUF012",  # Mutable class attributes should be annotated with
    "PLR0913", # too many arguments
    "PLR0912", # too many branches
    "PLR0915", # too many statements
    "PLR2004", # magic value used in comparison
    "S101",    # assert detected
    "TRY003",  # avoid specifying messages outside exception class
    "TD002",   # Missing author in TODO
    "TD003",   # Missing issue link in TODO
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"
docstring-code-format = true
docstring-code-line-length = 72

[tool.ruff.lint.pycodestyle]
max-line-length = 88
max-doc-length = 88

[tool.ruff.lint.isort]
combine-as-imports = true
split-on-trailing-comma = true
known-first-party = ["package_name"]
force-sort-within-sections = true

[tool.ruff.lint.pylint]
max-args = 8
max-branches = 15
max-returns = 8
max-statements = 60

[tool.ruff.lint.flake8-quotes]
inline-quotes = "single"
multiline-quotes = "double"

[tool.ruff.lint.flake8-bandit]
check-typed-exception = true

# [tool.taskipy.tasks]
# test = "pytest --cov=src --cov-report=term-missing"
# lint = "ruff check . && ruff format --check ."
# format = "ruff check --fix . && ruff format ."
# post_test = "coverage html"

[dependency-groups]
dev = [
  "pytest",
  "pytest-cov",
  "pytest-mock",
  "ruff",
  "pre-commit",
  "ipdb",
  "taskipy",
]
PYPROJECT_EOF

printf "${PURPLE}pyproject.toml created${RESET}\n"

#############################
# PROJECT STRUCTURE
#############################

curl -sL https://www.gitignore.io/api/python >.gitignore

printf "${PURPLE}.gitignore generated ${RESET}\n"

mkdir src

mv main.py src/

printf "${GREEN}Project structure generated! ${RESET}"
