# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased][]

## [0.3.0][] - 2019-02-12

Thanks [@bismark](https://github.com/bismark) for the following fixes in
PR [#23](https://github.com/peek-travel/excal/pull/23)

### Fixed

- Fix NIF path issue when including excal as a dependency

### Changed

- Use elixir_make for a more robust build process
- Update Makefile to not recompile every time

## [0.2.0][] - 2019-02-02

### Added

- Documentation and typespecs to all public functions.

### Fixed

- Removed usage of unreleased libical features that were only available in libical master. Excal now compiles with libical >= 3.0.0

## 0.1.0 - 2018-07-04

### Initial release

[Unreleased]: https://github.com/peek-travel/excal/compare/0.3.0...HEAD
[0.3.0]: https://github.com/peek-travel/excal/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/peek-travel/excal/compare/0.1.0...0.2.0
