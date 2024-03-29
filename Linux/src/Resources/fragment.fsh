// The fragment shader.
// Do YUV to RGB32 conversion.
#ifdef GL_ES
// Set default precision to medium
precision mediump float;
#endif
varying vec2 textureYOut;
varying vec2 textureUOut;
uniform sampler2D tex_y;
uniform sampler2D tex_u;
uniform sampler2D tex_v;
void main(void)
{
    vec3 yuv;
    vec3 rgb;
    yuv.x = texture2D(tex_y, textureYOut).r - 0.062745;
    yuv.y = texture2D(tex_u, textureUOut).r - 0.501960;
    yuv.z = texture2D(tex_v, textureUOut).r - 0.501960;
	//BT.601
    rgb = mat3( 1.164383, 1.164383, 1.164383,
				0.000000, -0.391762, 2.017232,
				1.596027, -0.812968, 0.000000) * yuv;
	//BT.709
    //rgb = mat3( 1.000000, 1.000000, 1.000000,
	//			-0.000000, -0.187324, 1.855600,
	//			1.574800, -0.468124, -0.000000) * yuv;		
    gl_FragColor = vec4(rgb, 1);
}
