#!/bin/bash
set -e

PKG_DIR="package/custom"
mkdir -p "$PKG_DIR"

echo "=== 拉取 luci-app-airoha-npu ==="
rm -rf "$PKG_DIR/luci-app-airoha-npu"
git clone --depth 1 -b main \
  https://github.com/luanmuc/luci-app-airoha-npu \
  "$PKG_DIR/luci-app-airoha-npu"

# 包结构校验
[ -f "$PKG_DIR/luci-app-airoha-npu/Makefile" ] || {
  echo "::error::Makefile 不存在"; exit 1
}

# po 改名（中文生效关键）
PODIR="$PKG_DIR/luci-app-airoha-npu/po"
[ -f "$PODIR/zh_Hans/luci-app-airoha-npu.po" ] && \
  mv "$PODIR/zh_Hans/luci-app-airoha-npu.po" "$PODIR/zh_Hans/airoha-npu.po"
[ -f "$PODIR/es/luci-app-airoha-npu.po" ] && \
  mv "$PODIR/es/luci-app-airoha-npu.po" "$PODIR/es/airoha-npu.po"

echo "=== 强制重建包索引 ==="
rm -f tmp/.packageinfo tmp/.targetinfo
rm -f tmp/info/.scan-packageinfo.stamp tmp/info/.scan-targetinfo.stamp
rm -f tmp/.config-package.in tmp/.config-target.in
find "$PKG_DIR" -type f -exec touch {} + 2>/dev/null || true

make prepare-tmpinfo OPENWRT_BUILD= V=s

echo "=== 索引硬校验 ==="
grep -qx "Package: luci-app-airoha-npu" tmp/.packageinfo || {
  echo "::error::未进入索引，defconfig 会剔除该包"; exit 1
}
echo "✅ luci-app-airoha-npu 已进索引"
