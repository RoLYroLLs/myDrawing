//
//  MyDrawingAppDelegate.h
//  MyDrawing 
//
//  Created by RoLY roLLs on 6/2/11.
//  Copyright 2011 RoLYroLLs Enterprises, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyWindow;
@class MyCanvasView;
@class SoundEffect;

@interface MyDrawingAppDelegate : NSObject <UIApplicationDelegate>
{
	MyWindow *_myWindow;
	MyCanvasView *_myCanvas;
	
	SoundEffect *_erasingSound;
	SoundEffect *_selectSound;
	
	CFTimeInterval lastTime;
	
	UIButton *_saveButton;
	UIButton *_eraseButton;
}

@property (nonatomic, retain) IBOutlet MyWindow *myWindow;
@property (nonatomic, retain) IBOutlet MyCanvasView *myCanvas;

@property (nonatomic, retain) SoundEffect *erasingSound;
@property (nonatomic, retain) SoundEffect *selectSound;

@property (nonatomic, retain) UIButton *saveButton;
@property (nonatomic, retain) UIButton *eraseButton;

@end
