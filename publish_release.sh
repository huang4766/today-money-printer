#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="${1:-}"
VERSION_FILE="$ROOT_DIR/VERSION"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1"
    exit 1
  fi
}

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "Missing required file: $1"
    exit 1
  fi
}

current_version() {
  require_file "$VERSION_FILE"
  tr -d '[:space:]' < "$VERSION_FILE"
}

next_patch_version() {
  local version="$1"
  local major minor patch
  IFS='.' read -r major minor patch <<< "$version"

  if [[ -z "${major:-}" || -z "${minor:-}" || -z "${patch:-}" ]]; then
    echo "Invalid version in $VERSION_FILE: $version"
    exit 1
  fi

  echo "${major}.${minor}.$((patch + 1))"
}

if [[ -z "$VERSION" ]]; then
  VERSION="$(next_patch_version "$(current_version)")"
  echo "No version argument provided, auto-bumping to $VERSION"
fi

TAG="v${VERSION}"
TITLE="今日印钞 ${TAG}"
NOTES_FILE="$ROOT_DIR/release-notes-v${VERSION}.md"
ASSET_NAME="today-money-printer-v${VERSION}-macos.zip"
ASSET_PATH="$ROOT_DIR/dist/$ASSET_NAME"
README_FILE="$ROOT_DIR/README.md"
ENV_FILE="$ROOT_DIR/.env"

GITHUB_REPO="${GITHUB_REPO:-huang4766/today-money-printer}"
GITEE_OWNER="${GITEE_OWNER:-hl95599}"
GITEE_REPO="${GITEE_REPO:-today-money-printer}"
GITEE_TOKEN="${GITEE_TOKEN:-}"
SKIP_BUILD="${SKIP_BUILD:-0}"

GITHUB_RELEASES_URL="https://github.com/${GITHUB_REPO}/releases"
GITHUB_LATEST_URL="${GITHUB_RELEASES_URL}/latest"
GITEE_RELEASES_URL="https://gitee.com/${GITEE_OWNER}/${GITEE_REPO}/releases"

load_env_file() {
  if [[ -f "$ENV_FILE" ]]; then
    set -a
    source "$ENV_FILE"
    set +a
  fi
}

ensure_gitee_token() {
  if [[ -z "$GITEE_TOKEN" ]]; then
    echo "Missing GITEE_TOKEN environment variable."
    echo "Create a Gitee personal access token with repo access and export it before running."
    exit 1
  fi
}

sync_readme_download_links() {
  require_file "$README_FILE"

  python3 - "$README_FILE" "$GITHUB_LATEST_URL" "$GITEE_RELEASES_URL" "$GITHUB_RELEASES_URL" <<'PY'
from pathlib import Path
import sys

readme_path = Path(sys.argv[1])
github_latest = sys.argv[2]
gitee_latest = sys.argv[3]
github_releases = sys.argv[4]

content = readme_path.read_text(encoding="utf-8")
lines = content.splitlines()
updated = []

for line in lines:
    stripped = line.strip()
    if stripped.startswith("- 最新 GitHub 下载页:"):
        updated.append(f"- 最新 GitHub 下载页: [today-money-printer 最新版]({github_latest})")
    elif stripped.startswith("- 最新 Gitee 下载页:"):
        updated.append(f"- 最新 Gitee 下载页: [today-money-printer 最新版]({gitee_latest})")
    elif stripped.startswith("- Releases:"):
        updated.append(f"- Releases: [huang4766/today-money-printer/releases]({github_releases})")
    else:
        updated.append(line)

readme_path.write_text("\n".join(updated) + "\n", encoding="utf-8")
PY
}

write_version_file() {
  printf '%s\n' "$VERSION" > "$VERSION_FILE"
}

ensure_release_notes_file() {
  if [[ -f "$NOTES_FILE" ]]; then
    return
  fi

  local latest_notes
  latest_notes="$(ls "$ROOT_DIR"/release-notes-v*.md 2>/dev/null | sort | tail -n 1)"

  if [[ -z "$latest_notes" ]]; then
    cat > "$NOTES_FILE" <<EOF
# 今日印钞 ${TAG}

一个维护更新版本。

## 更新

- 待补充

## 使用方式

1. 下载 \`今日印钞.app\` 或对应压缩包
2. 打开后在菜单栏中找到 \`今日印钞\`
3. 点击菜单栏图标进入设置面板
4. 填写你的月薪、时薪、工时和规则

## 已知说明

- 当前主要面向 \`macOS 14+\`
- 如果遇到 Gatekeeper 拦截，需要在系统设置中允许打开
EOF
    echo "Created $NOTES_FILE from built-in template"
    return
  fi

  python3 - "$latest_notes" "$NOTES_FILE" "$TAG" <<'PY'
from pathlib import Path
import re
import sys

source_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])
tag = sys.argv[3]

content = source_path.read_text(encoding="utf-8")
content = re.sub(r"^# 今日印钞 v[0-9]+\.[0-9]+\.[0-9]+$", f"# 今日印钞 {tag}", content, count=1, flags=re.M)

if "## 更新" in content and "- 待补充" not in content:
    content = content.replace("## 更新\n", "## 更新\n\n- 待补充\n", 1)

target_path.write_text(content, encoding="utf-8")
PY

  echo "Created $NOTES_FILE from $(basename "$latest_notes")"
}

github_release_exists() {
  gh release view "$TAG" --repo "$GITHUB_REPO" >/dev/null 2>&1
}

create_or_update_github_release() {
  if github_release_exists; then
    echo "GitHub release $TAG already exists, updating notes and asset..."
    gh release edit "$TAG" \
      --repo "$GITHUB_REPO" \
      --title "$TITLE" \
      --notes-file "$NOTES_FILE"
  else
    echo "Creating GitHub release $TAG..."
    gh release create "$TAG" "$ASSET_PATH" \
      --repo "$GITHUB_REPO" \
      --title "$TITLE" \
      --notes-file "$NOTES_FILE"
    return
  fi

  gh release upload "$TAG" "$ASSET_PATH" \
    --repo "$GITHUB_REPO" \
    --clobber
}

gitee_api() {
  local method="$1"
  local url="$2"
  shift 2

  curl --fail --silent --show-error \
    -X "$method" \
    "$url" \
    "$@"
}

fetch_gitee_release_by_tag() {
  gitee_api GET \
    "https://gitee.com/api/v5/repos/${GITEE_OWNER}/${GITEE_REPO}/releases/tags/${TAG}?access_token=${GITEE_TOKEN}"
}

gitee_release_exists() {
  fetch_gitee_release_by_tag >/dev/null 2>&1
}

create_gitee_release() {
  echo "Creating Gitee release $TAG..."
  gitee_api POST \
    "https://gitee.com/api/v5/repos/${GITEE_OWNER}/${GITEE_REPO}/releases" \
    --data-urlencode "access_token=${GITEE_TOKEN}" \
    --data-urlencode "tag_name=${TAG}" \
    --data-urlencode "name=${TITLE}" \
    --data-urlencode "body=$(cat "$NOTES_FILE")" \
    --data-urlencode "prerelease=false" \
    >/dev/null
}

update_gitee_release() {
  local release_id="$1"
  echo "Updating Gitee release $TAG..."
  gitee_api PATCH \
    "https://gitee.com/api/v5/repos/${GITEE_OWNER}/${GITEE_REPO}/releases/${release_id}" \
    --data-urlencode "access_token=${GITEE_TOKEN}" \
    --data-urlencode "name=${TITLE}" \
    --data-urlencode "body=$(cat "$NOTES_FILE")" \
    --data-urlencode "prerelease=false" \
    >/dev/null
}

delete_gitee_asset_if_exists() {
  local release_id="$1"
  local release_json="$2"
  local asset_name="$3"
  local asset_id

  asset_id="$(printf '%s' "$release_json" | jq -r --arg name "$asset_name" '.assets[]? | select(.name == $name) | .id' | head -n 1)"
  if [[ -z "$asset_id" || "$asset_id" == "null" ]]; then
    return
  fi

  echo "Deleting existing Gitee asset $asset_name..."
  gitee_api DELETE \
    "https://gitee.com/api/v5/repos/${GITEE_OWNER}/${GITEE_REPO}/releases/${release_id}/attach_files/${asset_id}?access_token=${GITEE_TOKEN}" \
    >/dev/null
}

upload_gitee_asset() {
  local release_id="$1"
  echo "Uploading asset to Gitee release $TAG..."
  curl --fail --silent --show-error \
    -X POST \
    "https://gitee.com/api/v5/repos/${GITEE_OWNER}/${GITEE_REPO}/releases/${release_id}/attach_files" \
    -F "access_token=${GITEE_TOKEN}" \
    -F "file=@${ASSET_PATH}" \
    >/dev/null
}

create_or_update_gitee_release() {
  local release_json release_id

  if gitee_release_exists; then
    release_json="$(fetch_gitee_release_by_tag)"
    release_id="$(printf '%s' "$release_json" | jq -r '.id')"
    update_gitee_release "$release_id"
  else
    create_gitee_release
    release_json="$(fetch_gitee_release_by_tag)"
    release_id="$(printf '%s' "$release_json" | jq -r '.id')"
  fi

  delete_gitee_asset_if_exists "$release_id" "$release_json" "$ASSET_NAME"
  upload_gitee_asset "$release_id"
}

main() {
  require_command gh
  require_command jq
  require_command curl
  require_command python3
  load_env_file
  ensure_gitee_token
  require_file "$VERSION_FILE"
  ensure_release_notes_file
  require_file "$NOTES_FILE"
  write_version_file
  sync_readme_download_links

  if [[ "$SKIP_BUILD" != "1" ]]; then
    "$ROOT_DIR/build_app.sh"
    "$ROOT_DIR/package_release.sh" "$VERSION"
  fi

  require_file "$ASSET_PATH"

  create_or_update_github_release
  create_or_update_gitee_release

  echo
  echo "Release published successfully:"
  echo "GitHub: https://github.com/${GITHUB_REPO}/releases/tag/${TAG}"
  echo "Gitee: https://gitee.com/${GITEE_OWNER}/${GITEE_REPO}/releases/tag/${TAG}"
}

main "$@"
