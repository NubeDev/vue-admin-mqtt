#pragma glslify: export(computePosition)
vec4 computePosition(vec2 posHi, vec2 posLo, vec2 scHi, vec2 scLo, vec2 trHi, vec2 trLo, vec2 screenScale, vec2 screenOffset) {
  return vec4((posHi + trHi) * scHi
            + (posLo + trLo) * scHi
            + (posHi + trHi) * scLo
            + (posLo + trLo) * scLo
            + screenScale * screenOffset, 0, 1);
}