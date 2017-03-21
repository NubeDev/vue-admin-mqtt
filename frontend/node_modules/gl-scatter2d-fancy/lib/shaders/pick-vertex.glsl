precision highp float;

attribute vec2 positionHi, positionLo;
attribute vec2 offset;
attribute vec4 id;

uniform vec2 scaleHi, scaleLo, translateHi, translateLo, pixelScale;
uniform vec4 pickOffset;

varying vec4 fragColor;

#pragma glslify: computePosition = require("./xform.glsl")

void main() {
  vec4 fragId = id + pickOffset;

  fragId.y += floor(fragId.x / 256.0);
  fragId.x -= floor(fragId.x / 256.0) * 256.0;

  fragId.z += floor(fragId.y / 256.0);
  fragId.y -= floor(fragId.y / 256.0) * 256.0;

  fragId.w += floor(fragId.z / 256.0);
  fragId.z -= floor(fragId.z / 256.0) * 256.0;

  fragColor = fragId / 255.0;

  gl_Position = computePosition(
    positionHi, positionLo,
    scaleHi, scaleLo,
    translateHi, translateLo,
    pixelScale, offset);
}
