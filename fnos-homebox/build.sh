#!/bin/bash
# ============================================================
# Homebox fnOS 原生应用（非 Docker）一键打包脚本
# 用法： ./build.sh           # 打包全部架构
#        ./build.sh x86_64    # 只打包指定架构（x86_64 / x86_64-musl / aarch64）
# 产物输出到 dist/
# ============================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_DIR="$REPO_ROOT/package"
DIST_DIR="$REPO_ROOT/dist"
TOOLS_DIR="$REPO_ROOT/tools"
CACHE_DIR="$REPO_ROOT/cache"

HOMEBOX_VERSION="0.1.3"          # 上游 homebox Release 版本
FNOS_MIN_VER="0.9.0"             # 最低飞牛系统版本
FNPACK_VER="1.2.3"

UPSTREAM_RELEASE="https://github.com/XGHeaven/homebox/releases/download/v${HOMEBOX_VERSION}"
FNPACK_URL="https://static2.fnnas.com/fnpack/fnpack-${FNPACK_VER}-linux-amd64"

# 各架构：目录名 | 平台值 | 上游二进制文件名 | fnpack 平台工具
declare -A ARCHS=(
  [x86_64]="x86|homebox-linux-amd64.tar.gz|linux-amd64"
  [x86_64-musl]="x86|homebox-linux-amd64-musl.tar.gz|linux-amd64"
  [aarch64]="arm|homebox-linux-arm64.tar.gz|linux-arm64"
)

need() { command -v "$1" >/dev/null 2>&1 || { echo "缺少依赖: $1"; exit 1; }; }
need curl; need tar; need gzip

mkdir -p "$DIST_DIR" "$TOOLS_DIR" "$CACHE_DIR"

# ---- 1. 准备 fnpack ----
FNPACK_BIN="$TOOLS_DIR/fnpack-${FNPACK_VER}-linux-amd64"
if [ ! -x "$FNPACK_BIN" ]; then
  echo "[*] 下载 fnpack ${FNPACK_VER} ..."
  curl -fsSL -o "$FNPACK_BIN" "$FNPACK_URL"
  chmod +x "$FNPACK_BIN"
fi

# ---- 2. 准备 homebox 二进制缓存 ----
fetch_bin() {
  local tarball="$1" out="$2"
  if [ ! -f "$out" ]; then
    echo "[*] 下载 ${tarball} ..."
    local tmp="$CACHE_DIR/$tarball"
    curl -fsSL -o "$tmp" "$UPSTREAM_RELEASE/$tarball"
    # 解压到独立子目录，避免与目标缓存路径冲突
    local extract_dir="$CACHE_DIR/_extract_${arch}"
    rm -rf "$extract_dir" && mkdir -p "$extract_dir"
    tar xzf "$tmp" -C "$extract_dir"
    mv -f "$extract_dir/$(basename "$tarball" .tar.gz)" "$out"
    rm -rf "$extract_dir" "$tmp"
  fi
}

build_arch() {
  local arch="$1" platform bin_src
  IFS='|' read -r platform bin_src _ <<< "${ARCHS[$arch]}"
  local build_dir="$REPO_ROOT/build/$arch"
  local bin_cache="$CACHE_DIR/homebox-${arch}"

  echo ""
  echo "==================== 打包 $arch (platform=$platform) ===================="
  fetch_bin "$bin_src" "$bin_cache"

  rm -rf "$build_dir"
  mkdir -p "$build_dir/app"
  cp -r "$PACKAGE_DIR/cmd" "$PACKAGE_DIR/config" "$PACKAGE_DIR/wizard" "$build_dir/"
  cp "$PACKAGE_DIR/manifest" "$PACKAGE_DIR/ICON.PNG" "$PACKAGE_DIR/ICON_256.PNG" "$build_dir/"
  cp -r "$PACKAGE_DIR/app/ui" "$build_dir/app/ui"
  cp "$bin_cache" "$build_dir/app/homebox"
  chmod 755 "$build_dir/app/homebox"

  # 设置架构字段
  sed -i "s/^platform=.*/platform=$platform/" "$build_dir/manifest"

  # 用官方 fnpack 打包
  (cd "$build_dir" && "$FNPACK_BIN" build >/dev/null)

  # 输出到 dist/
  local out="$DIST_DIR/homebox-1.0.0-${arch}.fpk"
  mv -f "$build_dir/homebox.fpk" "$out"
  echo "[✓] 生成 $out"
}

if [ $# -eq 0 ]; then
  for arch in x86_64 x86_64-musl aarch64; do build_arch "$arch"; done
else
  build_arch "$1"
fi

echo ""
echo "全部完成，产物如下："
ls -l "$DIST_DIR"
