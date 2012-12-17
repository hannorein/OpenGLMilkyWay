//In
attribute vec4 Position;
attribute float PointSize;
attribute vec4 Color;
attribute vec2 texCoordIn;

uniform highp float UserScale;
uniform highp float pointSizePreMultiply;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

//Out
varying highp vec4 colorVarying;
varying highp float relsize;
varying highp vec2 texCoordOut;

void main(){
	vec4 modelViewPosition = modelViewMatrix * Position;
	gl_Position = projectionMatrix * modelViewPosition;
	
	// Distance measured to the focus, measured in UserScales
	relsize = length(modelViewPosition.xyz)/UserScale;
	
	colorVarying = Color;
	gl_PointSize = max(1.,PointSize*pointSizePreMultiply);
	texCoordOut = texCoordIn/2.+0.5;
}
