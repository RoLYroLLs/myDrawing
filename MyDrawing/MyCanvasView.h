//
//  MyCanvasView.h
//  MyDrawing
//
//  Created by RoLY roLLs on 6/2/11.
//  Copyright 2011 RoLYroLLs Enterprises, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

//CONSTANTS:

#define kBrushOpacity		(1.0 / 3.0)
#define kBrushPixelStep		3
#define kBrushScale			2
#define kLuminosity			0.75
#define kSaturation			1.0

//CLASS INTERFACES:

@interface MyCanvasView : UIView
{
@private
	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
	
	// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
	GLuint depthRenderbuffer;
	
	GLuint	brushTexture;
	CGPoint	location;
	CGPoint	previousLocation;
	Boolean	firstTouch;
	Boolean needsErase;	
}

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;

-(void)erase;
-(void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end
