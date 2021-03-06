//
//  MyDrawingAppDelegate.m
//  MyDrawing 
//
//  Created by RoLY roLLs on 6/2/11.
//  Copyright 2011 RoLYroLLs Enterprises, LLC. All rights reserved.
//

#import "MyDrawingAppDelegate.h"

#import "MyCanvasView.h"
#import "SoundEffect.h"

//CONSTANTS:

#define kPaletteHeight			30
#define kPaletteSize			5
#define kMinEraseInterval		0.5

#define kButtonHeight			30

// Padding for margins
#define kLeftMargin				10.0
#define kTopMargin				10.0
#define kRightMargin			10.0

//FUNCTIONS:
/*
 HSL2RGB Converts hue, saturation, luminance values to the equivalent red, green and blue values.
 For details on this conversion, see Fundamentals of Interactive Computer Graphics by Foley and van Dam (1982, Addison and Wesley)
 You can also find HSL to RGB conversion algorithms by searching the Internet.
 See also http://en.wikipedia.org/wiki/HSV_color_space for a theoretical explanation
 */
static void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
	float			temp1,
	temp2;
	float			temp[3];
	int				i;
	
	// Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
	if(s == 0.0) {
		if(outR)
			*outR = l;
		if(outG)
			*outG = l;
		if(outB)
			*outB = l;
		return;
	}
	
	// Test for luminance and compute temporary values based on luminance and saturation 
	if(l < 0.5)
		temp2 = l * (1.0 + s);
	else
		temp2 = l + s - l * s;
	temp1 = 2.0 * l - temp2;
	
	// Compute intermediate values based on hue
	temp[0] = h + 1.0 / 3.0;
	temp[1] = h;
	temp[2] = h - 1.0 / 3.0;
	
	for(i = 0; i < 3; ++i) {
		
		// Adjust the range
		if(temp[i] < 0.0)
			temp[i] += 1.0;
		if(temp[i] > 1.0)
			temp[i] -= 1.0;
		
		
		if(6.0 * temp[i] < 1.0)
			temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
		else {
			if(2.0 * temp[i] < 1.0)
				temp[i] = temp2;
			else {
				if(3.0 * temp[i] < 2.0)
					temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
				else
					temp[i] = temp1;
			}
		}
	}
	
	// Assign temporary values to R, G, B
	if(outR)
		*outR = temp[0];
	if(outG)
		*outG = temp[1];
	if(outB)
		*outB = temp[2];
}

//CLASS IMPLEMENTATIONS:

@implementation MyDrawingAppDelegate


@synthesize myWindow = _myWindow;
@synthesize myCanvas = _myCanvas;

@synthesize erasingSound = _erasingSound;
@synthesize selectSound = _selectSound;

@synthesize saveButton = _saveButton;
@synthesize eraseButton = _eraseButton;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
	CGRect					rect = [[UIScreen mainScreen] applicationFrame];
	CGFloat					components[3];
	
	// Create a segmented control so that the user can choose the brush color.
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 [UIImage imageNamed:@"Red.png"],
											 [UIImage imageNamed:@"Yellow.png"],
											 [UIImage imageNamed:@"Green.png"],
											 [UIImage imageNamed:@"Blue.png"],
											 [UIImage imageNamed:@"Purple.png"],
											 nil]];
	
	// Compute a rectangle that is positioned correctly for the segmented control you'll use as a brush color palette
	//CGRect frame = CGRectMake(rect.origin.x + kLeftMargin, rect.size.height - kPaletteHeight - kTopMargin, rect.size.width - (kLeftMargin + kRightMargin), kPaletteHeight);
	CGRect frame = CGRectMake(rect.origin.x, rect.size.height - kPaletteHeight - kButtonHeight, rect.size.width, kPaletteHeight);
	[segmentedControl setFrame:frame];
	// When the user chooses a color, the method changeBrushColor: is called.
	[segmentedControl addTarget:self action:@selector(changeBrushColor:) forControlEvents:UIControlEventValueChanged];
	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	// Make sure the color of the color complements the black background
	[segmentedControl setTintColor:[UIColor darkGrayColor]];
	// Set the third color (index values start at 0)
	[segmentedControl setSelectedSegmentIndex:2];
	
	// Add the control to the window
	[[self myWindow] addSubview:segmentedControl];
	// Now that the control is added, you can release it
	[segmentedControl release];
	
	// Erase button
	[self setEraseButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
	
	CGRect eraseButtonFrame = CGRectMake(rect.origin.x, rect.size.height - kButtonHeight, rect.size.width / 2, kButtonHeight);
	[[self eraseButton] setFrame:eraseButtonFrame];
	
	[[self myWindow] addSubview:[self eraseButton]];
	
	[[self eraseButton] setTitle:@"Erase" forState:UIControlStateNormal];
	[[self eraseButton] addTarget:self action:@selector(eraseView) forControlEvents:UIControlEventTouchUpInside];
	
	// Save button
	[self setSaveButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
	
	CGRect saveButtonFrame = CGRectMake(rect.size.width / 2, rect.size.height - kButtonHeight, rect.size.width / 2, kButtonHeight);
	[[self saveButton] setFrame:saveButtonFrame];
	
	[[self myWindow] addSubview:[self saveButton]];
	
	[[self saveButton] setTitle:@"Save" forState:UIControlStateNormal];
	[[self saveButton] addTarget:self action:@selector(saveDrawing) forControlEvents:UIControlEventTouchUpInside];
	
    // Define a starting color 
	HSL2RGB((CGFloat) 2.0 / (CGFloat)kPaletteSize, kSaturation, kLuminosity, &components[0], &components[1], &components[2]);
	// Defer to the OpenGL view to set the brush color
	[[self myCanvas] setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
	
	// Look in the Info.plist file and you'll see the status bar is hidden
	// Set the style to black so it matches the background of the application
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
	// Now show the status bar, but animate to the style.
	[application setStatusBarHidden:NO withAnimation:YES];
	
	// Load the sounds
	NSBundle *mainBundle = [NSBundle mainBundle];	
	[self setErasingSound:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]]];
	[self setSelectSound:[[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Select" ofType:@"caf"]]];
	
	// Erase the view when recieving a notification named "shake" from the NSNotificationCenter object
	// The "shake" nofification is posted by the PaintingWindow object when user shakes the device
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eraseView) name:@"shake" object:nil];
    return YES;
}

-(void)dealloc
{
	[_selectSound release];
	[_erasingSound release];
	[_saveButton release];
	[_myCanvas release];
	[_myWindow release];
	
	[super dealloc];
}

// Change the brush color
-(void)changeBrushColor:(id)sender
{
 	CGFloat					components[3];
	
	// Play sound
 	[[self selectSound] play];
	
	// Define a new brush color
 	HSL2RGB((CGFloat)[sender selectedSegmentIndex] / (CGFloat)kPaletteSize, kSaturation, kLuminosity, &components[0], &components[1], &components[2]);
	// Defer to the OpenGL view to set the brush color
	[[self myCanvas] setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
	
}

// Called when receiving the "shake" notification; plays the erase sound and redraws the view
-(void)eraseView
{
	if(CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval)
	{
		[[self erasingSound] play];
		[[self myCanvas] erase];
		lastTime = CFAbsoluteTimeGetCurrent();
	}
}

#pragma mark - Save View as Image

// Called to get a view's context as an image
-(UIImage *)createImageFromGLView:(UIView *)glView
{
    int width = glView.frame.size.width;
    int height = glView.frame.size.height;
	
    NSInteger myDataLength = width * height * 4;
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y < height; y++)
    {
        for(int x = 0; x < width * 4; x++)
        {
            buffer2[((height - 1) - y) * width * 4 + x] = buffer[y * 4 * width + x];
        }
    }
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}

-(void)saveDrawing
{
	// Save the view to the user's library
	UIImageWriteToSavedPhotosAlbum([self createImageFromGLView:[self myCanvas]], nil, nil, nil);
}

@end
