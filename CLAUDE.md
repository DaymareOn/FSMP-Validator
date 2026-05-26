# FSMP-Validator — project-specific rules

Universal rules (gstack, commits, zero-errors) are in `~/.claude/CLAUDE.md`.
This is a pure schema + documentation project — no C++ code, no build system.

## What this project is

XSD schemas and reference documentation for HDT-SMP physics configuration files.
The schemas define the valid structure of the XML configs that hdtSMP64 reads at runtime.

## Scope

- `schemas/` — XSD/XML schema definitions
- `docs/`    — human-readable reference documentation
- No source code, no CMakeLists.txt, no vcpkg

## Exceptions to global rules

- **Zero-errors**: applies to schema validity (xmllint or equivalent), not compilation
- **E2E / i18n / device configs / data sanitizer**: N/A
