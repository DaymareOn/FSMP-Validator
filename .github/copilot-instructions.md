# GitHub Copilot Instructions for FSMP-Validator

Assists with HDT-SMP physics configuration schema authoring and documentation.

## Schema conventions

- XSD files in `schemas/`, documentation in `docs/`
- Element names: camelCase; attribute names: camelCase
- Every element and attribute must have an `<xs:annotation><xs:documentation>` entry
- Enumeration values: document the physical meaning and valid range
- Restrict types as tightly as the physics domain allows — use `xs:minInclusive`, `xs:maxInclusive`, `xs:pattern`

## Documentation conventions

- Markdown; one file per major schema component
- Lead each section with a one-sentence summary of what the element controls physically
- Include a minimal valid example for every complex element
- Cross-reference the HDT-SMP runtime behaviour where known

## Commit strategy ("dry commits")

- Semantic types: `feat` / `fix` / `docs` / `style` / `refactor` / `chore`
- One logical unit per commit — no mixed schema + docs changes in a single commit
- Indentation-only fixes: dedicated `style:` commit, never mixed with content changes

## Input validation

All schema authoring must validate correctly against xmllint or equivalent before committing.
Reject schemas that accept values outside the physically meaningful range.

## Not applicable to this project

- ❌ Compilation / compiler warnings (no source code)
- ❌ Build system (no CMakeLists.txt, no MSVC)
- ❌ E2E tests
- ❌ Internationalization
- ❌ Device configuration support
- ❌ Data migration sanitizer
