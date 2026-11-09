#!/bin/bash
# 构建 fnOS FPK 安装包。产出：codebuddy.fpk
#
# 前置：在 fnOS 本机运行（fnpack 已内置：/usr/local/bin/fnpack）。
# 做两件事：
#   1) 拉取 CodeBuddy Code npm 包填充托管代码目录 app/lib/codebuddy
#      （多镜像容错：npmmirror -> npmjs）
#   2) fnpack build 打包
#
# 环境变量：
#   CBC_VERSION   指定版本（默认 latest）
set -e
cd "$(dirname "$0")"

VERSION="${CBC_VERSION:-latest}"
REGISTRY="${CBC_REGISTRY:-https://registry.npmmirror.com}"
LIB=app/lib/codebuddy

if [ -f "${LIB}/package.json" ]; then
    echo "app/lib/codebuddy 已存在，跳过拉取（删除该目录可强制重新拉取）"
else
    mkdir -p "${LIB}"
    if [ "${VERSION}" = "latest" ]; then
        VER=$(curl -sSf --retry 3 "${REGISTRY}/@tencent-ai/codebuddy-code/latest" | grep -oE '"version":"[^"]+"' | head -1 | cut -d'"' -f4)
    else
        VER="${VERSION}"
    fi
    [ -n "${VER}" ] || { echo "获取版本号失败" >&2; exit 1; }
    echo "拉取 @tencent-ai/codebuddy-code@${VER} ..."
    curl -sSfL --retry 3 -o /tmp/cbc.tgz "${REGISTRY}/@tencent-ai/codebuddy-code/-/codebuddy-code-${VER}.tgz"
    tar xzf /tmp/cbc.tgz -C /tmp
    rm -rf "${LIB}"
    mv /tmp/package "${LIB}"
    rm -f /tmp/cbc.tgz
fi

chmod 755 app/bin/codebuddy cmd/*
chmod 755 "${LIB}/bin/codebuddy" 2>/dev/null || true

command -v fnpack >/dev/null 2>&1 || { echo "fnpack 不存在：请在本机（fnOS）运行，或安装 fnpack（https://developer.fnnas.com/）" >&2; exit 1; }
fnpack build --directory .
echo "产出：$(pwd)/codebuddy.fpk"
