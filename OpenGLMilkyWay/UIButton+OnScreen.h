//
//  UIButton+OnScreen.h
//  Exoplanet
//
//  Created by Hanno Rein on 9/13/12.
//
//
typedef enum {
    UIOnscreenbuttonPositionTopLeft,
	UIOnscreenbuttonPositionTopRight,
	UIOnscreenbuttonPositionBottomLeft,
	UIOnscreenbuttonPositionBottomRight,
	UIOnscreenbuttonPositionMiddleLeft,
	UIOnscreenbuttonPositionMiddleRight,
	UIOnscreenbuttonPositionTopMiddle,
	UIOnscreenbuttonPositionBottomMiddle,
	UIOnscreenbuttonPositionBottom13,
	UIOnscreenbuttonPositionBottom23,
} UIOnscreenbuttonPosition;

#import <UIKit/UIKit.h>

@interface UIButton (OnScreen)

+(UIButton*)onscreenbuttonWithPosition:(UIOnscreenbuttonPosition)_position target:(id)_target action:(SEL)_action image:(NSString*)_image view:(UIView*)_view;

@end
