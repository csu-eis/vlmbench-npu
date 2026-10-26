#!/usr/bin/env bash
# 一键本地渲染项目主页。
#
# 用法：
#   ./start.sh        安装依赖（如需）并启动本地预览 http://localhost:14001
#   ./start.sh build  安装依赖并构建静态站点到 dist/
#   ./start.sh clean  清理 dist/
#
# 依赖：Node.js 24+（可用 nvm 安装：nvm install 24 && nvm use 24）。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# 预览端口（固定，可用环境变量覆盖）
PORT="${VLMBENCH_PORT:-14001}"

# PDD 内部镜像（node 安装器 / Prisma / Puppeteer）
export N_NODE_MIRROR=https://maven.pdd.net/repository/taobao-nodejs/
export NODEJS_ORG_MIRROR=https://maven.pdd.net/repository/taobao-nodejs/
export PUPPETEER_CHROME_DOWNLOAD_BASE_URL=https://maven.pdd.net/repository/bazel-public/chrome-for-testing

GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { printf "${GREEN}==>${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}警告:${NC} %s\n" "$1"; }
error() { printf "${RED}错误:${NC} %s\n" "$1" >&2; }

# ---- 环境检查 ----
command -v node >/dev/null 2>&1 || { error "未找到 Node.js，请先安装（建议 24+）。"; exit 1; }

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if (( NODE_MAJOR < 24 )); then
  error "Node.js 版本过低（当前 $(node --version)），本模板需要 24+。可用 nvm 切换：nvm install 24 && nvm use 24"
  exit 1
fi

ensure_deps() {
  if [[ ! -x node_modules/.bin/astro ]]; then
    info "首次运行，安装依赖（可能较慢）..."
    npm install
  fi
}

# 结束占用指定 TCP 端口的进程（先 kill 旧进程，再启动新的），供反复重启使用。
free_port() {
  local port="$1" pids
  pids="$(lsof -ti "tcp:${port}" -sTCP:LISTEN 2>/dev/null || true)"
  if [[ -z "$pids" ]]; then
    return 0
  fi
  warn "端口 ${port} 已被占用（PID: ${pids//$'\n'/ }），正在结束占用的进程..."
  kill $pids 2>/dev/null || true
  for _ in 1 2 3 4 5; do
    sleep 0.4
    pids="$(lsof -ti "tcp:${port}" -sTCP:LISTEN 2>/dev/null || true)"
    if [[ -z "$pids" ]]; then
      return 0
    fi
  done
  warn "普通结束未生效，强制结束（kill -9）..."
  kill -9 $pids 2>/dev/null || true
  sleep 0.4
  return 0
}

# ---- 子命令 ----
serve() {
  ensure_deps
  free_port "$PORT"
  info "启动本地预览：http://localhost:${PORT}  （Ctrl+C 停止，保存文件自动热更新）"
  exec npm run dev -- --port "$PORT" --strictPort
}

build() {
  ensure_deps
  info "构建静态站点到 dist/ ..."
  npm run build
  info "完成：dist/"
}

clean() {
  info "清理构建产物 ..."
  rm -rf dist
  info "已清理 dist/"
}

case "${1:-serve}" in
  serve|"") serve ;;
  build)    build ;;
  clean)    clean ;;
  *)
    error "未知命令: $1"
    printf "可用命令: serve | build | clean\n"
    exit 1 ;;
esac
