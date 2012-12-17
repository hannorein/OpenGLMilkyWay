//
//  ExoplanetSharegroup.m
//  Exoplanet
//
//  Created by Hanno Rein on 6/1/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import "ExoplanetSharegroup.h"
#import "Texture2D.h"
ExoplanetSharegroup* _defaultSharegroup = nil;

@interface ExoplanetSharegroup(){
	EAGLContext*			firstContext;
	EAGLContext*			queueContext;
	NSOperationQueue*		_textureQueue;
	NSMutableDictionary*	_textures;
	NSMutableArray*			_texturesLoading;
	NSMutableDictionary*	_texturesWithString;
	NSMutableArray*			_texturesWithStringLoading;
	NSMutableDictionary*	_texturesForLabel;
	NSMutableArray*			_texturesForLabelLoading;
}
@property (retain) EAGLContext*			queueContext;
@end

@implementation ExoplanetSharegroup
@synthesize queueContext;

-(id)init{
	if(self=[super init]){
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning:) name: UIApplicationDidReceiveMemoryWarningNotification object:nil];
		_textureQueue = [[NSOperationQueue alloc] init];
		_textureQueue.maxConcurrentOperationCount = 1;
		_textures					= [[NSMutableDictionary alloc]initWithCapacity:50];
		_texturesLoading			= [[NSMutableArray alloc] initWithCapacity:50];
		_texturesWithString			= [[NSMutableDictionary alloc]initWithCapacity:50];
		_texturesWithStringLoading	= [[NSMutableArray alloc] initWithCapacity:50];
		_texturesForLabel			= [[NSMutableDictionary alloc]initWithCapacity:50];
		_texturesForLabelLoading	= [[NSMutableArray alloc] initWithCapacity:50];
	}
	return self;
}
+(ExoplanetSharegroup *)defaultSharegroup{
	if (_defaultSharegroup==nil){
		_defaultSharegroup = [[ExoplanetSharegroup alloc] init];
	}
	return _defaultSharegroup;
}
- (void) handleMemoryWarning:(NSNotification *)notification{
	[self didReceiveMemoryWarning];
}

-(void)didReceiveMemoryWarning{
	[EAGLContext setCurrentContext: firstContext];
	[_textureQueue cancelAllOperations];
	[_texturesLoading removeAllObjects];
	[_textures removeAllObjects];
	[_texturesWithStringLoading removeAllObjects];
	[_texturesWithString removeAllObjects];
	[_texturesForLabelLoading removeAllObjects];
	[_texturesForLabel removeAllObjects];
	[EAGLContext setCurrentContext: nil];
}

-(EAGLContext *)getNewContext{
	if (firstContext==nil){
		firstContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		if (firstContext==nil) return nil;
		self.queueContext = [self getNewContext];
	}
	return [[[EAGLContext alloc] initWithAPI:[firstContext API] sharegroup:[firstContext sharegroup]] autorelease];
}

-(unsigned int)loadTexture:(NSString*)filename{
	Texture2D* _texture = [[Texture2D alloc] initWithImage:[UIImage imageNamed:filename]];
	if (_texture==nil) {
		NSLog(@"Error while loading texture from file %@.",filename);
		return 0;
	}else{
		[_textures setValue:_texture forKey:filename];
		[_texture release];
		return _texture.name;
	}
}

-(unsigned int)getTexture:(NSString*)filename{
	Texture2D* _texture = [_textures objectForKey:filename];
	if (_texture==nil){
		return [self loadTexture:filename];
	}
	return _texture.name;
}

-(void)doneLoadingTextureWithDictionary:(NSDictionary*)_dic{
	[_textures setValue:[_dic objectForKey:@"texture"] forKey:[_dic objectForKey:@"filename"]];
	[_texturesLoading removeObject:[_dic objectForKey:@"filename"]];
}

-(void)loadTextureWithFilenameInBackgound:(NSString*)filename{
	[EAGLContext setCurrentContext: queueContext];

	Texture2D* _texture = [[Texture2D alloc] initWithImage:[UIImage imageNamed:filename]];
	
	if (_texture!=nil) {
		NSDictionary* _newdic = [[NSDictionary alloc] initWithObjectsAndKeys:_texture,@"texture",filename,@"filename", nil];
		[self performSelectorOnMainThread:@selector(doneLoadingTextureWithDictionary:) withObject:_newdic waitUntilDone:NO];
		[_newdic release];
		[_texture release];
	}
	[EAGLContext setCurrentContext: nil];
}



-(unsigned int)asynchronouslyGetTexture:(NSString*)filename{
	Texture2D* _texture = [_textures objectForKey:filename];
	if (_texture==nil){
		if ([_texturesLoading containsObject:filename]) return 0;
		NSInvocationOperation* op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadTextureWithFilenameInBackgound:)object:filename];
		[_textureQueue addOperation:op];
		[op release];
		return 0;
	}
	return _texture.name;
}

+(unsigned int)asynchronouslyBindTexture:(NSString*)filename{
	unsigned int _textureid = [[ExoplanetSharegroup defaultSharegroup] asynchronouslyGetTexture:filename];
	if (_textureid){
		glBindTexture(GL_TEXTURE_2D, _textureid);
	}
	return _textureid;	
}

+(unsigned int)bindTexture:(NSString*)filename{
	unsigned int _textureid = [[ExoplanetSharegroup defaultSharegroup] getTexture:filename];
	glBindTexture(GL_TEXTURE_2D, _textureid);
	return _textureid;
}
+(unsigned int)bindTextureWithString:(NSString*)string{
	unsigned int _textureid = [[ExoplanetSharegroup defaultSharegroup] getTextureWithString:string Size:CGSizeMake(256,128)];
	glBindTexture(GL_TEXTURE_2D, _textureid);
	return _textureid;
}
+(unsigned int)bindTextureWithString:(NSString*)string Size:(CGSize)size{
	unsigned int _textureid = [[ExoplanetSharegroup defaultSharegroup] getTextureWithString:string Size:size];
	glBindTexture(GL_TEXTURE_2D, _textureid);
	return _textureid;
}

+(unsigned int)bindTextureForLabel:(NSString*)string{
	unsigned int _textureid = [[ExoplanetSharegroup defaultSharegroup] getTextureForLabel:string];
	glBindTexture(GL_TEXTURE_2D, _textureid);
	return _textureid;
}

-(void)doneLoadingTextureFromStringWithDictionary:(NSDictionary*)_dic{
	[_texturesWithString setValue:[_dic objectForKey:@"texture"] forKey:[_dic objectForKey:@"string"]];
	[_texturesWithStringLoading removeObject:[_dic objectForKey:@"string"]];
}

-(void)loadTextureWithDictionary:(NSDictionary*)_dic{
	[EAGLContext setCurrentContext: queueContext];

	
	NSString* string = [_dic objectForKey:@"string"];
	CGSize size;
	size.width	= [[_dic objectForKey:@"width"]  floatValue];
	size.height	= [[_dic objectForKey:@"height"] floatValue];
	Texture2D* _texture = [[Texture2D alloc] initWithString:string dimensions:size alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:16.];

	if (_texture!=nil) {
		NSDictionary* _newdic = [[NSDictionary alloc] initWithObjectsAndKeys:_texture,@"texture",string,@"string", nil];
		[self performSelectorOnMainThread:@selector(doneLoadingTextureFromStringWithDictionary:) withObject:_newdic waitUntilDone:NO];
		[_newdic release];
		[_texture release];
	}
	[EAGLContext setCurrentContext: nil];
}

-(unsigned int)getTextureWithString:(NSString*)string Size:(CGSize)size{
	Texture2D* _texture = [_texturesWithString objectForKey:string];
	if (_texture==nil){
		if (![_texturesWithStringLoading containsObject:string]){
			[_texturesWithStringLoading addObject:string];
			NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:string,@"string",[NSNumber numberWithFloat:size.width],@"width",[NSNumber numberWithFloat:size.height],@"height", nil];
			NSInvocationOperation* op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadTextureWithDictionary:)object:dic];
			[_textureQueue addOperation:op];
			[dic release];
			[op release];
		}
		return 0;
	}
	return _texture.name;
}

-(unsigned int)getTextureForLabel:(NSString*)string{
	Texture2D* _texture = [_texturesForLabel objectForKey:string];
	if (_texture==nil){
		if (![_texturesForLabelLoading containsObject:string]){
			[_texturesForLabelLoading addObject:string];
			CGSize labelSize;
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
				labelSize = CGSizeMake(512,64);
			}else{
				labelSize = CGSizeMake(256,32);
			}
			NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:string,@"string",[NSNumber numberWithFloat:labelSize.width],@"width",[NSNumber numberWithFloat:labelSize.height],@"height", nil];
			NSInvocationOperation* op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadTextureForLabel:)object:dic];
			[_textureQueue addOperation:op];
			[dic release];
			[op release];
		}
		return 0;
	}
	return _texture.name;
}

-(void)loadTextureForLabel:(NSDictionary*)_dic{
	[EAGLContext setCurrentContext: queueContext];
	
	
	NSString* string = [_dic objectForKey:@"string"];
	CGSize size;
	size.width	= [[_dic objectForKey:@"width"]  floatValue];
	size.height	= [[_dic objectForKey:@"height"] floatValue];
	Texture2D* _texture = [[Texture2D alloc] initWithString:string dimensions:size alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:16.];
	
	if (_texture!=nil) {
		NSDictionary* _newdic = [[NSDictionary alloc] initWithObjectsAndKeys:_texture,@"texture",string,@"string", nil];
		[self performSelectorOnMainThread:@selector(doneLoadingTextureForLabel:) withObject:_newdic waitUntilDone:NO];
		[_newdic release];
		[_texture release];
	}
	[EAGLContext setCurrentContext: nil];
}

-(void)doneLoadingTextureForLabel:(NSDictionary*)_dic{
	[_texturesForLabel setValue:[_dic objectForKey:@"texture"] forKey:[_dic objectForKey:@"string"]];
	[_texturesForLabelLoading removeObject:[_dic objectForKey:@"string"]];
}


-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_textureQueue release];
	[_texturesWithString release];
	[_textures release];
	[_texturesLoading release];
	[_texturesWithStringLoading release];
	[queueContext release];
	[firstContext release];
	[super dealloc];
}
@end
