# /qompassai/intel/flake.nix
# Qompass AI Intel Quickstart Flake
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
{
  description = "Qompass AI Intel Quickstart Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };
  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
        pname = "qompass-intel-oneapi-stack";
        version = "2025.0";
        src = null;
        buildInputs = [ pkgs.cmake pkgs.git pkgs.make pkgs.curl pkgs.python3 ];
        buildPhase = ''
          mkdir -p $out
          export ONEAPI_ROOT=$out/oneapi
          fetch_and_untar() {
            url="$1"
            name="$(basename $url)"
            mkdir -p $ONEAPI_ROOT/$name
            curl -L "$url" | tar -xz -C $ONEAPI_ROOT/$name --strip-components=1
          }
          fetch_and_untar https://github.com/oneapi-src/oneDNN/archive/refs/tags/v3.7.2.tar.gz dnnl
          fetch_and_untar https://github.com/openvinotoolkit/openvino/archive/refs/tags/2023.2.tar.gz openvino
          fetch_and_untar https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.12.0.tar.gz tbb
          fetch_and_untar https://github.com/OpenImageDenoise/oidn/archive/refs/tags/v2.3.3.tar.gz openimagedenoise
          fetch_and_untar https://github.com/intel/isa-l/archive/refs/tags/v2.31.1.tar.gz isa-l
          fetch_and_untar https://github.com/intel/libvpl/archive/refs/tags/v2.15.0.tar.gz libvpl
          fetch_and_untar https://github.com/Intel-Media-SDK/MediaSDK/archive/refs/tags/intel-mediasdk-23.2.2.tar.gz libmfx
          fetch_and_untar https://github.com/oneapi-src/oneMKL/archive/refs/tags/v2023.2.0.tar.gz mkl
          fetch_and_untar https://github.com/OpenPathGuiding/openpgl/archive/refs/tags/v0.7.1.tar.gz openpgl

          git clone --depth=1 https://github.com/intel/llvm.git $ONEAPI_ROOT/compiler
          git clone --depth=1 https://github.com/intel/gmmlib.git $ONEAPI_ROOT/gmmlib
          git clone --depth=1 https://github.com/intel/media-driver.git $ONEAPI_ROOT/media-driver
          git clone --depth=1 https://gitlab.freedesktop.org/drm/igt-gpu-tools.git $ONEAPI_ROOT/intel-gpu-tools
          git clone --depth=1 https://github.com/intel/compute-runtime.git $ONEAPI_ROOT/intel-compute-runtime
          git clone --depth=1 https://github.com/intel/openmp.git $ONEAPI_ROOT/openmp
          git clone --depth=1 https://gitlab.com/x86-tool/iucode-tool.git $ONEAPI_ROOT/iucode-tool
          git clone --depth=1 https://sourceforge.net/p/openipmi/code/ci/master/tree/ $ONEAPI_ROOT/openipmi

          # Optionally, pip install python bindings (they'll go to $HOME but you could vendor them)
          # pip3 install --prefix=$out/python onednn openvino openvino-dev intel-extension-for-pytorch intel-extension-for-tensorflow

          cat >$out/oneapi-setvars.sh <<EOF
          export ONEAPI_ROOT="\$HOME/.local/share/intel/oneapi"
          export PATH="\$ONEAPI_ROOT/dnnl/bin:\$ONEAPI_ROOT/tbb/bin:\$ONEAPI_ROOT/mkl/bin:\$PATH"
          export LD_LIBRARY_PATH="\$ONEAPI_ROOT/dnnl/lib:\$ONEAPI_ROOT/tbb/lib:\$ONEAPI_ROOT/mkl/lib:\$LD_LIBRARY_PATH"
          EOF
        '';

        installPhase = ''
        '';
      };
    };
}
