// In
uniform sampler2D Sampler;
uniform sampler2D SamplerDust;

varying highp vec4 colorVarying;
varying highp float relsize;
varying highp vec2 texCoordOut;

void main(){
	highp float transmission = texture2D(SamplerDust,texCoordOut).a;
	gl_FragColor = vec4(1.,1.,1.,texture2D(Sampler, gl_PointCoord).a*transmission*max(0.,1.-relsize/3.))*colorVarying;
}