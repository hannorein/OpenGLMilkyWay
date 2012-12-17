//
//  ShaderManager.m
//  Exoplanet
//
//  Created by Hanno Rein on 6/15/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import "ShaderManager.h"
#import "SimpleShader.h"

ShaderManager* shaderManagerSingleton = nil;

@interface ShaderManager() {
	NSMutableDictionary* shaderCache;
}

@end
@implementation ShaderManager

-(id)init{
	if (self=[super init]){
		shaderCache = [[NSMutableDictionary alloc] initWithCapacity:50];
	}
	return self;
}
-(void)dealloc{
	[shaderCache removeAllObjects];
	[shaderCache release];
	[super dealloc];
}

-(void)loadShader{
}

-(SimpleShader*)_getSimpleShaderWithName:(NSString*)name{
	SimpleShader* _simpleShader = [shaderCache objectForKey:name];
	if (_simpleShader==nil){
		_simpleShader = [[SimpleShader alloc] init];
		
		if ([name isEqualToString:@"PointsMilkyWay"]){
			[_simpleShader addUniform:		@"projectionMatrix"];
			[_simpleShader addUniform:		@"modelViewMatrix"];
			[_simpleShader addUniform:		@"UserScale"];
			[_simpleShader addUniform:		@"pointSizePreMultiply"];
			[_simpleShader addUniform:		@"Sampler"];
			[_simpleShader addUniform:		@"SamplerDust"];
			[_simpleShader addAttribute:	@"Position"];
			[_simpleShader addAttribute:	@"PointSize"];
			[_simpleShader addAttribute:	@"Color"];
			[_simpleShader addAttribute:	@"texCoordIn"];
		}
		if ([name isEqualToString:@"PointsMilkyWayToTexture"]){
			[_simpleShader addUniform:		@"modelViewMatrix"];
			[_simpleShader addUniform:		@"SamplerDust"];
			[_simpleShader addUniform:		@"cameraPosition"];
			[_simpleShader addAttribute:	@"texCoordIn"];
			[_simpleShader addAttribute:	@"Position"];
		}
		if ([name isEqualToString:@"QuadMilkyWay"]){
			[_simpleShader addUniform:		@"projectionMatrix"];
			[_simpleShader addUniform:		@"modelViewMatrix"];
			[_simpleShader addUniform:		@"Sampler"];
			[_simpleShader addUniform:		@"Opacity"];
			[_simpleShader addAttribute:	@"Position"];
			[_simpleShader addAttribute:	@"TextureCoord"];
		}
		[_simpleShader loadShaders:name];
		[shaderCache setObject:_simpleShader forKey:name];
		[_simpleShader release];
	}
	return _simpleShader;
}


+(SimpleShader*)getSimpleShaderWithName:(NSString*)name{
	if (shaderManagerSingleton==nil){
		shaderManagerSingleton = [[ShaderManager alloc] init];
	}
	return [shaderManagerSingleton _getSimpleShaderWithName:name];
}

@end
