//
//  SimpleShader.m
//  Exoplanet
//
//  Created by Hanno Rein on 6/15/12.
//  Copyright (c) 2012 Hanno Rein. All rights reserved.
//

#import "SimpleShader.h"
#import "ExoplanetSharegroup.h"


@interface SimpleShader(){
	NSMutableDictionary* attributes;
	NSMutableDictionary* uniforms;
	NSString* _filename;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation SimpleShader
@synthesize program = _program;

-(id)init{
	if (self=[super init]){
		attributes	= [[NSMutableDictionary alloc] init];
		uniforms	= [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc{
	if (_program) {
		glDeleteProgram(_program);
		_program = 0;
	}
	[attributes	release];
	[uniforms	release];
	[_filename release];
	[super dealloc];
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
	_filename = [file copy];
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader: %@.",file);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog{
    GLint status;
    glLinkProgram(prog);
    
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

-(void)addAttribute:(NSString*)_attrib{
	[attributes setValue:[NSNumber numberWithInt:[attributes count]] forKey:_attrib];
}
-(void)addUniform:(NSString*)_uniform{
	[uniforms setValue:[NSNumber numberWithInt:0] forKey:_uniform];
}

-(int)getAttribute:(NSString*)_attrib{
	NSNumber* value = [attributes objectForKey:_attrib];
	if (value) return [value intValue];
//	NSLog(@"Warning: Attribute %@ not found in %@.",_attrib,_filename);
	return 0;
}

-(int)getUniform:(NSString*)_uniform{
	NSNumber* value = [uniforms objectForKey:_uniform];
	if (value) return [value intValue];
//	NSLog(@"Warning: Uniform %@ not found in %@.",_uniform,_filename);
	return 0;
}


- (BOOL)loadShaders:(NSString*)filename{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:filename ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader.");
//#warning DEBUG REMOVE exit
//		exit(1);
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:filename ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader.");
//#warning DEBUG REMOVE exit
//		exit(1);
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
	for (NSString* key in attributes){
		NSNumber* value = [attributes objectForKey:key];
		glBindAttribLocation(_program, [value intValue], [key cStringUsingEncoding:NSASCIIStringEncoding]);
	}
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
//#warning DEBUG REMOVE exit
//		exit(1);
        return NO;
    }
    
    // Get uniform locations.
	NSArray* keys  = [[uniforms allKeys] copy];
	for (NSString* key in keys){
		int value = glGetUniformLocation(_program, [key cStringUsingEncoding:NSASCIIStringEncoding]);
		if (value==-1) NSLog(@"Error. Cannot find Uniform: %@ in %@.",key,filename);
		[uniforms setValue:[NSNumber numberWithInt:value] forKey:key];
	}
	[keys release];
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

@end
