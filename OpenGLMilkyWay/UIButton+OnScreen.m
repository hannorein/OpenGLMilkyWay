//
//  UIButton+OnScreen.m
//  Exoplanet
//
//  Created by Hanno Rein on 9/13/12.
//
//

#import "UIButton+OnScreen.h"

@implementation UIButton (OnScreen)

+(UIButton*)onscreenbuttonWithPosition:(UIOnscreenbuttonPosition)_position target:(id)_target action:(SEL)_action image:(NSString*)_image view:(UIView*)_view{
	
	UIButton* onscreenbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[onscreenbutton addTarget:_target action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	float size;
	NSString* _image_long;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		_image_long = [NSString stringWithFormat:@"%@.png",_image];
		size = 32;
	}else{
		_image_long = [NSString stringWithFormat:@"%@_iphone.png",_image];
		size = 24;
	}
	[onscreenbutton setImage:[UIImage imageNamed:_image_long] forState:UIControlStateNormal];
	[onscreenbutton setImageEdgeInsets:UIEdgeInsetsMake(10,10,10,10)];
	
	switch (_position) {
		case UIOnscreenbuttonPositionTopLeft:
			onscreenbutton.frame = CGRectMake(0,0, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
			break;
		case UIOnscreenbuttonPositionTopRight:
			onscreenbutton.frame = CGRectMake(_view.frame.size.width-size-20,0, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin);
			break;
		case UIOnscreenbuttonPositionBottomLeft:
			onscreenbutton.frame = CGRectMake(0,_view.frame.size.height-size-20, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin);
			break;
		case UIOnscreenbuttonPositionBottomRight:
			onscreenbutton.frame = CGRectMake(_view.frame.size.width-size-20,_view.frame.size.height-size-20, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin);
			break;
		case UIOnscreenbuttonPositionMiddleLeft:
			onscreenbutton.frame = CGRectMake(0,_view.frame.size.height/2.-size/2.-10, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
			break;
		case UIOnscreenbuttonPositionMiddleRight:
			onscreenbutton.frame = CGRectMake(_view.frame.size.width-size-20,_view.frame.size.height/2.-size/2.-10, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
			break;
		case UIOnscreenbuttonPositionTopMiddle:
			onscreenbutton.frame = CGRectMake(_view.frame.size.width/2.-size/2.-10,0, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
			break;
		case UIOnscreenbuttonPositionBottomMiddle:
			onscreenbutton.frame = CGRectMake(_view.frame.size.width/2.-size/2.-10,_view.frame.size.height-size-20, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin);
			break;
		case UIOnscreenbuttonPositionBottom13:
			onscreenbutton.frame = CGRectMake(_view.frame.size.width/3.-size/2.-10,_view.frame.size.height-size-20, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin);
			break;
		case UIOnscreenbuttonPositionBottom23:
			onscreenbutton.frame = CGRectMake(2.*_view.frame.size.width/3.-size/2.-10,_view.frame.size.height-size-20, size+20, size+20);
			onscreenbutton.autoresizingMask = ( UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin);
			break;
		default:
			break;
	}
	[_view addSubview:onscreenbutton];
	[_view bringSubviewToFront:onscreenbutton];
	
	return onscreenbutton;
}

@end
