#!/usr/bin/env bash

set -e
GLAD_GEN="${1:-c}"

pushd glad
python -m glad --generator=${GLAD_GEN} --extensions=GL_EXT_framebuffer_multisample,GL_EXT_texture_filter_anisotropic,GL_EXT_texture_snorm,GL_NV_texture_barrier --local-files --out-path=.
popd
cp glad/*.h src/
cp glad/glad.c src/
