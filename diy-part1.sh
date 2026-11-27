#!/bin/bash
# diy-part1.sh —— 仅拉取 luci-app-airoha-npu（含中文翻译）
set -e

PKG_DIR="package/custom"
mkdir -p "$PKG_DIR"

echo "=== 拉取 luci-app-airoha-npu ==="

# 已存在则跳过
if [ ! -d "$PKG_DIR/luci-app-airoha-npu" ]; then
    git clone --depth 1 -b main \
        https://github.com/luanmuc/luci-app-airoha-npu \
        "$PKG_DIR/luci-app-airoha-npu"
fi

# po 改名：luci.mk 按 LUCI_BASENAME(=airoha-npu) 查找，必须叫 airoha-npu.po
PODIR="$PKG_DIR/luci-app-airoha-npu/po"
if [ -f "$PODIR/zh_Hans/luci-app-airoha-npu.po" ]; then
    mv "$PODIR/zh_Hans/luci-app-airoha-npu.po" "$PODIR/zh_Hans/airoha-npu.po"
    echo "✅ po 已改名: airoha-npu.po"
fi

# 强制重建索引
rm -f tmp/.packageinfo tmp/.targetinfo
rm -f tmp/info/.scan-packageinfo.stamp tmp/info/.scan-targetinfo.stamp
rm -f tmp/info/.files* 2>/dev/null
find "$PKG_DIR" -type f -exec touch {} + 2>/dev/null || true

make prepare-tmpinfo OPENWRT_BUILD= V=s 2>&1 | tail -20

echo "🎉 完成：luci-app-airoha-npu 已就绪"
