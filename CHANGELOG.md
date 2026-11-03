# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The repository has no version tags yet.

## [Unreleased]

### Added

- 2026-11-03: Engineering baseline: `SECURITY.md`, `CHANGELOG.md`, PR and issue templates, `.editorconfig`, `.gitattributes`, markdownlint config, pre-commit config, `docs/adr/` with ADR-0001, `make setup`, `make lint` and `make ci`.
- 2026-11-03: CI runs a lint job (markdownlint, shellcheck, `-Werror` compile of every source).

### Changed

- 2026-11-03: `make ci` runs lint, the test suite and a sanitizer smoke run; `make test` uses the python-chess virtualenv from `make setup` when present.
- 2026-11-03: CI workflow gets `permissions: contents: read`, `concurrency`, job timeouts and no persisted checkout credentials. Dependabot is now monthly, grouped, one open PR, 7-day cooldown.
- 2026-11-03: `CONTRIBUTING.md` documents branch prefixes, PR titles and `make ci`. README perft table uses text results instead of emoji.
