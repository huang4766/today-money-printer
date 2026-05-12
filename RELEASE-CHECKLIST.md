# Release Checklist

## Files

- App bundle: `今日印钞.app`
- Release notes: `release-notes-v1.0.0.md`
- Release zip: `dist/today-money-printer-v1.0.0-macos.zip`

## One Command

```bash
export GITEE_TOKEN=你的_gitee_access_token
./publish_release.sh 1.0.0
```

默认会执行构建、打包，并创建或更新 GitHub / Gitee 两边的 release。

- GitHub 仓库默认用 `huang4766/today-money-printer`
- Gitee 仓库默认用 `hl95599/today-money-printer`
- 如果只想复用已经打好的包，可以加 `SKIP_BUILD=1`

```bash
SKIP_BUILD=1 GITEE_TOKEN=你的_gitee_access_token ./publish_release.sh 1.0.0
```

## Manual Steps

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

4. Create a Gitee Release

- Tag: `v1.0.0`
- Title: `今日印钞 v1.0.0`
- Body: paste `release-notes-v1.0.0.md`
- Asset: upload `dist/today-money-printer-v1.0.0-macos.zip`

## Suggested first release title

`今日印钞 v1.0.0`

## Suggested asset name

`today-money-printer-v1.0.0-macos.zip`
