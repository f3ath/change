# change
Changelog manipulation tool written in Dart. 

## Features
- Supports basic features of Markdown such as bold, italic, links, etc.
- Automatic diff links generation.

## Limitations
- Works with changelogs following [keepachangelog](https://keepachangelog.com/en/1.0.0/) format only.
- Complex Markdown (e.g. inline HTML) will probably not work.


## Usage
### Adding entries to Unreleased section
#### Additions
To add `- New *cool* feature` to the **Added** section run
```
change added "New *cool* feature"
```

#### Changes
To add `- Renamed foo to bar` to the **Changed** section run
```
change changed "Renamed foo to bar"
```

#### Deprecations
To add `- Do not use foo` to the **Deprecated** section run
```
change deprecated "Do not use foo"
```

#### Removals
To add `- Old feature` to the **Removed** section run
```
change removed "Old feature"
```

#### Fixed
To add `- Nasty bug` to the **Fixed** section run
```
change added "Nasty bug"
```

#### Security
To add `- Do not store passwords` to the **Security** section run
```
change added "Do not store passwords"
```

### Releasing unreleased changes
To release all unreleased changes under version 1.1.0 and generate diff links run
```
change release 1.1.0 -l https://github.com/example/project/compare/%from%...%to%
```