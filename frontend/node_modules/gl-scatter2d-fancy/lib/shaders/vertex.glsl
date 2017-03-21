precision highp float;

attribute vec2 positionHi, positionLo;
attribute vec2 offset;
attribute vec4 color;

uniform vec2 scaleHi, scaleLo, translateHi, translateLo, pixelScale;

varying vec4 fragColor;

#pragma glslify: computePosition = require("./xform.glsl")

void main() {
  fragColor = color;

  gl_Position = computePosition(
    positionHi, positionLo,
    scaleHi, scaleLo,
    translateHi, translateLo,
    pixelScale, offset);
}
