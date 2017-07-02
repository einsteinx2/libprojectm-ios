//
//  ViewController.m
//  projectmtest
//
//  Created by Benjamin Baron on 7/2/17.
//  Copyright © 2017 Ben Baron. All rights reserved.
//

#import "ViewController.h"
#import "ConstantsAndMacros.h"
#import "projectM.hpp"
#import "AudioController.h"

@interface ViewController()
{
    projectM *_pm;
    AudioController *_audioController;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _audioController = [[AudioController alloc] init];
    [_audioController startIOUnit];
    
    self.glView = [[GLView alloc] initWithFrame:self.view.bounds];
    self.glView.delegate = self;
    [self.view addSubview:self.glView];
    [self.glView startAnimation];
}

- (void)setupView:(UIView *)theView
{
    const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0;
    GLfloat size;
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
    CGRect rect = theView.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size /
               (rect.size.width / rect.size.height), zNear, zFar);
    glViewport(0, 0, rect.size.width, rect.size.height);
    glMatrixMode(GL_MODELVIEW);
    
    glLoadIdentity();
    
    
    int width = self.view.bounds.size.width, height = self.view.bounds.size.height;
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *presetsPath = [bundlePath stringByAppendingString:@"/presets/"];
    NSString *fontsPath = [bundlePath stringByAppendingString:@"/fonts"];
    
    projectM::Settings settings;
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
    settings.presetURL = [[presetsPath stringByAppendingString:@"presets_milkdrop"] cStringUsingEncoding:NSUTF8StringEncoding];
    settings.menuFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    settings.titleFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    
    _pm = new projectM(settings);
    _pm->selectRandom(true);
    _pm->projectM_resetGL(width, height);
}

- (void)drawView:(UIView *)theView
{
//    short pcm_data[2][512];
//    
//    /** Produce some fake PCM data to stuff into projectM */
//    for ( int i = 0 ; i < 512 ; i++ ) {
//        if ( i % 2 == 0 ) {
//            pcm_data[0][i] = (float)( rand() / ( (float)RAND_MAX ) * (pow(2,14) ) );
//            pcm_data[1][i] = (float)( rand() / ( (float)RAND_MAX ) * (pow(2,14) ) );
//        } else {
//            pcm_data[0][i] = (float)( rand() / ( (float)RAND_MAX ) * (pow(2,14) ) );
//            pcm_data[1][i] = (float)( rand() / ( (float)RAND_MAX ) * (pow(2,14) ) );
//        }
//        if ( i % 2 == 1 ) {
//            pcm_data[0][i] = -pcm_data[0][i];
//            pcm_data[1][i] = -pcm_data[1][i];
//        }
//    }
//    
//    /** Add the waveform data */
//    _pm->pcm()->addPCM16(pcm_data);
    
    BufferManager *buffer = [_audioController getBufferManagerInstance];
    _pm->pcm()->addPCMfloat(buffer->mPCMData, buffer->mPCMSamples);
    
    glClearColor( 0.0, 0.5, 0.0, 0.0 );
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    _pm->renderFrame();
    glFlush();
}

@end
