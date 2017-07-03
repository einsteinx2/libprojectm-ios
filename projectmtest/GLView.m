//
//  GLView.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
//#import <OpenGLES/EAGLDrawable.h>
#import "Regal.h"

#import "GLView.h"
#import "ConstantsAndMacros.h"


@interface GLView ()
{
    @private
    GLint _backingWidth;
    GLint _backingHeight;
    
    GLuint _viewRenderbuffer, _viewFramebuffer;
    GLuint _depthRenderbuffer;

    NSTimeInterval _animationInterval;
}
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;
- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
@end

#pragma mark -

@implementation GLView

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

#if kAttemptToUseOpenGLES2
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (_context == NULL)
        {
#endif
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
            
            if (!_context || ![EAGLContext setCurrentContext:_context]) {
                return nil;
            }
#if kAttemptToUseOpenGLES2
        }
#endif
        
        _animationInterval = 1.0 / kRenderingFrequency;
    }
    return self;
}

- (void)drawView 
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);
    [_delegate drawView:self];
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (BOOL)createFramebuffer
{
    glGenFramebuffersOES(1, &_viewFramebuffer);
    glGenRenderbuffersOES(1, &_viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_backingHeight);
    
    if (USE_DEPTH_BUFFER) 
    {
        glGenRenderbuffersOES(1, &_depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, _backingWidth, _backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    [_delegate setupView:self];
    return YES;
}

- (void)destroyFramebuffer
{
    if (_viewFramebuffer)
    {
        glDeleteFramebuffersOES(1, &_viewFramebuffer);
        _viewFramebuffer = 0;
        glDeleteRenderbuffersOES(1, &_viewRenderbuffer);
        _viewRenderbuffer = 0;
    }
    
    if(_depthRenderbuffer) 
    {
        glDeleteRenderbuffersOES(1, &_depthRenderbuffer);
        _depthRenderbuffer = 0;
    }
}

- (void)startAnimation
{
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
    _animationTimer = nil;
}

- (void)setAnimationTimer:(NSTimer *)newTimer
{
    [_animationTimer invalidate];
    _animationTimer = newTimer;
}

- (NSTimeInterval)animationInterval
{
    return _animationInterval;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
    _animationInterval = interval;
    if (self.animationTimer)
    {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)dealloc
{
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
}

@end
