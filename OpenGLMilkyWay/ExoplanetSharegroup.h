//
//  ExoplanetSharegroup.h
//  Exoplanet
//
//  Created by Hanno Rein on 6/1/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import <Foundation/Foundation.h>
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface ExoplanetSharegroup : NSObject{
	
}

+(ExoplanetSharegroup*)defaultSharegroup;
-(EAGLContext*)getNewContext;
+(unsigned int)bindTexture:(NSString*)filename;
+(unsigned int)asynchronouslyBindTexture:(NSString*)filename;
+(unsigned int)bindTextureWithString:(NSString*)string;
+(unsigned int)bindTextureForLabel:(NSString*)string;
+(unsigned int)bindTextureWithString:(NSString*)string Size:(CGSize)size;

@end

