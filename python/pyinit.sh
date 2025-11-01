#!/bin/bash

cat <<EOF >pyrightconfig.json
{
  "venvPath": ".",
  "venv": ".venv",
  "include": ["backend"],
  "exclude": ["frontend", "**/__pycache__", "**/node_modules"],
  "pythonPlatform": "Linux",
  "typeCheckingMode": "basic",
  "useLibraryCodeForTypes": true,
  "reportMissingImports": true,
  "reportMissingTypeStubs": false
}
EOF

echo "pyrightconfig created"

uv init
cat >> pyproject.toml <<'EOF'

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

echo "pyproject.toml created"
