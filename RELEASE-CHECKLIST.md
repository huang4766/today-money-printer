# Release Checklist

## Files

- App bundle: `今日印钞.app`
- Release notes: `release-notes-v1.0.0.md`
- Release zip: `dist/today-money-printer-v1.0.0-macos.zip`

## Steps

1. Build the latest app

```bash
./build_app.sh
```

2. Package the release zip

```bash
./package_release.sh 1.0.0
```

3. Create a GitHub Release

- Tag: `v1.0.0`
- Title: `今日印钞 v1.0.0`
- Body: paste `release-notes-v1.0.0.md`
- Asset: upload `dist/today-money-printer-v1.0.0-macos.zip`

## Suggested first release title

`今日印钞 v1.0.0`

## Suggested asset name

`today-money-printer-v1.0.0-macos.zip`
