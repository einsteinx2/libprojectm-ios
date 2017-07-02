//
//  ProjectMView.mm
//  projectmtest
//
//  Created by Benjamin Baron on 7/2/17.
//  Copyright © 2017 Ben Baron. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#include "projectM.hpp"

#import "ProjectMView.h"

@interface ProjectMView() {
    projectM *pm;
    projectM::Settings settings;
}
@end

@implementation ProjectMView

static float drawInterval = 1./20.;
static int specWidth; //256 or 512
static int specHeight; //256 or 512

static CGContextRef specdc;
static void *specbuf;

typedef struct 
{
	uint8_t rgbRed, rgbGreen, rgbBlue, Aplha;
} RGBQUAD;

static void SetupArrays()
{
	if ([UIScreen mainScreen].scale == 1.0)// && !IS_IPAD())
		specWidth = specHeight = 256;
	else
		specWidth = specHeight = 512;
	
	specbuf = malloc(specWidth * specHeight * 4);
}

//- (void)createBitmapToDraw
static void SetupDrawBitmap()
{
	// create the bitmap
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	specdc = CGBitmapContextCreate(specbuf, specWidth, specHeight, 8, specWidth * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
	CGColorSpaceRelease(colorSpace);
}

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)setup
{
    SetupArrays();
    SetupDrawBitmap();
    
    int width = 512, height = 512;
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *presetsPath = [bundlePath stringByAppendingString:@"/presets/"];
    NSString *fontsPath = [bundlePath stringByAppendingString:@"/fonts"];
    
    settings.meshX = 1;
    settings.meshY = 1;
    settings.fps   = 60;
    settings.textureSize = 2048;  // idk?
    settings.windowWidth = width;
    settings.windowHeight = height;
    settings.smoothPresetDuration = 3; // seconds
    settings.presetDuration = 5; // seconds
    settings.beatSensitivity = 0.8;
    settings.aspectCorrection = 1;
    settings.easterEgg = 0; // ???
    settings.shuffleEnabled = 1;
    settings.softCutRatingsEnabled = 1; // ???
    settings.presetURL = [[presetsPath stringByAppendingString:@"presets_tryptonaut"] cStringUsingEncoding:NSUTF8StringEncoding];
    settings.menuFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    settings.titleFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    
    pm = new projectM(settings);
    pm->selectRandom(true);
    pm->projectM_resetGL(width, height);
    
	self.userInteractionEnabled = YES;
	
	self.drawTimer = nil;
	
	//[self createBitmapToDraw];
	
	//[self setupPalette];
	
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	
	eaglLayer.opaque = YES;
	// In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									@YES, kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
	
	context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	
	if (!context || ![EAGLContext setCurrentContext:context])
	{
		return nil;
	}
	
//	// Use OpenGL ES to generate a name for the texture.
//	glGenTextures(1, &imageTexture);
//	// Bind the texture name. 
//	glBindTexture(GL_TEXTURE_2D, imageTexture);
//	// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//	
//	//Set up OpenGL states
//	glMatrixMode(GL_PROJECTION);
//	CGRect frame = self.bounds;
//	glOrthof(0, frame.size.width, 0, frame.size.height, -1, 1);
//	glViewport(0, 0, frame.size.width, frame.size.height);
//	glMatrixMode(GL_MODELVIEW);
//	
//	glDisable(GL_DITHER);
//	glEnable(GL_TEXTURE_2D);
//	glEnableClientState(GL_VERTEX_ARRAY);
//	glEnable(GL_POINT_SPRITE_OES);
//	glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);

	return self;
}

// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder 
{
    if ((self = [super initWithCoder:coder]))
	{
		return [self setup];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		return [self setup];
	}
	
	return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    CGContextRelease(specdc);
    free(specbuf);
    
    [self.drawTimer invalidate];
    
    if (imageTexture)
    {
        glDeleteTextures(1, &imageTexture);
        imageTexture = 0;
    }
    
    if([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    
}

- (void)startEqDisplay
{
	//DLog(@"starting eq display");
	self.drawTimer = [NSTimer scheduledTimerWithTimeInterval:drawInterval target:self selector:@selector(drawTheEq) userInfo:nil repeats:YES];
}

- (void)stopEqDisplay
{
	//DLog(@"stopping eq display");
	[self.drawTimer invalidate];
    self.drawTimer = nil;
}

- (void)createBitmapToDraw
{
	// create the bitmap
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	specdc = CGBitmapContextCreate(specbuf, specWidth, specHeight, 8, specWidth * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
	CGColorSpaceRelease(colorSpace);
}

- (void)drawTheEq
{
    [EAGLContext setCurrentContext:context];
    
	short pcm_data[2][512];
    
    /** Produce some fake PCM data to stuff into projectM */
    for ( int i = 0 ; i < 512 ; i++ ) {
        if ( i % 2 == 0 ) {
            pcm_data[0][i] = (float)( rand() / ( (float)RAND_MAX ) * (pow(2,14) ) );
            pcm_data[1][i] = (float)( rand() / ( (float)RAND_MAX ) * (pow(2,14) ) );
        } else {
            pcm_data[0][i] = (float)( rand() / ( (float)RAND_MAX ) * (pow(2,14) ) );
            pcm_data[1][i] = (float)( rand() / ( (float)RAND_MAX ) * (pow(2,14) ) );
        }
        if ( i % 2 == 1 ) {
            pcm_data[0][i] = -pcm_data[0][i];
            pcm_data[1][i] = -pcm_data[1][i];
        }
    }
    
    /** Add the waveform data */
    pm->pcm()->addPCM16(pcm_data);
    
    glClearColor( 0.0, 0.5, 0.0, 0.0 );
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    pm->renderFrame();
    glFlush();

	
//	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, specWidth, specHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, specbuf);
//	
//	[EAGLContext setCurrentContext:context];
//	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
//	
//	GLfloat width = self.frame.size.width;
//	GLfloat height = self.frame.size.height;
//	GLfloat box[] = 
//	{   0,     height, 0, 
//		width, height, 0,
//		width,      0, 0,
//	    0,          0, 0 };
//	GLfloat tex[] = {0,0, 1,0, 1,1, 0,1};
//	
//	glEnableClientState(GL_VERTEX_ARRAY);
//	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
//	
//	glVertexPointer(3, GL_FLOAT, 0, box);
//	glTexCoordPointer(2, GL_FLOAT, 0, tex);
//	
//	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//	
//	glDisableClientState(GL_VERTEX_ARRAY);
//	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//	
//	//Display the buffer
//	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
//	
//	UIApplicationState state = [UIApplication sharedApplication].applicationState;
//	if (state == UIApplicationStateActive)
//	{
//		// Make sure we didn't resign active while the method was already running
//		[context presentRenderbuffer:GL_RENDERBUFFER_OES];
//	}
}

// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
- (void)layoutSubviews
{
	//DLog(@"self.layer.frame: %@", NSStringFromCGRect(self.layer.frame));
	//self.layer.frame = self.frame;
	//DLog(@"self.layer.frame: %@", NSStringFromCGRect(self.layer.frame));
	NSLog(@"  ");
	
	[EAGLContext setCurrentContext:context];
	
	glMatrixMode(GL_PROJECTION);
    CGRect frame = self.bounds;
    CGFloat scaleFactor = self.contentScaleFactor;
    glLoadIdentity();
    glOrthof(0, frame.size.width * scaleFactor, 0, frame.size.height * scaleFactor, -1, 1);
    glViewport(0, 0, frame.size.width * scaleFactor, frame.size.height * scaleFactor);
    glMatrixMode(GL_MODELVIEW);
	
	[self destroyFramebuffer];
	[self createFramebuffer];
	
	// Clear the framebuffer the first time it is allocated
	if (needsErase) 
	{
		[self erase];
		needsErase = NO;
	}
}

- (BOOL)createFramebuffer
{
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

// Erases the screen
- (void)erase
{
	[EAGLContext setCurrentContext:context];
	
	//Clear the buffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClearColor(0., 0., 0., 0.);
	glClear(GL_COLOR_BUFFER_BIT);
	
	//Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)eraseBitBuffer
{
	memset(specbuf, 0, (specWidth * specHeight * 4));
}

@end
