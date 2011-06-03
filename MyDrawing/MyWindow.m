//
//  MyWindow.m
//  MyDrawing
//
//  Created by RoLY roLLs on 6/2/11.
//  Copyright 2011 RoLYroLLs Enterprises, LLC. All rights reserved.
//

#import "MyWindow.h"


@implementation MyWindow

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if (motion == UIEventSubtypeMotionShake )
	{
		// User was shaking the device. Post a notification named "shake".
		[[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
	}
}

-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{	
}

@end
