//
//  ShaderManager.h
//  Exoplanet
//
//  Created by Hanno Rein on 6/15/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleShader.h"

@interface ShaderManager : NSObject{
	
}
+(SimpleShader*)getSimpleShaderWithName:(NSString*)name;

@end
