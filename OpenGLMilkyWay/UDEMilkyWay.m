//
//  URMilkyWay.m
//  Exoplanet
//
//  Created by Hanno Rein on 5/25/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import "UDEMilkyWay.h"
#import "Texture2D.h"
#import "ShaderManager.h"
#import "ExoplanetSharegroup.h"
#import "UniverseViewController.h"

@interface UDEMilkyWay () {
	long		numStars;
	GLuint		vertexBuffer;
	
	//Offscreen FBO
	GLuint frameBufferID;
	GLuint colorRenderBuffer;
	GLuint colorRenderBufferTextureID;
}

@end

@implementation UDEMilkyWay

-(id)init{
	if (self=[super init]){
		numStars = 0;
		vertexBuffer = 0;
		frameBufferID = 0;
	}
	return self;
}


-(void)draw{
	if (frameBufferID==0){
		[self createOffScreenFramebuffer];
	}
	if (!vertexBuffer){
		[self generateMilkyWay];
	}
	
	// Texture
	float milkywayscale = 45./2.; //kpc
	float z = GLKMatrix4MultiplyVector3(_modelViewMatrix, GLKVector3Make(0, 0, 1)).v[2];
	
	
	{
        // Draw background image
		float _opacity = 1.1*fabs(z)-0.2; // tilt
		_opacity = MAX(MIN(_opacity, 1.),0.);
		_opacity *= -1.+1.*logf(_userScale*1.3); //scale
		_opacity = MAX(MIN(_opacity, 1.),0.);
		
		glEnable (GL_BLEND);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		
		SimpleShader* _simpleShader = [ShaderManager getSimpleShaderWithName:@"QuadMilkyWay"];
		glUseProgram(_simpleShader.program);
		
		[ExoplanetSharegroup bindTexture:@"milkywaybg.png"];
		
		GLKMatrix4 modelViewMatrixTexture = GLKMatrix4Scale(_modelViewMatrix, milkywayscale*2., milkywayscale*2., milkywayscale*2.);

		glEnableVertexAttribArray([_simpleShader getAttribute:@"Position"]);
		glEnableVertexAttribArray([_simpleShader getAttribute:@"TextureCoord"]);
		glUniformMatrix4fv([_simpleShader getUniform:@"modelViewMatrix"], 1, 0,  modelViewMatrixTexture.m);
		glUniformMatrix4fv([_simpleShader getUniform:@"projectionMatrix"], 1, 0,  _projectionMatrix.m);

		glUniform1i([_simpleShader getUniform:@"Sampler"], 0);
		glUniform1f([_simpleShader getUniform:@"Opacity"], _opacity);
		
		const float data[20]	= {
			-0.5, -0.5, 0, 0, 0,
			-0.5,  0.5, 0, 0, 1,
			0.5,  -0.5, 0, 1, 0,
			0.5,   0.5, 0, 1, 1
		};
		glVertexAttribPointer([_simpleShader getAttribute:@"Position"], 3, GL_FLOAT, GL_FALSE, sizeof(float)*5, data);
		glVertexAttribPointer([_simpleShader getAttribute:@"TextureCoord"], 2, GL_FLOAT, GL_FALSE, sizeof(float)*5, &(data[3]));

		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		glDisableVertexAttribArray([_simpleShader getAttribute:@"Position"]);
		glDisableVertexAttribArray([_simpleShader getAttribute:@"TextureCoord"]);
		glBindTexture(GL_TEXTURE_2D, 0);
		glDisable(GL_BLEND);
		
	}
	
	
	{
		// Points
		// DRAW TO OFF SCREEN BUFFER
		glBindFramebuffer(GL_FRAMEBUFFER, frameBufferID);
		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
		glViewport(0, 0, 256, 256);
		glClearColor(0, 0, 0, 1.f);
		glClear(GL_COLOR_BUFFER_BIT);
		
		
		SimpleShader* pointShader = [ShaderManager getSimpleShaderWithName:@"PointsMilkyWayToTexture"];
		glUseProgram(pointShader.program);
		glDisable(GL_BLEND);
		
		
		// Setup dust texture
		[ExoplanetSharegroup bindTexture:@"milkywaydust.png"];
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		
		// Provide matricies and uniforms
		glUniformMatrix4fv([pointShader getUniform:@"modelViewMatrix"], 1, 0, _modelViewMatrix.m);
        GLKVector3 cameraPosition = GLKMatrix4MultiplyAndProjectVector3(GLKMatrix4Invert(_modelViewMatrix,NULL), GLKVector3Make(0, 0, _userScale));
		glUniform3fv([pointShader getUniform:@"cameraPosition"],1,cameraPosition.v);
		glUniform1i([pointShader getUniform:@"SamplerDust"], 0);

		// Provide array data
		glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
		glVertexAttribPointer([pointShader getAttribute:@"Position"],	3, GL_FLOAT, GL_FALSE, sizeof(float)*10, 0);
		glVertexAttribPointer([pointShader getAttribute:@"texCoordIn"],	2, GL_FLOAT, GL_FALSE, sizeof(float)*10, BUFFER_OFFSET(sizeof(float)*8));
		glEnableVertexAttribArray([pointShader getAttribute:@"Position"]);
		glEnableVertexAttribArray([pointShader getAttribute:@"texCoordIn"]);
		
		
		// Execute shaders
        glDrawArrays(GL_POINTS, 0, numStars);
		
		// Cleanup
		glBindTexture(GL_TEXTURE_2D, 0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		
		glDisableVertexAttribArray([pointShader getAttribute:@"texCoordIn"]);
		glDisableVertexAttribArray([pointShader getAttribute:@"Position"]);
		
		
		// DRAW TO MAIN BUFFER
		// DRAW REST
		
		[_glkview bindDrawable]; // reset to main framebuffer
		
	}

	{
		// Points NOW REALLY DRAWING POINTS
		
		SimpleShader* pointShader = [ShaderManager getSimpleShaderWithName:@"PointsMilkyWay"];
		glUseProgram(pointShader.program);
		glEnable (GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		// Setup textures
		glUniform1i([pointShader getUniform:@"SamplerDust"], 1);
		glUniform1i([pointShader getUniform:@"Sampler"], 0);
		glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D, colorRenderBufferTextureID);
		glActiveTexture(GL_TEXTURE0);
		[ExoplanetSharegroup bindTexture:@"newblob.png"];
		

		// Provide matricies and uniforms
		glUniformMatrix4fv([pointShader getUniform:@"modelViewMatrix"], 1, 0, _modelViewMatrix.m);
		glUniformMatrix4fv([pointShader getUniform:@"projectionMatrix"], 1, 0, _projectionMatrix.m);
		glUniform1f([pointShader getUniform:@"UserScale"], _userScale);
        float pointSize = MIN(16./_userScale,8./sqrtf(_userScale));
		if (isRetina)   pointSize *= 2.;
		if (isIpad)     pointSize *= 2.;
		glUniform1f([pointShader getUniform:@"pointSizePreMultiply"], pointSize);
        
		glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
		glVertexAttribPointer([pointShader getAttribute:@"Position"],	3, GL_FLOAT, GL_FALSE, sizeof(float)*10, 0);
		glVertexAttribPointer([pointShader getAttribute:@"PointSize"],	1, GL_FLOAT, GL_FALSE, sizeof(float)*10, BUFFER_OFFSET(sizeof(float)*3));
		glVertexAttribPointer([pointShader getAttribute:@"Color"],		4, GL_FLOAT, GL_FALSE, sizeof(float)*10, BUFFER_OFFSET(sizeof(float)*4));
		glVertexAttribPointer([pointShader getAttribute:@"texCoordIn"],	2, GL_FLOAT, GL_FALSE, sizeof(float)*10, BUFFER_OFFSET(sizeof(float)*8));
		
		// Provide array data
		glEnableVertexAttribArray([pointShader getAttribute:@"Position"]);
		glEnableVertexAttribArray([pointShader getAttribute:@"PointSize"]);
		glEnableVertexAttribArray([pointShader getAttribute:@"Color"]);
		glEnableVertexAttribArray([pointShader getAttribute:@"texCoordIn"]);

		
		// Execute shader
		glDrawArrays(GL_POINTS, 0, numStars);
		
		// Cleanup
		glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D, 0);
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, 0);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		
		glDisableVertexAttribArray([pointShader getAttribute:@"Position"]);
		glDisableVertexAttribArray([pointShader getAttribute:@"PointSize"]);
		glDisableVertexAttribArray([pointShader getAttribute:@"Color"]);
		glDisableVertexAttribArray([pointShader getAttribute:@"texCoordIn"]);

		
		glDisable(GL_BLEND);
	}
}


-(void)dealloc{
	if (vertexBuffer){
		glDeleteBuffers(1, &(vertexBuffer));
		vertexBuffer = 0;
	}
	[super dealloc];
}


-(void)generateMilkyWay{
    // Load a precalculated array of points. The points represent the galaxy.
    // Format (all floats): x, y, z, size, colorr, colorg, colorb, coloralpha, texturex, texturey
    
	NSMutableData* data = [[NSMutableData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"milkyway0" ofType:@"binary"]];
	numStars = data.length/(sizeof(float)*10);
	
	glGenBuffers(1, &(vertexBuffer));
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, data.length, data.bytes, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	[data release];
}

- (void)createOffScreenFramebuffer{
	if (frameBufferID != 0){
        // Recreating the framebuffer is only needed when the size changes.
		glDeleteRenderbuffers(1, &colorRenderBuffer);
		glDeleteFramebuffers(1, &frameBufferID);
	}
	
	// Color buffer
	glGenRenderbuffers(1, &colorRenderBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, 256, 256);
	
	// Frame buffer
	glGenFramebuffers(1, &frameBufferID);
	glBindFramebuffer(GL_FRAMEBUFFER, frameBufferID);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
	
	// Texture
	glGenTextures(1, &colorRenderBufferTextureID);
	glBindTexture(GL_TEXTURE_2D, colorRenderBufferTextureID);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 256, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colorRenderBufferTextureID, 0);
	
	
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)	NSLog(@"Framebuffer is not complete.");
	
	glBindTexture(GL_TEXTURE_2D, 0);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	
	
	[_glkview bindDrawable]; // reset to main framebuffer because we changed it when we made a 2nd framebuffer
}



@end
