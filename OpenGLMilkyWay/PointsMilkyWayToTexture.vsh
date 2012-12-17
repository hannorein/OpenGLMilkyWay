//In
attribute vec4 Position;
attribute vec2 texCoordIn;

uniform mat4 modelViewMatrix;
uniform vec3 cameraPosition;

//Out
varying highp vec3 texCoordStart;
varying highp vec3 texCoordStop;
varying highp float lengthInDust;

void main(){
	const highp float milkyWayScale = 45.;
	const highp float milkyWayHeight = 1.5;
	vec4 modelViewPosition = modelViewMatrix * Position;
	
	gl_Position = vec4(texCoordIn.x,texCoordIn.y,0.,1.);
	gl_PointSize = 1.;
	
	vec3 lineOfSight = cameraPosition-Position.xyz;
	float lineOfSightLength = length(lineOfSight);
	vec3 lineOfSightNorm = lineOfSight/lineOfSightLength;
	float lengthLineOfSightXY = length(lineOfSightNorm.xy);

	float lengthInCircle = length(Position.xy - milkyWayScale/2.*normalize(lineOfSightNorm.xy));
	float lengthInCylinder = lengthInCircle/lengthLineOfSightXY;
	
	float lengthInDisk = max(0.,milkyWayHeight-sign(lineOfSightNorm.z)*Position.z)/abs(lineOfSightNorm.z);
	
	lengthInDust = min(min(lengthInDisk,lengthInCylinder),lineOfSightLength);


	texCoordStart = Position.xyz/milkyWayScale+0.5;
	texCoordStop  = (Position.xyz + lengthInDust*lineOfSightNorm.xyz)/milkyWayScale+0.5;
}
