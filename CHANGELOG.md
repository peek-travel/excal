# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased][]

## [0.3.1][] - 2019-03-18

### Fixed

- Fixed typespec for Stream.new - Thanks [@bismark](https://github.com/bismark) - [#29](https://github.com/peek-travel/excal/pull/29)
- Fixed Makefile not recompiling when C source changes - [0a5081bb](https://github.com/peek-travel/excal/commit/0a5081bb865b712cc1e573cce423b320719aa9c3)
- Fixed dialyzer error on `Excal.Interface.Recurrence.Iterator.load_nifs/0` - [#30](https://github.com/peek-travel/excal/pull/30)

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

[Unreleased]: https://github.com/peek-travel/excal/compare/0.3.1...HEAD
[0.3.1]: https://github.com/peek-travel/excal/compare/0.3.0...0.3.1
[0.3.0]: https://github.com/peek-travel/excal/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/peek-travel/excal/compare/0.1.0...0.2.0
