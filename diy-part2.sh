#!/bin/bash
set -e

PKG_DIR="package/custom"
mkdir -p "$PKG_DIR"

echo "=== 拉取 luci-app-airoha-npu ==="
rm -rf "$PKG_DIR/luci-app-airoha-npu"
git clone --depth 1 -b main \
  https://github.com/luanmuc/luci-app-airoha-npu \
  "$PKG_DIR/luci-app-airoha-npu"

# 包结构校验：Makefile 必须在根目录，否则 buildroot 扫不到
[ -f "$PKG_DIR/luci-app-airoha-npu/Makefile" ] || {
  echo "::error::luci-app-airoha-npu/Makefile 不存在，包无法被索引"; exit 1
}

# po 改名：luci.mk 按 LUCI_BASENAME(=airoha-npu) 找 lmo，不改中文不生效
PODIR="$PKG_DIR/luci-app-airoha-npu/po"
[ -f "$PODIR/zh_Hans/luci-app-airoha-npu.po" ] && \
  mv "$PODIR/zh_Hans/luci-app-airoha-npu.po" "$PODIR/zh_Hans/airoha-npu.po"
[ -f "$PODIR/es/luci-app-airoha-npu.po" ] && \
  mv "$PODIR/es/luci-app-airoha-npu.po" "$PODIR/es/airoha-npu.po"

echo "=== 强制重建包索引 ==="
# 只删 .packageinfo 不够，scan stamp 会拿 mtime 跳过扫描，必须一起删
rm -f tmp/.packageinfo tmp/.targetinfo
rm -f tmp/info/.scan-packageinfo.stamp tmp/info/.scan-targetinfo.stamp
rm -f tmp/info/.files* 2>/dev/null || true
rm -f tmp/.config-package.in tmp/.config-target.in
find "$PKG_DIR" -type f -exec touch {} + 2>/dev/null || true

make prepare-tmpinfo OPENWRT_BUILD= V=s

echo "=== 索引硬校验 ==="
grep -qx "Package: luci-app-airoha-npu" tmp/.packageinfo || {
  echo "::error::luci-app-airoha-npu 未进入 tmp/.packageinfo，defconfig 会静默剔除该包"
  ls -la "$PKG_DIR/luci-app-airoha-npu/"
  exit 1
}
echo "✅ luci-app-airoha-npu 已进索引"
