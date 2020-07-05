Changelog manipulation tool written in Dart. 

## Features
- Supports basic features of Markdown such as bold, italic, links, etc.
- Automatic diff links generation.

## Limitations
- Works with changelogs following [keepachangelog](https://keepachangelog.com/en/1.0.0/) format only.
- Complex Markdown (e.g. inline HTML) will probably not work.

## Installation
```
pub global activate change
```

## Usage
### Adding entries to Unreleased section
To add a change entry to the Unreleased section, run the following command `change <type> <entry>`.
- `<type>` is one of the following: `added`, `changed`, `deprecated`, `removed`, `fixed`, `security`.
- `<entry>` is an arbitrary line of markdown.

#### Example

By running these commands
```
change added "New *cool* feature"
change changed "Renamed foo to [bar](https://example.com/bar)"
```
you create two entries in the CHANGELOG:
```markdown
## Unreleased
### Added
- New *cool* feature
### Changed
- Renamed foo to [bar](https://example.com/bar)
```

### Releasing unreleased changes
To release all unreleased changes under a new version, run
```
change release <version> -l <diff_link> -d <date>
```
- `<version>` is the version for the new release.
- optional `<date` is the release date. Default is today.
- optional `<diff_link>` is the diff link template.

#### Example
CHANGELOG before:
```markdown
## Unreleased
### Added
- New *cool* feature

### Changed
- Renamed foo to [bar](https://example.com/bar)
```

release command:
```
change release 0.1.0 -l "https://github.com/example/project/compare/%from%...%to%" -d "2020-06-07"
```

CHANGELOG after:
```markdown
## Unreleased
## [0.1.0] - 2020-06-07
### Added
- New *cool* feature

### Changed
- Renamed foo to [bar](https://example.com/bar)

[Unreleased]: https://github.com/example/project/compare/0.1.0...HEAD
```
