#!/usr/bin/env sh
# /qompassai/intel/scripts/quickstart.sh
# Qompass AI Intel Quickstart
# Copyright (C) 2025 Qompass AI, All Rights Reserved
######################################################
set -eu
IFS='
'
: "${ONEAPI_ROOT:=$HOME/.local/share/intel/oneapi}"
: "${XDG_BIN_HOME:=$HOME/.local/bin}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
mkdir -p "$ONEAPI_ROOT" "$XDG_BIN_HOME" "$XDG_CONFIG_HOME/intel"
case ":$PATH:" in
*":$XDG_BIN_HOME:"*) ;;
*)
    PATH="$XDG_BIN_HOME:$PATH"
    export PATH
    ;;
esac
OS="unknown"
ARCH="unknown"
PKG=""
case "$(uname -s)" in
Linux*) OS="linux" ;;
Darwin*) OS="macos" ;;
CYGWIN* | MINGW* | MSYS*) OS="windows" ;;
esac
case "$(uname -m)" in
x86_64) ARCH="x86_64" ;;
aarch64) ARCH="aarch64" ;;
riscv64*) ARCH="riscv64" ;;
*) ARCH="$(uname -m)" ;;
esac
echo "==> OS: $OS  ARCH: $ARCH"
for p in pacman dnf apt brew choco; do
    if command -v "$p" >/dev/null; then
        PKG="$p"
        break
    fi
done
download_and_extract() {
    url="$1"
    dest="$2"
    name="$(basename "$url")"
    tmp="$ONEAPI_ROOT/$name"
    printf " → Fetch: %s\n" "$name"
    curl --proto '=https' --tlsv1.2 -fsSL "$url" -o "$tmp"
    mkdir -p "$dest"
    tar -xf "$tmp" -C "$dest"
    rm -f "$tmp"
}
build_from_source() {
    repo="$1"
    install_dir="$2"
    cd "$ONEAPI_ROOT"
    repo_dir="$(basename "$repo" .git)"
    [ -d "$repo_dir" ] && rm -rf "$repo_dir"
    if ! git clone --depth=1 "$repo" "$repo_dir"; then
        return 1
    fi
    cd "$repo_dir"
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$install_dir"
    make -j"$(nproc)"
    make install
}
install_pkg() {
    pkg="$1"
    if [ -n "$PKG" ]; then
        case "$PKG" in
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        dnf) sudo dnf install -y "$pkg" ;;
        apt) sudo apt-get install -y "$pkg" ;;
        brew) brew install "$pkg" ;;
        choco) choco install "$pkg" -y ;;
        esac
    fi
}
build_from_source_or_extract() {
    repo="$1"
    tarurl="$2"
    comp="$3"
    ver="$4"
    comp_dir="$ONEAPI_ROOT/$comp"
    install_dir="$comp_dir/$ver"
    mkdir -p "$install_dir"
    if ! build_from_source "$repo" "$install_dir"; then
        echo "⚠ Git build failed for $repo, trying tarball..."
        if [ -n "$tarurl" ]; then
            download_and_extract "$tarurl" "$install_dir"
        else
            echo "❌ No tarball URL provided for $repo — skipping."
            return 1
        fi
    fi
    ln -sfn "$ver" "$comp_dir/latest"
}
echo "==> Installing core AI/Systems libs into $ONEAPI_ROOT"
build_from_source_or_extract \
    "https://github.com/oneapi-src/oneDNN.git" \
    "https://github.com/oneapi-src/oneDNN/archive/refs/tags/v3.7.2.tar.gz" \
    "dnnl" "2025.0"
build_from_source_or_extract \
    "https://github.com/openvinotoolkit/openvino.git" \
    "https://github.com/openvinotoolkit/openvino/archive/refs/tags/2023.2.tar.gz" \
    "openvino" "2025.0"
build_from_source_or_extract \
    "https://github.com/oneapi-src/oneTBB.git" \
    "https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.12.0.tar.gz" \
    "tbb" "2022.0"
build_from_source_or_extract \
    "https://github.com/OpenImageDenoise/oidn.git" \
    "https://github.com/OpenImageDenoise/oidn/archive/refs/tags/v2.3.3.tar.gz" \
    "openimagedenoise" "2025.0"
build_from_source_or_extract \
    "https://github.com/intel/isa-l.git" \
    "https://github.com/intel/isa-l/archive/refs/tags/v2.31.1.tar.gz" \
    "isa-l" "2.31.1"
build_from_source_or_extract \
    "https://github.com/intel/libvpl.git" \
    "https://github.com/intel/libvpl/archive/refs/tags/v2.15.0.tar.gz" \
    "libvpl" "2.15.0"
build_from_source_or_extract \
    "https://github.com/Intel-Media-SDK/MediaSDK.git" \
    "https://github.com/Intel-Media-SDK/MediaSDK/archive/refs/tags/intel-mediasdk-23.2.2.tar.gz" \
    "libmfx" "23.2.2"
build_from_source_or_extract \
    "https://github.com/oneapi-src/oneMKL.git" \
    "https://github.com/oneapi-src/oneMKL/archive/refs/tags/v2023.2.0.tar.gz" \
    "mkl" "2025.0"
build_from_source_or_extract \
    "https://github.com/OpenPathGuiding/openpgl.git" \
    "https://github.com/OpenPathGuiding/openpgl/archive/refs/tags/v0.7.1.tar.gz" \
    "openpgl" "0.7.1"
build_from_source_or_extract \
    "https://github.com/intel/llvm.git" \
    "" "compiler" "2025.0"
build_from_source_or_extract \
    "https://github.com/intel/gmmlib.git" \
    "" "gmmlib" "22.7.2"
build_from_source_or_extract \
    "https://github.com/intel/media-driver.git" \
    "" "media-driver" "25.2.5"
build_from_source_or_extract \
    "https://gitlab.freedesktop.org/drm/igt-gpu-tools.git" \
    "" "intel-gpu-tools" "2025.0"
build_from_source_or_extract \
    "https://github.com/intel/compute-runtime.git" \
    "" "intel-compute-runtime" "2025.0"
build_from_source_or_extract \
    "https://github.com/intel/openmp.git" \
    "" "openmp" "2025.0"
build_from_source_or_extract \
    "https://gitlab.com/x86-tool/iucode-tool.git" \
    "" "iucode-tool" "2.3.1"
build_from_source_or_extract \
    "https://sourceforge.net/p/openipmi/code/ci/master/tree/" \
    "" "openipmi" "2.0.36"
if command -v python3 >/dev/null 2>&1; then
    echo "==> Installing Python AI/acceleration extensions"
    pip3 install --user onednn openvino openvino-dev intel-extension-for-pytorch intel-extension-for-tensorflow || true
fi
cat >"$XDG_BIN_HOME/oneapi-setvars.sh" <<EOF
#!/usr/bin/env sh
export ONEAPI_ROOT="$ONEAPI_ROOT"
export PATH="\$ONEAPI_ROOT/dnnl/latest/bin:\$ONEAPI_ROOT/tbb/latest/bin:\$ONEAPI_ROOT/mkl/latest/bin:\$PATH"
export LD_LIBRARY_PATH="\$ONEAPI_ROOT/dnnl/latest/lib:\$ONEAPI_ROOT/tbb/latest/lib:\$ONEAPI_ROOT/mkl/latest/lib:\$LD_LIBRARY_PATH"
EOF
chmod +x "$XDG_BIN_HOME/oneapi-setvars.sh"
echo "✅ Intel/oneAPI components installed under $ONEAPI_ROOT"
echo "→ Add $XDG_BIN_HOME to PATH and 'source oneapi-setvars.sh' to configure."
