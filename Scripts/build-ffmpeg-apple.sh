#!/usr/bin/env bash

set -euo pipefail

INVOCATION_DIR="$(pwd -P)"

FFMPEG_VERSION="${FFMPEG_VERSION:-}"
DEFAULT_PLATFORMS="macos-arm64,macos-x86_64"
ALL_PLATFORMS="macos-arm64,macos-x86_64,ios-arm64,ios-simulator-arm64,ios-simulator-x86_64,tvos-arm64,tvos-simulator-arm64,tvos-simulator-x86_64,watchos-arm64,watchos-simulator-arm64,watchos-simulator-x86_64,visionos-arm64,visionos-simulator-arm64,visionos-simulator-x86_64"
PLATFORMS="${PLATFORMS:-$DEFAULT_PLATFORMS}"
LIBRARIES="${LIBRARIES:-libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale}"
PLATFORM_PACKAGING="${PLATFORM_PACKAGING:-combined}"
LIBRARY_PACKAGING="${LIBRARY_PACKAGING:-combined}"
LINKAGE="${LINKAGE:-static}"
PACKAGE_XCFRAMEWORK="${PACKAGE_XCFRAMEWORK:-}"
EXPLICIT_LINKAGE=false
VERBOSE="${VERBOSE:-false}"

MACOS_DEPLOYMENT_TARGET="${MACOS_DEPLOYMENT_TARGET:-11.0}"
IOS_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET:-13.0}"
TVOS_DEPLOYMENT_TARGET="${TVOS_DEPLOYMENT_TARGET:-13.0}"
WATCHOS_DEPLOYMENT_TARGET="${WATCHOS_DEPLOYMENT_TARGET:-7.0}"
VISIONOS_DEPLOYMENT_TARGET="${VISIONOS_DEPLOYMENT_TARGET:-1.0}"

BUILD_DIR="${BUILD_DIR:-}"
OUTPUT_DIR="${OUTPUT_DIR:-}"
FFMPEG_SOURCE_DIR="${FFMPEG_SOURCE_DIR:-}"
SOURCE_DIR=""
SOURCE_ARCHIVE=""
PREFIX_DIR=""
COMBINED_DIR=""
HEADERS_DIR=""

JOBS="${JOBS:-$(sysctl -n hw.ncpu 2>/dev/null || echo 8)}"

usage() {
  local bold="" reset=""
  if [[ -t 1 ]] && command -v tput >/dev/null; then
    bold="$(tput bold 2>/dev/null || true)"
    reset="$(tput sgr0 2>/dev/null || true)"
  fi

  cat <<EOF
Build FFmpeg for Apple platforms from an FFmpeg source checkout.

${bold}Usage:${reset}
  $(basename "$0") [platform flags]

${bold}Default Flags:${reset}
  -macOS -static -xcframework

${bold}Platform Options:${reset}
  -macOS                Build macOS device slices: arm64 + x86_64.
  -iOS                  Build iOS device + simulator slices.
  -tvOS                 Build tvOS device + simulator slices.
  -watchOS              Build watchOS device + simulator slices.
  -visionOS             Build visionOS device + simulator slices.
  -all                  Build every supported Apple platform above.

${bold}Library Build Options:${reset}
  -static               Build static libraries. If -xcframework is omitted,
                         raw libraries are copied to the output folder.
  -dynamic              Build dynamic libraries. If -xcframework is omitted,
                         raw libraries are copied to the output folder.
  -xcframework          Package the selected library output as XCFrameworks.
  --separate-platforms  Create one artifact per FFmpeg library and platform
                         family, such as Libavutil-macOS.xcframework and
                         Libavutil-iOS.xcframework.
  --separate-ffmpeg-libraries
                         Create one library output per FFmpeg sub-library.
                         By default, FFmpeg sub-libraries are merged into one
                         static archive per platform variant.

${bold}General Options:${reset}
  -f, --ffmpeg PATH     FFmpeg source checkout to build.
  -v, --verbose         Print FFmpeg configure and build output.
  -h, --help            Show this help.

If no FFmpeg source checkout is found or specified, the latest FFmpeg release
archive is temporarily downloaded and extracted to the build folder's source
directory.
EOF
}

log() {
  printf "\n==> %s\n" "$*"
}

die() {
  printf "error: %s\n" "$*" >&2
  exit 1
}

is_ffmpeg_source_dir() {
  local directory="$1"
  [[ -f "$directory/configure" ]] &&
    [[ -d "$directory/libavutil" ]] &&
    [[ -d "$directory/libavcodec" ]] &&
    [[ -d "$directory/libavformat" ]]
}

resolve_source_dir() {
  if [[ -n "$FFMPEG_SOURCE_DIR" ]]; then
    SOURCE_DIR="$(cd "$FFMPEG_SOURCE_DIR" && pwd)"
    is_ffmpeg_source_dir "$SOURCE_DIR" || die "FFMPEG_SOURCE_DIR is not an FFmpeg source checkout: $SOURCE_DIR"
    return
  fi

  if is_ffmpeg_source_dir "$INVOCATION_DIR"; then
    SOURCE_DIR="$INVOCATION_DIR"
    return
  fi
}

version_from_source_dir() {
  local directory="$1"
  local release_file="$directory/RELEASE"

  if [[ -f "$release_file" ]]; then
    sed -n '1 { s/^n//; p; }' "$release_file"
    return
  fi

  git -C "$directory" describe --tags --exact-match 2>/dev/null | sed 's/^n//' || true
}

cached_source_dir() {
  local candidate
  local candidates=()

  if [[ -n "$BUILD_DIR" ]]; then
    candidates+=("$BUILD_DIR"/source)
    candidates+=("$BUILD_DIR"/ffmpeg-*)
    candidates+=("$BUILD_DIR"/FFmpeg-*/source)
    candidates+=("$BUILD_DIR"/FFmpeg-*/ffmpeg-*)
  else
    candidates+=("$INVOCATION_DIR/Build"/FFmpeg-*/source)
    candidates+=("$INVOCATION_DIR/Build"/FFmpeg-*/ffmpeg-*)
  fi

  for candidate in "${candidates[@]}"; do
    [[ -d "$candidate" ]] || continue
    is_ffmpeg_source_dir "$candidate" || continue
    printf "%s\n" "$candidate"
  done | sort -V | tail -n 1
}

resolve_version_and_paths() {
  local latest_release release_version

  if [[ -z "$SOURCE_DIR" ]]; then
    SOURCE_DIR="$(cached_source_dir)"
  fi

  if [[ -n "$SOURCE_DIR" ]]; then
    if [[ -z "$FFMPEG_VERSION" ]]; then
      FFMPEG_VERSION="$(version_from_source_dir "$SOURCE_DIR")"
      FFMPEG_VERSION="${FFMPEG_VERSION:-source}"
    fi
    if [[ -z "$BUILD_DIR" && "$SOURCE_DIR" == "$INVOCATION_DIR/Build"/FFmpeg-*"/source" ]]; then
      BUILD_DIR="$(dirname "$SOURCE_DIR")"
    elif [[ -z "$BUILD_DIR" && "$SOURCE_DIR" == "$INVOCATION_DIR/Build"/FFmpeg-*"/ffmpeg-"* ]]; then
      BUILD_DIR="$(dirname "$SOURCE_DIR")"
    fi
  else
    latest_release="$(latest_ffmpeg_release)"
    release_version="${latest_release#ffmpeg-}"
    release_version="${release_version%.tar.xz}"
    FFMPEG_VERSION="${FFMPEG_VERSION:-$release_version}"
    BUILD_DIR="${BUILD_DIR:-$INVOCATION_DIR/Build/FFmpeg-$FFMPEG_VERSION}"
    SOURCE_ARCHIVE="$BUILD_DIR/$latest_release"
    SOURCE_DIR="$BUILD_DIR/source"
  fi

  BUILD_DIR="${BUILD_DIR:-$INVOCATION_DIR/Build/FFmpeg-$FFMPEG_VERSION}"
  OUTPUT_DIR="${OUTPUT_DIR:-$INVOCATION_DIR/Artifacts/FFmpeg-$FFMPEG_VERSION}"
  PREFIX_DIR="$BUILD_DIR/$LINKAGE/prefixes"
  COMBINED_DIR="$BUILD_DIR/$LINKAGE/combined"
  HEADERS_DIR="$BUILD_DIR/$LINKAGE/headers"
}

latest_ffmpeg_release() {
  local latest_release

  command -v curl >/dev/null || die "curl not found"
  latest_release=$(curl -s https://ffmpeg.org/download.html | grep -oE 'ffmpeg-[0-9]+\.[0-9]+(\.[0-9]+)?\.tar\.xz' | head -n 1)
  [[ -n "$latest_release" ]] || die "Could not determine latest FFmpeg release"

  printf "%s" "$latest_release"
}

validate_options() {
  case "$LINKAGE" in
    static|dynamic) ;;
    *) die "Unsupported LINKAGE '$LINKAGE'. Use 'static' or 'dynamic'." ;;
  esac

  case "$PACKAGE_XCFRAMEWORK" in
    true|false) ;;
    *) die "Unsupported PACKAGE_XCFRAMEWORK '$PACKAGE_XCFRAMEWORK'. Use 'true' or 'false'." ;;
  esac

  case "$PLATFORM_PACKAGING" in
    combined|split|separate-all) ;;
    *) die "Unsupported PLATFORM_PACKAGING '$PLATFORM_PACKAGING'. Use 'combined', 'split', or 'separate-all'." ;;
  esac

  case "$LIBRARY_PACKAGING" in
    separate|combined) ;;
    *) die "Unsupported LIBRARY_PACKAGING '$LIBRARY_PACKAGING'. Use 'separate' or 'combined'." ;;
  esac

  if [[ "$LINKAGE" == "dynamic" && "$LIBRARY_PACKAGING" == "combined" ]]; then
    die "Dynamic combined-library output is not supported. Use -dynamic --separate-ffmpeg-libraries, or use -static."
  fi
}

append_platforms() {
  local addition="$1"
  if [[ -z "$SELECTED_PLATFORMS" ]]; then
    SELECTED_PLATFORMS="$addition"
  else
    SELECTED_PLATFORMS="$SELECTED_PLATFORMS,$addition"
  fi
}

parse_arguments() {
  SELECTED_PLATFORMS=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -v|--verbose)
        VERBOSE=true
        ;;
      -macOS|-macos|--macOS|--macos)
        append_platforms "macos-arm64,macos-x86_64"
        ;;
      -macOS_arm64|-macos_arm64|--macOS_arm64|--macos_arm64)
        append_platforms "macos-arm64"
        ;;
      -macOS_x86|-macos_x86|--macOS_x86|--macos_x86|-macOS_x86_64|-macos_x86_64|--macOS_x86_64|--macos_x86_64)
        append_platforms "macos-x86_64"
        ;;
      -iOS|-ios|--iOS|--ios)
        append_platforms "ios-arm64,ios-simulator-arm64,ios-simulator-x86_64"
        ;;
      -iOS_device|-ios_device|--iOS_device|--ios_device)
        append_platforms "ios-arm64"
        ;;
      -iOS_simulator|-ios_simulator|--iOS_simulator|--ios_simulator)
        append_platforms "ios-simulator-arm64,ios-simulator-x86_64"
        ;;
      -tvOS|-tvos|--tvOS|--tvos)
        append_platforms "tvos-arm64,tvos-simulator-arm64,tvos-simulator-x86_64"
        ;;
      -tvOS_device|-tvos_device|--tvOS_device|--tvos_device)
        append_platforms "tvos-arm64"
        ;;
      -tvOS_simulator|-tvos_simulator|--tvOS_simulator|--tvos_simulator)
        append_platforms "tvos-simulator-arm64,tvos-simulator-x86_64"
        ;;
      -watchOS|-watchos|--watchOS|--watchos)
        append_platforms "watchos-arm64,watchos-simulator-arm64,watchos-simulator-x86_64"
        ;;
      -watchOS_device|-watchos_device|--watchOS_device|--watchos_device)
        append_platforms "watchos-arm64"
        ;;
      -watchOS_simulator|-watchos_simulator|--watchOS_simulator|--watchos_simulator)
        append_platforms "watchos-simulator-arm64,watchos-simulator-x86_64"
        ;;
      -visionOS|-visionos|--visionOS|--visionos)
        append_platforms "visionos-arm64,visionos-simulator-arm64,visionos-simulator-x86_64"
        ;;
      -visionOS_device|-visionos_device|--visionOS_device|--visionos_device)
        append_platforms "visionos-arm64"
        ;;
      -visionOS_simulator|-visionos_simulator|--visionOS_simulator|--visionos_simulator)
        append_platforms "visionos-simulator-arm64,visionos-simulator-x86_64"
        ;;
      -all|--all)
        append_platforms "$ALL_PLATFORMS"
        ;;
      -f|--ffmpeg)
        shift
        [[ $# -gt 0 ]] || die "Missing value for --ffmpeg"
        FFMPEG_SOURCE_DIR="$1"
        ;;
      -f=*|--ffmpeg=*)
        FFMPEG_SOURCE_DIR="${1#*=}"
        ;;
      -static|--static)
        LINKAGE="static"
        EXPLICIT_LINKAGE=true
        if [[ -z "$PACKAGE_XCFRAMEWORK" ]]; then
          PACKAGE_XCFRAMEWORK=false
        fi
        ;;
      -dynamic|--dynamic)
        LINKAGE="dynamic"
        EXPLICIT_LINKAGE=true
        if [[ -z "$PACKAGE_XCFRAMEWORK" ]]; then
          PACKAGE_XCFRAMEWORK=false
        fi
        ;;
      -xcframework|--xcframework)
        PACKAGE_XCFRAMEWORK=true
        ;;
      --separate-platforms)
        PLATFORM_PACKAGING="split"
        ;;
      --separate-all-platforms)
        PLATFORM_PACKAGING="separate-all"
        ;;
      --separate-ffmpeg-libraries)
        LIBRARY_PACKAGING="separate"
        ;;
      -*)
        die "Unknown argument '$1'. Run $(basename "$0") --help for usage."
        ;;
      *)
        if [[ -n "$FFMPEG_SOURCE_DIR" ]]; then
          die "Multiple FFmpeg source paths provided: '$FFMPEG_SOURCE_DIR' and '$1'"
        fi
        FFMPEG_SOURCE_DIR="$1"
        ;;
    esac
    shift
  done

  if [[ -n "$SELECTED_PLATFORMS" ]]; then
    PLATFORMS="$SELECTED_PLATFORMS"
  fi

  if [[ -z "$PACKAGE_XCFRAMEWORK" ]]; then
    PACKAGE_XCFRAMEWORK=true
  fi
}

module_name_for_library() {
  local library="$1"
  case "$library" in
    libavcodec) echo "Libavcodec" ;;
    libavdevice) echo "Libavdevice" ;;
    libavfilter) echo "Libavfilter" ;;
    libavformat) echo "Libavformat" ;;
    libavutil) echo "Libavutil" ;;
    libpostproc) echo "Libpostproc" ;;
    libswresample) echo "Libswresample" ;;
    libswscale) echo "Libswscale" ;;
    *) die "Unsupported library '$library'" ;;
  esac
}

sdk_for_platform() {
  local platform="$1"
  case "$platform" in
    macos) echo "macosx" ;;
    ios) echo "iphoneos" ;;
    ios-simulator) echo "iphonesimulator" ;;
    tvos) echo "appletvos" ;;
    tvos-simulator) echo "appletvsimulator" ;;
    watchos) echo "watchos" ;;
    watchos-simulator) echo "watchsimulator" ;;
    visionos) echo "xros" ;;
    visionos-simulator) echo "xrsimulator" ;;
    *) die "Unsupported platform '$platform'" ;;
  esac
}

min_version_flag_for_platform() {
  local platform="$1"
  case "$platform" in
    macos) echo "-mmacosx-version-min=$MACOS_DEPLOYMENT_TARGET" ;;
    ios) echo "-miphoneos-version-min=$IOS_DEPLOYMENT_TARGET" ;;
    ios-simulator) echo "-mios-simulator-version-min=$IOS_DEPLOYMENT_TARGET" ;;
    tvos) echo "-mtvos-version-min=$TVOS_DEPLOYMENT_TARGET" ;;
    tvos-simulator) echo "-mtvos-simulator-version-min=$TVOS_DEPLOYMENT_TARGET" ;;
    watchos) echo "-mwatchos-version-min=$WATCHOS_DEPLOYMENT_TARGET" ;;
    watchos-simulator) echo "-mwatchsimulator-version-min=$WATCHOS_DEPLOYMENT_TARGET" ;;
    visionos) echo "-mtargetos=xros$VISIONOS_DEPLOYMENT_TARGET" ;;
    visionos-simulator) echo "-mtargetos=xros$VISIONOS_DEPLOYMENT_TARGET-simulator" ;;
    *) die "Unsupported platform '$platform'" ;;
  esac
}

platform_from_slice() {
  local slice="$1"
  case "$slice" in
    macos-*) echo "macos" ;;
    ios-simulator-*) echo "ios-simulator" ;;
    ios-*) echo "ios" ;;
    tvos-simulator-*) echo "tvos-simulator" ;;
    tvos-*) echo "tvos" ;;
    watchos-simulator-*) echo "watchos-simulator" ;;
    watchos-*) echo "watchos" ;;
    visionos-simulator-*) echo "visionos-simulator" ;;
    visionos-*) echo "visionos" ;;
    *) die "Unsupported platform slice '$slice'" ;;
  esac
}

arch_from_slice() {
  local slice="$1"
  case "$slice" in
    *-arm64) echo "arm64" ;;
    *-x86_64) echo "x86_64" ;;
    *-arm64_32) echo "arm64_32" ;;
    *) die "Unsupported architecture in slice '$slice'" ;;
  esac
}

platform_display_name() {
  local platform="$1"
  case "$platform" in
    macos) echo "macOS" ;;
    ios) echo "iOS" ;;
    ios-simulator) echo "iOS" ;;
    tvos) echo "tvOS" ;;
    tvos-simulator) echo "tvOS" ;;
    watchos) echo "watchOS" ;;
    watchos-simulator) echo "watchOS" ;;
    visionos) echo "visionOS" ;;
    visionos-simulator) echo "visionOS" ;;
    *) die "Unsupported platform '$platform'" ;;
  esac
}

slice_display_name() {
  local slice="$1"
  local platform arch name

  platform="$(platform_from_slice "$slice")"
  arch="$(arch_from_slice "$slice")"
  name="$(platform_display_name "$platform")"

  case "$platform" in
    macos) printf "%s (%s)" "$name" "$arch" ;;
    *-simulator) printf "%s (simulator)" "$name" ;;
    *) printf "%s (device)" "$name" ;;
  esac
}

ffmpeg_arch_from_slice() {
  local slice="$1"
  case "$(arch_from_slice "$slice")" in
    arm64|arm64_32) echo "arm64" ;;
    x86_64) echo "x86_64" ;;
    *) die "Unsupported FFmpeg architecture in slice '$slice'" ;;
  esac
}

xcframework_identifier_for_group() {
  local group="$1"
  case "$group" in
    macos) echo "macos-arm64_x86_64" ;;
    macos-arm64) echo "macos-arm64" ;;
    macos-x86_64) echo "macos-x86_64" ;;
    ios) echo "ios-arm64" ;;
    ios-simulator) echo "ios-arm64_x86_64-simulator" ;;
    ios-arm64) echo "ios-arm64" ;;
    ios-simulator-arm64) echo "ios-arm64-simulator" ;;
    ios-simulator-x86_64) echo "ios-x86_64-simulator" ;;
    tvos) echo "tvos-arm64" ;;
    tvos-simulator) echo "tvos-arm64_x86_64-simulator" ;;
    tvos-arm64) echo "tvos-arm64" ;;
    tvos-simulator-arm64) echo "tvos-arm64-simulator" ;;
    tvos-simulator-x86_64) echo "tvos-x86_64-simulator" ;;
    watchos) echo "watchos-arm64" ;;
    watchos-simulator) echo "watchos-arm64_x86_64-simulator" ;;
    watchos-arm64) echo "watchos-arm64" ;;
    watchos-simulator-arm64) echo "watchos-arm64-simulator" ;;
    watchos-simulator-x86_64) echo "watchos-x86_64-simulator" ;;
    visionos) echo "xros-arm64" ;;
    visionos-simulator) echo "xros-arm64_x86_64-simulator" ;;
    visionos-arm64) echo "xros-arm64" ;;
    visionos-simulator-arm64) echo "xros-arm64-simulator" ;;
    visionos-simulator-x86_64) echo "xros-x86_64-simulator" ;;
    *) die "Unsupported group '$group'" ;;
  esac
}

group_for_slice() {
  if [[ "$PLATFORM_PACKAGING" == "separate-all" ]]; then
    echo "$1"
    return
  fi

  platform_from_slice "$1"
}

family_for_group() {
  local group="$1"
  case "$group" in
    macos) echo "macos" ;;
    ios|ios-simulator) echo "ios" ;;
    tvos|tvos-simulator) echo "tvos" ;;
    watchos|watchos-simulator) echo "watchos" ;;
    visionos|visionos-simulator) echo "visionos" ;;
    *) die "Unsupported group '$group'" ;;
  esac
}

suffix_for_family() {
  local family="$1"
  case "$family" in
    macos) echo "macOS" ;;
    ios) echo "iOS" ;;
    tvos) echo "tvOS" ;;
    watchos) echo "watchOS" ;;
    visionos) echo "visionOS" ;;
    *) die "Unsupported platform family '$family'" ;;
  esac
}

suffix_for_group() {
  local group="$1"
  case "$group" in
    macos) echo "macOS" ;;
    macos-arm64) echo "macOS-arm64" ;;
    macos-x86_64) echo "macOS-x86_64" ;;
    ios) echo "iOS-device" ;;
    ios-arm64) echo "iOS-device-arm64" ;;
    ios-simulator) echo "iOS-simulator" ;;
    ios-simulator-arm64) echo "iOS-simulator-arm64" ;;
    ios-simulator-x86_64) echo "iOS-simulator-x86_64" ;;
    tvos) echo "tvOS-device" ;;
    tvos-arm64) echo "tvOS-device-arm64" ;;
    tvos-simulator) echo "tvOS-simulator" ;;
    tvos-simulator-arm64) echo "tvOS-simulator-arm64" ;;
    tvos-simulator-x86_64) echo "tvOS-simulator-x86_64" ;;
    watchos) echo "watchOS-device" ;;
    watchos-arm64) echo "watchOS-device-arm64" ;;
    watchos-simulator) echo "watchOS-simulator" ;;
    watchos-simulator-arm64) echo "watchOS-simulator-arm64" ;;
    watchos-simulator-x86_64) echo "watchOS-simulator-x86_64" ;;
    visionos) echo "visionOS-device" ;;
    visionos-arm64) echo "visionOS-device-arm64" ;;
    visionos-simulator) echo "visionOS-simulator" ;;
    visionos-simulator-arm64) echo "visionOS-simulator-arm64" ;;
    visionos-simulator-x86_64) echo "visionOS-simulator-x86_64" ;;
    *) die "Unsupported group '$group'" ;;
  esac
}

prepare_source() {
  local extracted_source_dir

  if is_ffmpeg_source_dir "$SOURCE_DIR"; then
    log "Using FFmpeg source at $SOURCE_DIR"
    return
  fi

  if [[ -z "$SOURCE_ARCHIVE" ]]; then
    die "Not an FFmpeg source checkout: $SOURCE_DIR"
  fi

  mkdir -p "$BUILD_DIR"

  if [[ ! -f "$SOURCE_ARCHIVE" ]]; then
    log "Downloading $(basename "$SOURCE_ARCHIVE")"
    curl -L "https://ffmpeg.org/releases/$(basename "$SOURCE_ARCHIVE")" -o "$SOURCE_ARCHIVE"
  fi

  if [[ -e "$SOURCE_DIR" ]]; then
    die "Source path exists but is not an FFmpeg source checkout: $SOURCE_DIR"
  fi

  log "Extracting $(basename "$SOURCE_ARCHIVE")"
  tar -xJf "$SOURCE_ARCHIVE" -C "$BUILD_DIR"

  extracted_source_dir="$BUILD_DIR/${SOURCE_ARCHIVE##*/}"
  extracted_source_dir="${extracted_source_dir%.tar.xz}"
  is_ffmpeg_source_dir "$extracted_source_dir" || die "Downloaded archive did not extract to an FFmpeg source checkout: $extracted_source_dir"

  log "Moving FFmpeg source to $SOURCE_DIR"
  mv "$extracted_source_dir" "$SOURCE_DIR"

  is_ffmpeg_source_dir "$SOURCE_DIR" || die "Downloaded archive did not extract to an FFmpeg source checkout: $SOURCE_DIR"
  rm -f "$SOURCE_ARCHIVE"
  log "Using FFmpeg source at $SOURCE_DIR"
}

configure_common_args() {
  cat <<EOF
--disable-programs
--disable-doc
--disable-debug
--enable-pic
--disable-autodetect
--disable-x86asm
--enable-avcodec
--enable-avdevice
--enable-avfilter
--enable-avformat
--enable-avutil
--enable-swresample
--enable-swscale
EOF

  if [[ "$LINKAGE" == "static" ]]; then
    cat <<EOF
--disable-shared
--enable-static
EOF
  else
    cat <<EOF
--enable-shared
--disable-static
EOF
  fi
}

library_filename() {
  local library="$1"
  if [[ "$LINKAGE" == "static" ]]; then
    echo "$library.a"
  else
    echo "$library.dylib"
  fi
}

build_slice() {
  local slice="$1"
  local platform arch ffmpeg_arch sdk sdk_path prefix min_flag cc host_cc host_sdk_path log_dir build_log display_name

  platform="$(platform_from_slice "$slice")"
  arch="$(arch_from_slice "$slice")"
  ffmpeg_arch="$(ffmpeg_arch_from_slice "$slice")"
  sdk="$(sdk_for_platform "$platform")"
  sdk_path="$(xcrun --sdk "$sdk" --show-sdk-path)"
  cc="$(xcrun --sdk "$sdk" -find clang)"
  host_cc="$(xcrun --sdk macosx -find clang)"
  host_sdk_path="$(xcrun --sdk macosx --show-sdk-path)"
  prefix="$PREFIX_DIR/$slice"
  min_flag="$(min_version_flag_for_platform "$platform")"
  log_dir="$BUILD_DIR/$LINKAGE/logs"
  build_log="$log_dir/$slice.log"
  display_name="$(slice_display_name "$slice")"

  if [[ -f "$prefix/.complete" ]]; then
    log "Skipping $display_name; already built"
    return
  fi

  log "Building $display_name"
  rm -rf "$prefix"
  mkdir -p "$prefix"
  mkdir -p "$log_dir"

  pushd "$SOURCE_DIR" >/dev/null

  local extra_cflags="-arch $arch -isysroot $sdk_path $min_flag"
  local extra_ldflags="-arch $arch -isysroot $sdk_path $min_flag"
  local configure_args=()

  while IFS= read -r arg; do
    [[ -n "$arg" ]] && configure_args+=("$arg")
  done < <(configure_common_args)

  configure_args+=(
    "--prefix=$prefix"
    "--target-os=darwin"
    "--arch=$ffmpeg_arch"
    "--cc=$cc"
    "--host-cc=$host_cc"
    "--host-cflags=-isysroot $host_sdk_path"
    "--host-ldflags=-isysroot $host_sdk_path"
    "--sysroot=$sdk_path"
    "--extra-cflags=$extra_cflags"
    "--extra-ldflags=$extra_ldflags"
  )

  if [[ "$platform" != "macos" ]]; then
    configure_args+=("--enable-cross-compile")
  fi

  if [[ "$platform" == *"simulator" ]]; then
    configure_args+=("--enable-cross-compile")
  fi

  if [[ "$VERBOSE" == "true" ]]; then
    make distclean || true
    if ! ./configure "${configure_args[@]}"; then
      popd >/dev/null
      die "Failed configuring $slice"
    fi
    if ! make -j "$JOBS"; then
      popd >/dev/null
      die "Failed building $slice"
    fi
    if ! make install; then
      popd >/dev/null
      die "Failed installing $slice"
    fi
  else
    {
      printf "Building FFmpeg n%s for %s\n\n" "$FFMPEG_VERSION" "$slice"
      printf "$ make distclean\n\n"
      make distclean || true
      printf "\n"
      printf "$ ./configure"
      printf " %q" "${configure_args[@]}"
      printf "\n\n"
      ./configure "${configure_args[@]}" &&
        make -j "$JOBS" &&
        make install
    } > "$build_log" 2>&1 || {
      popd >/dev/null
      die "Failed building $slice. See: $build_log"
    }
  fi
  popd >/dev/null

  touch "$prefix/.complete"
}

prepare_headers_for_library() {
  local source_include="$1"
  local library="$2"
  local module_name="$3"
  local destination="$4"
  local include_module_map="${5:-true}"

  rm -rf "$destination"
  mkdir -p "$destination"

  cp -R "$source_include"/. "$destination"/

  if [[ "$include_module_map" != "true" ]]; then
    return
  fi

  cat > "$destination/module.modulemap" <<EOF
module $module_name [system] {
  umbrella "."
  export *
}
EOF
}

combine_group() {
  local group="$1"
  shift
  local slices=("$@")
  local output="$COMBINED_DIR/$(xcframework_identifier_for_group "$group")"

  rm -rf "$output"
  mkdir -p "$output/lib"

  local first_prefix="$PREFIX_DIR/${slices[0]}"
  cp -R "$first_prefix/include" "$output/include"

  for library in $LIBRARIES; do
    local filename
    filename="$(library_filename "$library")"
    local inputs=()
    for slice in "${slices[@]}"; do
      inputs+=("$PREFIX_DIR/$slice/lib/$filename")
    done

    if [[ "${#inputs[@]}" -eq 1 ]]; then
      cp "${inputs[0]}" "$output/lib/$filename"
    else
      lipo -create "${inputs[@]}" -output "$output/lib/$filename"
    fi

    if [[ "$LINKAGE" == "dynamic" ]]; then
      xcrun install_name_tool -id "@rpath/$filename" "$output/lib/$filename" >/dev/null 2>&1 || true
    fi
  done
}

create_xcframework_for_library() {
  local library="$1"
  local module_name="$2"
  local output_name="$3"
  shift 3
  local groups=("$@")
  local output="$OUTPUT_DIR/$output_name.xcframework"
  local args=(-create-xcframework)

  rm -rf "$output"

  for group in "${groups[@]}"; do
    local identifier headers filename
    identifier="$(xcframework_identifier_for_group "$group")"
    filename="$(library_filename "$library")"
    headers="$HEADERS_DIR/$module_name/$identifier"
    prepare_headers_for_library "$COMBINED_DIR/$identifier/include" "$library" "$module_name" "$headers"
    args+=(
      -library "$COMBINED_DIR/$identifier/lib/$filename"
      -headers "$headers"
    )
  done

  log "Creating $output_name.xcframework"
  xcodebuild "${args[@]}" -output "$output"
}

combine_libraries_for_group() {
  local group="$1"
  local identifier output inputs=()

  identifier="$(xcframework_identifier_for_group "$group")"
  output="$COMBINED_DIR/$identifier/lib/libFFmpeg.a"

  for library in $LIBRARIES; do
    inputs+=("$COMBINED_DIR/$identifier/lib/$library.a")
  done

  log "Combining FFmpeg libraries for $identifier"
  xcrun libtool -static -o "$output" "${inputs[@]}"
}

create_xcframework_for_combined_library() {
  local output_name="$1"
  shift
  local groups=("$@")
  local module_name="FFmpeg"
  local output="$OUTPUT_DIR/$output_name.xcframework"
  local args=(-create-xcframework)

  rm -rf "$output"

  for group in "${groups[@]}"; do
    local identifier headers
    identifier="$(xcframework_identifier_for_group "$group")"
    headers="$HEADERS_DIR/$module_name/$identifier"
    prepare_headers_for_library "$COMBINED_DIR/$identifier/include" "libFFmpeg" "$module_name" "$headers" false
    args+=(
      -library "$COMBINED_DIR/$identifier/lib/libFFmpeg.a"
      -headers "$headers"
    )
  done

  log "Creating $output_name.xcframework"
  xcodebuild "${args[@]}" -output "$output"
}

unique_families_for_groups() {
  local families=()
  local group family existing exists

  for group in "$@"; do
    family="$(family_for_group "$group")"
    exists=false
    for existing in ${families+"${families[@]}"}; do
      if [[ "$existing" == "$family" ]]; then
        exists=true
        break
      fi
    done
    [[ "$exists" == false ]] && families+=("$family")
  done

  printf "%s\n" ${families+"${families[@]}"}
}

create_xcframeworks() {
  local groups=("$@")
  local library module_name family suffix

  case "$PLATFORM_PACKAGING" in
    combined|split|separate-all) ;;
    *) die "Unsupported PLATFORM_PACKAGING '$PLATFORM_PACKAGING'. Use 'combined', 'split', or 'separate-all'." ;;
  esac

  case "$LIBRARY_PACKAGING" in
    separate|combined) ;;
    *) die "Unsupported LIBRARY_PACKAGING '$LIBRARY_PACKAGING'. Use 'separate' or 'combined'." ;;
  esac

  local families=()
  if [[ "$PLATFORM_PACKAGING" == "split" ]]; then
    while IFS= read -r family; do
      [[ -n "$family" ]] && families+=("$family")
    done < <(unique_families_for_groups ${groups+"${groups[@]}"})
  fi

  if [[ "$LIBRARY_PACKAGING" == "combined" ]]; then
    for group in ${groups+"${groups[@]}"}; do
      combine_libraries_for_group "$group"
    done

    if [[ "$PLATFORM_PACKAGING" == "combined" ]]; then
      create_xcframework_for_combined_library "FFmpeg" ${groups+"${groups[@]}"}
    elif [[ "$PLATFORM_PACKAGING" == "separate-all" ]]; then
      for group in ${groups+"${groups[@]}"}; do
        suffix="$(suffix_for_group "$group")"
        create_xcframework_for_combined_library "FFmpeg-$suffix" "$group"
      done
    else
      for family in ${families+"${families[@]}"}; do
        local family_groups=()
        for group in ${groups+"${groups[@]}"}; do
          [[ "$(family_for_group "$group")" == "$family" ]] && family_groups+=("$group")
        done
        suffix="$(suffix_for_family "$family")"
        create_xcframework_for_combined_library "FFmpeg-$suffix" ${family_groups+"${family_groups[@]}"}
      done
    fi
    return
  fi

  if [[ "$PLATFORM_PACKAGING" == "combined" ]]; then
    for library in $LIBRARIES; do
      module_name="$(module_name_for_library "$library")"
      create_xcframework_for_library "$library" "$module_name" "$module_name" ${groups+"${groups[@]}"}
    done
  elif [[ "$PLATFORM_PACKAGING" == "separate-all" ]]; then
    for library in $LIBRARIES; do
      module_name="$(module_name_for_library "$library")"
      for group in ${groups+"${groups[@]}"}; do
        suffix="$(suffix_for_group "$group")"
        create_xcframework_for_library "$library" "$module_name" "$module_name-$suffix" "$group"
      done
    done
  else
    for library in $LIBRARIES; do
      module_name="$(module_name_for_library "$library")"
      for family in ${families+"${families[@]}"}; do
        local family_groups=()
        for group in ${groups+"${groups[@]}"}; do
          [[ "$(family_for_group "$group")" == "$family" ]] && family_groups+=("$group")
        done
        suffix="$(suffix_for_family "$family")"
        create_xcframework_for_library "$library" "$module_name" "$module_name-$suffix" ${family_groups+"${family_groups[@]}"}
      done
    done
  fi
}

copy_raw_outputs() {
  local groups=("$@")
  local raw_dir="$OUTPUT_DIR/$LINKAGE"
  local group identifier

  rm -rf "$raw_dir"
  mkdir -p "$raw_dir"

  if [[ "$LIBRARY_PACKAGING" == "combined" ]]; then
    for group in ${groups+"${groups[@]}"}; do
      combine_libraries_for_group "$group"
    done
  fi

  for group in ${groups+"${groups[@]}"}; do
    identifier="$(xcframework_identifier_for_group "$group")"
    mkdir -p "$raw_dir/$identifier"
    cp -R "$COMBINED_DIR/$identifier/include" "$raw_dir/$identifier/include"
    mkdir -p "$raw_dir/$identifier/lib"

    if [[ "$LIBRARY_PACKAGING" == "combined" ]]; then
      cp "$COMBINED_DIR/$identifier/lib/libFFmpeg.a" "$raw_dir/$identifier/lib/libFFmpeg.a"
    else
      local library filename
      for library in $LIBRARIES; do
        filename="$(library_filename "$library")"
        cp "$COMBINED_DIR/$identifier/lib/$filename" "$raw_dir/$identifier/lib/$filename"
      done
    fi
  done
}

normalized_slices() {
  local raw="$1"
  local input=()
  local output=()
  local slice existing exists

  IFS=',' read -r -a input <<< "$raw"
  for slice in "${input[@]}"; do
    [[ -z "$slice" ]] && continue
    exists=false
    for existing in ${output+"${output[@]}"}; do
      if [[ "$existing" == "$slice" ]]; then
        exists=true
        break
      fi
    done
    [[ "$exists" == false ]] && output+=("$slice")
  done

  local IFS=','
  printf "%s" "${output[*]-}"
}

build_summary() {
  local artifact platform_scope library_scope linkage_description

  if [[ "$PACKAGE_XCFRAMEWORK" == "true" ]]; then
    artifact="XCFrameworks"
  else
    artifact="raw libraries"
  fi

  case "$PLATFORM_PACKAGING" in
    combined) platform_scope="for selected platforms" ;;
    split) platform_scope="for each platform" ;;
    separate-all) platform_scope="for each platform slice" ;;
    *) platform_scope="for selected platforms" ;;
  esac

  if [[ "$LIBRARY_PACKAGING" == "combined" ]]; then
    library_scope="one combined"
  else
    library_scope="separate"
  fi

  linkage_description="$LINKAGE FFmpeg"
  printf "Building %s %s using %s %s library." "$artifact" "$platform_scope" "$library_scope" "$linkage_description"
}

append_unique() {
  local value="$1"
  shift
  local existing

  for existing in "$@"; do
    [[ "$existing" == "$value" ]] && return 1
  done

  return 0
}

process_split_platform_xcframeworks() {
  local slices=("$@")
  local families=()
  local slice group family existing

  for slice in "${slices[@]}"; do
    group="$(group_for_slice "$slice")"
    family="$(family_for_group "$group")"
    if append_unique "$family" ${families+"${families[@]}"}; then
      families+=("$family")
    fi
  done

  for family in ${families+"${families[@]}"}; do
    local family_groups=()

    for slice in "${slices[@]}"; do
      group="$(group_for_slice "$slice")"
      [[ "$(family_for_group "$group")" == "$family" ]] || continue
      if append_unique "$group" ${family_groups+"${family_groups[@]}"}; then
        family_groups+=("$group")
      fi
    done

    for group in ${family_groups+"${family_groups[@]}"}; do
      local group_slices=()

      for slice in "${slices[@]}"; do
        [[ "$(group_for_slice "$slice")" == "$group" ]] && group_slices+=("$slice")
      done

      for slice in ${group_slices+"${group_slices[@]}"}; do
        build_slice "$slice"
      done

      combine_group "$group" "${group_slices[@]}"
    done

    create_xcframeworks ${family_groups+"${family_groups[@]}"}
  done
}

main() {
  parse_arguments "$@"
  resolve_source_dir
  resolve_version_and_paths
  validate_options

  command -v xcodebuild >/dev/null || die "xcodebuild not found"
  command -v xcrun >/dev/null || die "xcrun not found"
  command -v lipo >/dev/null || die "lipo not found"
  xcrun -find libtool >/dev/null || die "libtool not found"

  local slices=()
  PLATFORMS="$(normalized_slices "$PLATFORMS")"
  [[ -n "$PLATFORMS" ]] || die "No platforms selected"
  IFS=',' read -r -a slices <<< "$PLATFORMS"

  log "$(build_summary)"
  printf "Slices: %s\n" "$PLATFORMS"

  prepare_source

  rm -rf "$COMBINED_DIR" "$HEADERS_DIR" "$OUTPUT_DIR"
  mkdir -p "$COMBINED_DIR" "$HEADERS_DIR" "$OUTPUT_DIR"

  if [[ "$PACKAGE_XCFRAMEWORK" == "true" && "$PLATFORM_PACKAGING" == "split" ]]; then
    process_split_platform_xcframeworks "${slices[@]}"
    log "Done"
    printf "Artifacts: %s\n" "$OUTPUT_DIR"
    exit 0
  fi

  for slice in "${slices[@]}"; do
    build_slice "$slice"
  done

  local groups=()
  for slice in "${slices[@]}"; do
    local group exists=false
    group="$(group_for_slice "$slice")"
    for existing in ${groups+"${groups[@]}"}; do
      if [[ "$existing" == "$group" ]]; then
        exists=true
        break
      fi
    done
    [[ "$exists" == false ]] && groups+=("$group")
  done

  for group in ${groups+"${groups[@]}"}; do
    local group_slices=()
    for slice in "${slices[@]}"; do
      [[ "$(group_for_slice "$slice")" == "$group" ]] && group_slices+=("$slice")
    done
    combine_group "$group" "${group_slices[@]}"
  done

  if [[ "$PACKAGE_XCFRAMEWORK" == "true" ]]; then
    create_xcframeworks ${groups+"${groups[@]}"}
  else
    copy_raw_outputs ${groups+"${groups[@]}"}
  fi

  log "Done"
  printf "Artifacts: %s\n" "$OUTPUT_DIR"
}

main "$@"
