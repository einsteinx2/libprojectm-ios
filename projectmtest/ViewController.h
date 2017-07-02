//
//  ViewController.h
//  projectmtest
//
//  Created by Benjamin Baron on 7/2/17.
//  Copyright © 2017 Ben Baron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLView.h"

@interface ViewController : UIViewController<GLViewDelegate>
@property (nonatomic, strong) GLView *glView;
@end

