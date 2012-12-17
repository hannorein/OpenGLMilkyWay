//
//  UniverseDrawableElement.h
//  Exoplanet
//
//  Created by Hanno Rein on 6/1/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


@interface UniverseDrawableElement : NSObject{
	bool		isRetina;
	bool		isIpad;
	GLKMatrix4	_modelViewMatrix;
	GLKMatrix4	_projectionMatrix;
	float		_userScale;
}
@property 	GLKMatrix4	_modelViewMatrix;
@property 	GLKMatrix4	_projectionMatrix;
@property 	float		_userScale;

-(void)draw;
-(void)update:(float)timeInterval;
-(void)didReceiveMemoryWarning;

@end
