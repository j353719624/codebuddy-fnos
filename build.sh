#!/usr/bin/env bash
# CodeBuddy fnOS FPK 一键构建脚本
# 自动拉取 @tencent-ai/codebuddy-code 最新版并打包为 fnOS 应用
set -euo pipefail

REGISTRY="${NPM_REGISTRY:-https://registry.npmmirror.com}"
OUT_DIR="${OUT_DIR:-.}"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

echo "==> 拉取 @tencent-ai/codebuddy-code 最新版..."
npm install --prefix "$WORK_DIR/app/lib" --registry "$REGISTRY" @tencent-ai/codebuddy-code@latest

ENGINE_VER=$(node -p "require('$WORK_DIR/app/lib/node_modules/@tencent-ai/codebuddy-code/package.json').version")
echo "==> 引擎版本: $ENGINE_VER"

echo "==> 组装 FPK 树..."
mkdir -p "$WORK_DIR/cmd" "$WORK_DIR/config" "$WORK_DIR/app/bin" "$WORK_DIR/app/ui/images"
cp -a "$WORK_DIR/app/lib/node_modules/@tencent-ai/codebuddy-code" "$WORK_DIR/app/lib/codebuddy"
rm -rf "$WORK_DIR/app/lib/node_modules"
cp cmd/* "$WORK_DIR/cmd/"
cp config/* "$WORK_DIR/config/"
cp app/bin/codebuddy "$WORK_DIR/app/bin/"
cp app/ui/config "$WORK_DIR/app/ui/"
cp app/ui/images/* "$WORK_DIR/app/ui/images/"
cp ICON.PNG ICON_256.PNG "$WORK_DIR/"
sed "s/^version = .*/version = $ENGINE_VER/" manifest > "$WORK_DIR/manifest"

chmod 755 "$WORK_DIR/cmd/"* "$WORK_DIR/app/bin/codebuddy" "$WORK_DIR/app/lib/codebuddy/bin/codebuddy"

echo "==> fnpack 打包..."
cd "$WORK_DIR"
fnpack build --directory .

FPK_NAME="codebuddy-$ENGINE_VER.fpk"
cp codebuddy.fpk "$OUT_DIR/$FPK_NAME"
echo "==> 完成: $OUT_DIR/$FPK_NAME"
