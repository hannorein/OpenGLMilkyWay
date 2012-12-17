//
//  ShareController.m
//  Exoplanet
//
//  Created by Hanno Rein on 7/28/12.
//
//

#import "ShareController.h"
#import <Social/Social.h>

@implementation ShareController
+(void)shareText:(NSString*)text andImage:(UIImage*)image viewController:(UIViewController*)viewController{
	Class classUIActivityViewController = NSClassFromString (@"UIActivityViewController");
	if (classUIActivityViewController){
		// Yay! IOS6!
		UIActivityViewController *activityVC = [[classUIActivityViewController alloc] initWithActivityItems:@[text,image] applicationActivities:nil];
		[viewController presentViewController:activityVC animated:YES completion:nil];
		[activityVC release];
	}else{
		// Nope. iOS < 6
        // You can add a fallback here, using the Twitter framework.
	}
}
@end
