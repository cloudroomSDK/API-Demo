attribute vec4 vertexIn;
attribute vec2 textureYIn;
attribute vec2 textureUIn;
varying vec2 textureYOut;
varying vec2 textureUOut;
void main() {
  gl_Position = vertexIn;
  textureYOut = textureYIn;
  textureUOut = textureUIn;
}