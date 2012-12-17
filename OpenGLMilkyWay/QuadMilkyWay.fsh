uniform sampler2D Sampler;
uniform highp float Opacity;

varying lowp vec2 outTextureCoord;

void main(){
	gl_FragColor = texture2D(Sampler, outTextureCoord)*Opacity;
}