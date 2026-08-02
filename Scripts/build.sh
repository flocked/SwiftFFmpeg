#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"
BUILD_SCRIPT="$SCRIPT_DIR/build-ffmpeg-apple.sh"
PACKAGE_FILE="$REPO_DIR/Package.swift"

platform_targets=(
  "macOS:FFmpegMacOS:FFmpeg-macOS.xcframework"
  "iOS:FFmpegIOS:FFmpeg-iOS.xcframework"
  "tvOS:FFmpegTVOS:FFmpeg-tvOS.xcframework"
  "watchOS:FFmpegWatchOS:FFmpeg-watchOS.xcframework"
  "visionOS:FFmpegVisionOS:FFmpeg-visionOS.xcframework"
)

log() {
  printf "\n==> %s\n" "$*"
}

die() {
  printf "error: %s\n" "$*" >&2
  exit 1
}

latest_artifact_dir() {
  find "$SCRIPT_DIR/Artifacts" -maxdepth 1 -type d -name 'FFmpeg-*' 2>/dev/null | sort -V | tail -n 1
}

zip_xcframework() {
  local xcframework="$1"
  local zip_path="$2"
  local parent name

  parent="$(dirname "$xcframework")"
  name="$(basename "$xcframework")"

  rm -f "$zip_path"
  (
    cd "$parent"
    COPYFILE_DISABLE=1 zip -qry "$zip_path" "$name" \
      -x "*/.DS_Store" \
      -x "*/__MACOSX/*" \
      -x "*/._*"
  )
}

update_checksum() {
  local target="$1"
  local checksum="$2"

  TARGET="$target" CHECKSUM="$checksum" perl -0pi -e '
    my $target = quotemeta($ENV{"TARGET"});
    my $checksum = $ENV{"CHECKSUM"};
    my $count = s/(\.binaryTarget\(\s*name:\s*"$target",.*?checksum:\s*")[^"]+(")/$1$checksum$2/s;
    die "Could not update checksum for $ENV{TARGET}\n" unless $count == 1;
  ' "$PACKAGE_FILE"
}

command -v swift >/dev/null || die "swift not found"
command -v zip >/dev/null || die "zip not found"
[[ -x "$BUILD_SCRIPT" ]] || die "Build script not found or not executable: $BUILD_SCRIPT"
[[ -f "$PACKAGE_FILE" ]] || die "Package.swift not found: $PACKAGE_FILE"

log "Building FFmpeg XCFrameworks"
(
  cd "$SCRIPT_DIR"
  "$BUILD_SCRIPT" -all --separate-platforms "$@"
)

ARTIFACT_DIR="$(latest_artifact_dir)"
[[ -n "$ARTIFACT_DIR" ]] || die "No FFmpeg artifact directory found in $SCRIPT_DIR/Artifacts"

ZIP_DIR="$ARTIFACT_DIR/Zips"
rm -rf "$ZIP_DIR"
mkdir -p "$ZIP_DIR"

log "Zipping XCFrameworks"
for entry in "${platform_targets[@]}"; do
  IFS=: read -r platform target xcframework_name <<< "$entry"
  xcframework_path="$ARTIFACT_DIR/$xcframework_name"
  zip_path="$ZIP_DIR/$xcframework_name.zip"

  [[ -d "$xcframework_path" ]] || die "Missing $platform XCFramework: $xcframework_path"

  printf "Zipping %s\n" "$(basename "$zip_path")"
  zip_xcframework "$xcframework_path" "$zip_path"

  checksum="$(swift package compute-checksum "$zip_path")"
  update_checksum "$target" "$checksum"
done

log "Done"
printf "Zips: %s\n" "$ZIP_DIR"
printf "Updated: %s\n" "$PACKAGE_FILE"
