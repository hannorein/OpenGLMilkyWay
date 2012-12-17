// In
uniform sampler2D SamplerDust;

varying highp vec3 texCoordStart;
varying highp vec3 texCoordStop;
varying highp float lengthInDust;

void main(){
	const highp float milkyWayScale = 45.;
	const highp float milkyWayHeight = 1.5;
	
	highp float transmission = 1.;
	highp float transmissionScaleFactor = lengthInDust/milkyWayHeight/5.; 
    
    // Ray tracing loop. Using a fixed number of iteration to allow compiler optimization. 
    // i=0..9 gives a reasonably good visualy effect.
	for (int i=0;i<9;i++){
		highp float frac = float(i)/10.;
		highp vec3 texCoord = texCoordStart*frac+texCoordStop*(1.-frac);
		
		highp float z = (texCoord.z-0.5)*milkyWayScale/milkyWayHeight*4.;
		highp float dustopacity = texture2D(SamplerDust, texCoord.xy).a*exp(-z*z);

		transmission *= exp(-dustopacity*transmissionScaleFactor);
	}
	
	gl_FragColor = vec4(1.,1.,1.,-0.1+1.2*transmission); // clipping is done automatically, -0.1 and 1.2 used to avoid saturation when blending too many points
}