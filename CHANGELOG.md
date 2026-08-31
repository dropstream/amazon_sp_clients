# Changelog

Notable changes to this gem. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Changes that only track updates to Amazon's API models are not
considered breaking and do not trigger a major version bump.

## [Unreleased]

### Added

- CI on GitHub Actions: RSpec on Ruby 3.3 and 3.4, plus RuboCop.
- Characterization specs that pin the current public behavior of
  `Configuration`, `Session`, `ApiClient`, `ApiResponse`,
  `TokenExchangeAuth`, the `RaiseError` middleware, and the module
  helpers (feed upload/download, report download).
- LICENSE (MIT) and this changelog.

### Changed

- Minimum Ruby version is 3.3 (was 2.3).

### Removed

- Travis CI config, `.ruby-gemset`, and the broken `.gitmodules`.
