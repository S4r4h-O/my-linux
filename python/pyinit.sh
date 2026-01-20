#!/bin/bash

GREEN="\e[0;32m"
PURPLE="\e[0;35m"
RESET="\e[0m"

#############################
# LSP AND LINT
#############################

cat <<EOF >pyrightconfig.json
{
  "venvPath": ".",
  "venv": ".venv",
  "include": ["backend", "src"],
  "exclude": ["frontend", "**/__pycache__", "**/.ruff_cache", "**/node_modules"],
  "pythonPlatform": "Linux",
  "reportMissingImports": true,
}
EOF

printf "${PURPLE}pyrightconfig created ${RESET}\n"

uv init

cat >>pyproject.toml <<'EOF'

[tool.ruff]
line-length = 88
target-version = "py313"
fix = true

[tool.ruff.lint]
select = [
  "E",
  "W",    # pycodestyle
  "F",    # pyflakes  
  "I",    # isort
  "UP",   # pyupgrade
  "B",    # bugbear
  "D",    # pydocstyle
  "N",    # pep8-naming
  "C90",  # mccabe
  "PL",   # pylint
  "RUF",  # ruff-specific
  "A",    # flake8-builtins
  "C4",   # flake8-comprehensions
  "T20",  # flake8-print
  "SIM",  # flake8-simplify
  "ARG",  # flake8-unused-arguments
  "PTH",  # flake8-use-pathlib
  "ERA",  # eradicate (commented code)
  "S",    # flake8-bandit (security)
  "BLE",  # flake8-blind-except
  "FBT",  # flake8-boolean-trap
  "G",    # flake8-logging-format
  "PIE",  # flake8-pie
  "Q",    # flake8-quotes
  "RSE",  # flake8-raise
  "RET",  # flake8-return
  "SLF",  # flake8-self
  "SLOT", # flake8-slots
  "TID",  # flake8-tidy-imports
  "TC",   # flake8-type-checking
  "PERF", # perflint
  "FURB", # refurb
  "LOG",  # flake8-logging
  "TRY",  # tryceratops
]
ignore = [
  "D100",    # Missing docstring in public module
  "D101",    # Missing docstring in public class
  "D106",    # Missing docstring in public nested class
  "D104",
  "D203",
  "D213",
  "RUF012",  # Mutable class attributes should be annotated with `typing.ClassVar`
  "PLR0913", # too many arguments  
  "PLR0912", # too many branches
  "PLR0915", # too many statements
  "PLR2004", # magic value used in comparison
  "S101",    # assert detected
  "T201",    # print found (development)
  "FBT001",  # boolean positional arg
  "FBT002",  # boolean default value
  "BLE001",  # blind except Exception
  "TRY003",  # avoid specifying messages outside exception class
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
inline-quotes = "double"
multiline-quotes = "double"

[tool.ruff.lint.flake8-bandit]
check-typed-exception = true
EOF

printf "${PURPLE}pyproject.toml created${RESET}\n"

cat >>pyrefly.toml <<'EOF'
project-includes = ["src"]
project-excludes = ["**/.[!/.]*", "**/tests"]
search-path = ["."]
site-package-path = ["venv/lib/python3.12/site-packages"]

python-platform = "linux"
python-version = "3.12"
python-interpreter-path = ".venv/bin/python3"

replace-imports-with-any = ["sympy.*", "*.series"]
ignore-errors-in-generated-code = true

# disable `bad-assignment` and `invalid-argument` for the whole project
[errors]
bad-assignment = false
invalid-argument = false
EOF

printf "${PURPLE}pyrefly.toml generated ${RESET}\n"

#############################
# PROJECT STRUCTURE
#############################

curl -sL https://www.gitignore.io/api/python >.gitignore

printf "${PURPLE}.gitignore generated ${RESET}\n"

mkdir src

mv main.py src/

printf "${GREEN}Project structure generated! ${RESET}"
