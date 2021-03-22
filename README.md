# change
Changelog manipulation in Dart. For the command-line tool, see [Cider](https://pub.dev/packages/cider).

## Features
- Supports some basic Markdown syntax, such as bold, italic, links, etc.
- CRUD operations on releases and changes.
- Generates a new release from `Unreleased` with diff links.

## Limitations
- Works with changelogs following [keepachangelog](https://keepachangelog.com/en/1.0.0/) format only.
- [Semantic versioning](https://semver.org/) is implied.
- Dates must be in ISO 8601 (YYYY-MM-DD) format.
- Complex Markdown (e.g. inline HTML) will probably not work.

