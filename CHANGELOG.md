# Changelog
This project follows [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

## [0.7.1] - 2023-06-11
### Added
- The `printChanges() function to print changes only and skip the header part

## [0.7.0] - 2023-06-11
### Added
- Keep freetext directly under release headings

### Changed
- Min SDK version is 3.0.0

## [0.6.0] - 2023-02-14
### Added
- You may pass an instance of markdown `Document` to the `parseChangelog()` to have fine-grained control over parsing, e.g. whether to encode HTML entities
- Support for \[YANKED\] releases

### Changed
- Bumped `markdown` to 7.0.0
- Bumped `marker` to 0.5.0
- HTML entities (ampersands, quotes, etc) are NOT encoded by default

## [0.5.0] - 2022-12-06
### Changed
- Updated dependencies: markdown to 6.0.0, marker to 0.4.0

## [0.4.0] - 2022-05-09
### Changed
- Bumped the versions of dependencies: markdown to 5.0.0, marker to 0.3.0, pub\_semver to 2.1.1
- Bumped the SDK version to 2.16.2

## [0.3.1] - 2021-12-28
### Changed
- Updated dependencies
- Prevent adding an existing release

## [0.3.0] - 2021-04-11
### Changed
- Release date is now required for each version.
- Change types are not limited by the ones listed by semver.
- Parsing and printing moved to standalone functions.

### Removed
- Dependency on `maybe_just_nothing`.
- Dependency on `dart:io`.
- Markdown-related parts of the API.
- The `Changelog.release()` method. This logic will be added directly to [Cider](https://pub.dev/packages/cider).

## [0.2.0] - 2021-03-22
### Changed
- Migrated to null safety
- The "Unreleased" section is hidden when empty

## [0.1.1] - 2020-10-18
### Changed
- Bump dependencies versions

## [0.1.0] - 2020-07-26
### Changed
- API has been reworked substantially

### Removed
- CLI part. Use [Cider](https://pub.dev/packages/cider)

## [0.0.13] - 2020-07-24
### Added
- Support for changelogs with missing dates

## [0.0.12] - 2020-07-23
### Added
- Ability to parse changelog with missing change type

## [0.0.11] - 2020-07-20
### Changed
- Upgraded dependencies

## [0.0.10] - 2020-07-18
### Fixed
- Missing diff link was breaking the app

## [0.0.9] - 2020-07-18
### Added
- `Collection.addText()`
- `MarkdownLine.parse()`

## [0.0.8] - 2020-07-18
### Added
- A static `fromLines()` factory method

## [0.0.7] - 2020-07-12
### Changed
- Updated dependencies

## [0.0.6] - 2020-07-08
### Added
- New command 'print' to output a released version

## [0.0.5] - 2020-07-05
### Added
- Create CHANGELOG.md when missing

## [0.0.4] - 2020-06-24
### Added
- Support for multiple major versions in a single file

## [0.0.3] - 2020-06-23
### Added
- Console app
- Changelog model

### Changed
- **BREAKING** Total rework of the package

## [0.0.2] - 2018-10-18
### Added
- Changelog.writeFile()

## 0.0.1 - 2018-10-18
### Added
- Parsing from markdown
- Writing to markdown

[0.7.1]: https://github.com/f3ath/change/compare/0.7.0...0.7.1
[0.7.0]: https://github.com/f3ath/change/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/f3ath/change/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/f3ath/change/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/f3ath/change/compare/0.3.1...0.4.0
[0.3.1]: https://github.com/f3ath/change/compare/0.3.0...0.3.1
[0.3.0]: https://github.com/f3ath/change/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/f3ath/change/compare/0.1.1...0.2.0
[0.1.1]: https://github.com/f3ath/change/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/f3ath/change/compare/0.0.13...0.1.0
[0.0.13]: https://github.com/f3ath/change/compare/0.0.12...0.0.13
[0.0.12]: https://github.com/f3ath/change/compare/0.0.11...0.0.12
[0.0.11]: https://github.com/f3ath/change/compare/0.0.10...0.0.11
[0.0.10]: https://github.com/f3ath/change/compare/0.0.9...0.0.10
[0.0.9]: https://github.com/f3ath/change/compare/0.0.8...0.0.9
[0.0.8]: https://github.com/f3ath/change/compare/0.0.7...0.0.8
[0.0.7]: https://github.com/f3ath/change/compare/0.0.6...0.0.7
[0.0.6]: https://github.com/f3ath/change/compare/0.0.5...0.0.6
[0.0.5]: https://github.com/f3ath/change/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/f3ath/change/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/f3ath/change/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/f3ath/change/compare/0.0.1...0.0.2
