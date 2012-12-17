//
//  SimpleShader.h
//  Exoplanet
//
//  Created by Hanno Rein on 6/15/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleShader : NSObject{
	GLuint _program;
}
@property (readonly) GLuint program;

-(BOOL)loadShaders:(NSString*)filename;

-(void)addAttribute:(NSString*)_attrib;
-(void)addUniform:(NSString*)_uniform;
-(int)getAttribute:(NSString*)_attrib;
-(int)getUniform:(NSString*)_uniform;


@end
