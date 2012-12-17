//
//  EGViewController.m
//  ZweierTEst
//
//  Created by Hanno Rein on 5/25/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UniverseViewController.h"
#import "ExoplanetSharegroup.h"
#import "UDEMilkyWay.h"
#import "SimpleShader.h"
#import "ShaderManager.h"
#import "ShareController.h"
#import "UIButton+OnScreen.h"

@interface UniverseViewController () {
    // OpenGL Matricies
	GLKMatrix4      modelViewMatrix;
	GLKMatrix4      projectionMatrix;

    // User interface
	UIButton*       backButton;
	UIButton*       shareButton;

    // Render engine
	UDEMilkyWay*	udeMilkyWay;	

	// User interaction
    float           radians_per_pixel;    
	GLKQuaternion	userQuarternion;    // Rotation
	float			userScale;          // Zoom
	
	// Smooth user interaction
	CGPoint         panVelocity;
	CGPoint         panInitial;
	float           panTimePassed;
    
	float           pinchVelocity;
	float           pinchInitial;
	float           pinchTimePassed;
    
	float           rotateTimePassed;
	float           rotateInitial;
	float           rotateVelocity;
}

@property (strong, nonatomic) EAGLContext *context;

@end


@implementation UniverseViewController
@synthesize context = _context;


-(id)init{
	if (self=[super init]){
		userQuarternion		= GLKQuaternionMake(0.f, 0.f, 0.f, 1.f);
		userScale			= 30.; //kiloparsec
		panTimePassed		= 1;
		pinchTimePassed		= 1;
	}
	return self;
}

- (void)dealloc{
	while (self.view.gestureRecognizers.count) {
		[self.view removeGestureRecognizer:[self.view.gestureRecognizers objectAtIndex:0]];
	}
    [_context release];
    [super dealloc];
}


#pragma mark - View Management

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Setup OpenGL
    self.context = [[ExoplanetSharegroup defaultSharegroup] getNewContext];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
	view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
	[EAGLContext setCurrentContext:self.context];
	CAEAGLLayer * const eaglLayer = (CAEAGLLayer*) view.layer;
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
	
	radians_per_pixel = M_PI / self.view.bounds.size.width;
	
	[self setupGL];
	[self update];
	
    
    // Add onscren buttons
	shareButton		= [[UIButton onscreenbuttonWithPosition:UIOnscreenbuttonPositionBottomRight target:self action:@selector(buttonPressed:) image:@"share" view:self.view] retain];
	backButton		= [[UIButton onscreenbuttonWithPosition:UIOnscreenbuttonPositionTopLeft target:self action:@selector(buttonPressed:) image:@"back" view:self.view] retain];
	
    
    // Setup gesture recognizers for user interaction
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	panRecognizer.delegate = self;
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [view addGestureRecognizer:panRecognizer];
    [panRecognizer release];
    
	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
	pinchRecognizer.delegate = self;
    [view addGestureRecognizer:pinchRecognizer];
    [pinchRecognizer release];
	
	UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
	rotationRecognizer.delegate = self;
    [view addGestureRecognizer:rotationRecognizer];
    [rotationRecognizer release];
}

- (void)viewWillAppear:(BOOL)animated{
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload{
	[super viewDidUnload];
    
	[backButton removeFromSuperview];
	[shareButton removeFromSuperview];
	[backButton release];
	[shareButton release];
	
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return YES;
}


#pragma mark - Screen capture

-(UIImage *) image:(UIImage *)image withAlpha:(CGFloat)alpha{
	
    // Create a pixel buffer in an easy to use format
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    UInt8 * m_PixelBuf = malloc(sizeof(UInt8) * height * width * 4);
	
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(m_PixelBuf, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
	
    //alter the alpha
    int length = height * width * 4;
    for (int i=0; i<length; i+=4){
        m_PixelBuf[i+3] =  255*alpha;
    }
	
	
    //create a new image
    CGContextRef ctx = CGBitmapContextCreate(m_PixelBuf, width, height,
											 bitsPerComponent, bytesPerRow, colorSpace,
											 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
    CGImageRef newImgRef = CGBitmapContextCreateImage(ctx);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
    free(m_PixelBuf);
	
    UIImage *finalImage = [UIImage imageWithCGImage:newImgRef];
    CGImageRelease(newImgRef);
	
    return finalImage;
}


#pragma mark - User Interaction

-(void)pan:(UIPanGestureRecognizer*)gesture {
    if ([gesture state] == UIGestureRecognizerStateBegan){
		panInitial = CGPointMake(0, 0);
		panTimePassed=1;
	}
	if ([gesture state] == UIGestureRecognizerStateChanged || [gesture state] == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gesture translationInView:[gesture view]];
		[self rotateQuaternionWithVector:CGPointMake(translation.x-panInitial.x, -(translation.y-panInitial.y))];
		panInitial = translation;
    }
	if ([gesture state] == UIGestureRecognizerStateEnded){
		panVelocity = [gesture velocityInView:[gesture view]];
		panTimePassed=0;
	}
}

-(void)rotate:(UIRotationGestureRecognizer*)gesture {
    if ([gesture state] == UIGestureRecognizerStateBegan){
		rotateInitial = 0;
		rotateTimePassed=1;
	}
	if ([gesture state] == UIGestureRecognizerStateChanged || [gesture state] == UIGestureRecognizerStateEnded) {
		userQuarternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(gesture.rotation-rotateInitial, 0, 0, -1),userQuarternion);
		rotateInitial = gesture.rotation;
    }
	if ([gesture state] == UIGestureRecognizerStateEnded){
		rotateVelocity = gesture.velocity;
		rotateTimePassed=0;
	}
}

-(void)pinch:(UIPinchGestureRecognizer*)gesture {
	if ([gesture state] == UIGestureRecognizerStateBegan){
		pinchInitial = 1;
		pinchTimePassed = 1;
	}
	if ([gesture state] == UIGestureRecognizerStateChanged || [gesture state] == UIGestureRecognizerStateEnded) {
        float scale = gesture.scale;
		userScale /= scale/pinchInitial;
		pinchInitial = scale;
    }
	if ([gesture state] == UIGestureRecognizerStateEnded){
		pinchVelocity = gesture.velocity;
		pinchTimePassed = 0;
		if (pinchVelocity>7.){
			pinchVelocity = 7.;
		}
		if (pinchVelocity<-7.){
			pinchVelocity = -7.;
		}
	}
}


-(void)buttonPressed:(id)sender{
	if (sender==backButton){
		exit(0);
	}
	if (sender==shareButton){
		GLKView *view = (GLKView *)self.view;
		UIImage* image = [self image:[view snapshot] withAlpha:1];
		NSString* text = @"The Milky Way and all discovered exoplanets via @ExoplanetApp";
		[ShareController shareText:text andImage:image viewController:self];
		return;
	}
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
	if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [touch.view.superview isKindOfClass:[GLKView class]]) return FALSE;
	return TRUE;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) return NO;
    return YES;
}

- (void) rotateMatrixWithArcBall:(GLKMatrix4 *)matrix{
	GLKVector3 axis = GLKQuaternionAxis(userQuarternion);
	float angle = GLKQuaternionAngle(userQuarternion);
	if( angle != 0.f )
		*matrix = GLKMatrix4Rotate(*matrix, angle, axis.v[0], axis.v[1], axis.v[2]);
}

- (void) rotateQuaternionWithVector:(CGPoint)delta{
	GLKVector3 up = GLKVector3Make(0.f, 1.f, 0.f);
	GLKVector3 right = GLKVector3Make(-1.f, 0.f, 0.f);
	
	up = GLKQuaternionRotateVector3( GLKQuaternionInvert(userQuarternion), up );
	right = GLKQuaternionRotateVector3( GLKQuaternionInvert(userQuarternion), right );
    
	userQuarternion = GLKQuaternionMultiply(userQuarternion, GLKQuaternionMakeWithAngleAndVector3Axis(delta.x * radians_per_pixel, up));
	
	userQuarternion = GLKQuaternionMultiply(userQuarternion, GLKQuaternionMakeWithAngleAndVector3Axis(delta.y * radians_per_pixel, right));
}

#pragma mark - OpenGL 

- (void)setupGL{
    [EAGLContext setCurrentContext:self.context];
	udeMilkyWay			= [[UDEMilkyWay alloc] init];
	udeMilkyWay.glkview = (GLKView*)self.view; // need access to glkviw for offscreen framebuffer
}

- (void)viewWillLayoutSubviews{
	[EAGLContext setCurrentContext:self.context];
}

- (void)tearDownGL{
    [EAGLContext setCurrentContext:self.context];
	[udeMilkyWay		release];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update{
    // Create a smooth user interaction
	if (panTimePassed<1.){
		panTimePassed+=self.timeSinceLastUpdate;
		float slowdown = (1.-panTimePassed)*(1.-panTimePassed);
		[self rotateQuaternionWithVector:CGPointMake(panVelocity.x*self.timeSinceLastUpdate*slowdown, -panVelocity.y*self.timeSinceLastUpdate*slowdown)];
	}
	if (pinchTimePassed<1.){
		pinchTimePassed+=self.timeSinceLastUpdate;
		float slowdown = (1.-pinchTimePassed)*(1.-pinchTimePassed)*(1.-pinchTimePassed)*(1.-pinchTimePassed);		
		float reduction = 1.+pinchVelocity*self.timeSinceLastUpdate*slowdown;
		if (reduction<0.5) reduction = 0.5; // safety fator to prevent overshooting.
		userScale /= powf(reduction,self.timeSinceLastUpdate*30.);
	}
	if (rotateTimePassed<1.){
		rotateTimePassed+=self.timeSinceLastUpdate;
		float slowdown = (1.-rotateTimePassed)*(1.-rotateTimePassed);
		userQuarternion = GLKQuaternionMultiply(GLKQuaternionMakeWithAngleAndAxis(rotateVelocity*self.timeSinceLastUpdate*slowdown, 0, 0, -1),userQuarternion);
	}
		 
    // Create the model view matrix
    modelViewMatrix = GLKMatrix4Identity;
	[self rotateMatrixWithArcBall:&modelViewMatrix];
	
    // Create the projection matrix
	float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	projectionMatrix =	GLKMatrix4MakePerspective(90./180.*M_PI, aspect, .2*userScale, 4.0*userScale);
	projectionMatrix = GLKMatrix4Multiply(projectionMatrix, GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.0f*userScale));
	
    [self updateUDE:udeMilkyWay];
}

-(void)updateUDE:(UniverseDrawableElement*)_ude{
	[_ude set_userScale:userScale];
	[_ude set_projectionMatrix:projectionMatrix];
	[_ude set_modelViewMatrix:modelViewMatrix];
	[_ude update:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    [udeMilkyWay		draw];
}


@end
