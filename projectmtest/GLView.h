//
//  GLView.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@protocol GLViewDelegate
- (void)drawView:(UIView *)theView;
- (void)setupView:(UIView *)theView;
@end

@interface GLView : UIView
@property NSTimeInterval animationInterval;
@property (weak) NSObject<GLViewDelegate> *delegate;
- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;
@end
