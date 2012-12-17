// In
attribute vec4 Position;
attribute vec2 TextureCoord;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

// Out
varying lowp vec2 outTextureCoord;


void main(){
	outTextureCoord = TextureCoord;
	
	vec4 modelViewPosition = modelViewMatrix * Position;
	gl_Position = projectionMatrix * modelViewPosition;
}
