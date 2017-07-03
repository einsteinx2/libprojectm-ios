#import "GLViewController.h"
#import "GLProgram.h"
#import "GLView.h"
#import "GLCommon.h"
#import "GLTexture.h"
#import "projectM.hpp"
#import "AudioController.h"

// START:extension
@interface GLViewController ()
{
    GLuint      positionAttribute;
    GLuint      textureCoordinateAttribute;
    GLuint      matrixUniform;
    GLuint      textureUniform;
    
    Matrix3D    rotationMatrix;
    Matrix3D    translationMatrix;
    Matrix3D    modelViewMatrix;
    Matrix3D    projectionMatrix;
    Matrix3D    matrix;
    
    projectM *_pm;
    AudioController *_audioController;
}
@end
// END:extension

@implementation GLViewController
@synthesize program, texture;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _audioController = [[AudioController alloc] init];
    [_audioController startIOUnit];
    
#if 0
    int width = 350;
    int height = 350;
#else
    // BEN Why do I have to multiple the gl size for iOS and it doesnt match screen scale??
    // And why doesn't it fill the screen?
    float iosMultiplier = 1.0;//1.2;
    int width = self.view.bounds.size.width * iosMultiplier;
    int height = self.view.bounds.size.height * iosMultiplier;
#endif
    
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
    settings.smoothPresetDuration = 8;//1; // seconds
    settings.presetDuration = 65;//3;//5; // seconds
    settings.beatSensitivity = 0.8;
    settings.aspectCorrection = 0;//1;
    settings.easterEgg = 0; // ???
    settings.shuffleEnabled = 0;//1;
    settings.softCutRatingsEnabled = 1; // ???
    //settings.presetURL = [[presetsPath stringByAppendingString:@"presets_milkdrop"] cStringUsingEncoding:NSUTF8StringEncoding];
    settings.presetURL = [[presetsPath stringByAppendingString:@"test"] cStringUsingEncoding:NSUTF8StringEncoding];
    settings.menuFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    settings.titleFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    
    _pm = new projectM(settings);
    _pm->selectRandom(true);
    _pm->projectM_resetGL(width, height);
    
    [(GLView*)self.view startAnimation];
}

// START:setup
- (void)setup
{
    GLProgram *theProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"Shader"
                                                     fragmentShaderFilename:@"Shader"];
    self.program = theProgram;
    
    [self.program addAttribute:@"position"];
    [self.program addAttribute:@"textureCoordinates"];
    
    if (![self.program link])
    {
        NSLog(@"Link failed");
        
        NSString *progLog = [self.program programLog];
        NSLog(@"Program Log: %@", progLog); 
        
        NSString *fragLog = [self.program fragmentShaderLog];
        NSLog(@"Frag Log: %@", fragLog);
        
        NSString *vertLog = [self.program vertexShaderLog];
        NSLog(@"Vert Log: %@", vertLog);
        
        [(GLView *)self.view stopAnimation];
        self.program = nil;
    }
    
    positionAttribute = [program attributeIndex:@"position"];
    textureCoordinateAttribute = [program attributeIndex:@"textureCoordinates"];
    matrixUniform = [program uniformIndex:@"matrix"];
    textureUniform = [program uniformIndex:@"texture"];

    glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ZERO);
    
    GLTexture *theTexture = [[GLTexture alloc] initWithFilename:@"DieTexture.png"];
    self.texture = theTexture;
}
// END:setup
// START:draw
- (void)draw
{
#if 0
    static const Vertex3D vertices[] = 
    {
        {-0.276385, -0.850640, -0.447215},
        {0.000000, 0.000000, -1.000000},  
        {0.723600, -0.525720, -0.447215}, 
        {0.723600, -0.525720, -0.447215}, 
        {0.000000, 0.000000, -1.000000},  
        {0.723600, 0.525720, -0.447215},  
        {-0.894425, 0.000000, -0.447215}, 
        {0.000000, 0.000000, -1.000000},  
        {-0.276385, -0.850640, -0.447215},
        {-0.276385, 0.850640, -0.447215}, 
        {0.000000, 0.000000, -1.000000},  
        {-0.894425, 0.000000, -0.447215}, 
        {0.723600, 0.525720, -0.447215},  
        {0.000000, 0.000000, -1.000000},  
        {-0.276385, 0.850640, -0.447215}, 
        {0.723600, -0.525720, -0.447215}, 
        {0.723600, 0.525720, -0.447215},  
        {0.894425, 0.000000, 0.447215}, 	 
        {-0.276385, -0.850640, -0.447215},
        {0.723600, -0.525720, -0.447215}, 
        {0.276385, -0.850640, 0.447215},  
        {-0.894425, 0.000000, -0.447215}, 
        {-0.276385, -0.850640, -0.447215},
        {-0.723600, -0.525720, 0.447215}, 
        {-0.276385, 0.850640, -0.447215}, 
        {-0.894425, 0.000000, -0.447215}, 
        {-0.723600, 0.525720, 0.447215},  
        {0.723600, 0.525720, -0.447215},  
        {-0.276385, 0.850640, -0.447215}, 
        {0.276385, 0.850640, 0.447215}, 	 
        {0.894425, 0.000000, 0.447215}, 	 
        {0.276385, -0.850640, 0.447215},  
        {0.723600, -0.525720, -0.447215}, 
        {0.276385, -0.850640, 0.447215},  
        {-0.723600, -0.525720, 0.447215}, 
        {-0.276385, -0.850640, -0.447215},
        {-0.723600, -0.525720, 0.447215}, 
        {-0.723600, 0.525720, 0.447215},  
        {-0.894425, 0.000000, -0.447215}, 
        {-0.723600, 0.525720, 0.447215},  
        {0.276385, 0.850640, 0.447215}, 	 
        {-0.276385, 0.850640, -0.447215}, 
        {0.276385, 0.850640, 0.447215}, 	 
        {0.894425, 0.000000, 0.447215}, 	 
        {0.723600, 0.525720, -0.447215},  
        {0.276385, -0.850640, 0.447215},  
        {0.894425, 0.000000, 0.447215}, 	 
        {0.000000, 0.000000, 1.000000}, 	 
        {-0.723600, -0.525720, 0.447215}, 
        {0.276385, -0.850640, 0.447215},  
        {0.000000, 0.000000, 1.000000}, 	 
        {-0.723600, 0.525720, 0.447215},  
        {-0.723600, -0.525720, 0.447215}, 
        {0.000000, 0.000000, 1.000000}, 	 
        {0.276385, 0.850640, 0.447215}, 	 
        {-0.723600, 0.525720, 0.447215},  
        {0.000000, 0.000000, 1.000000}, 	 
        {0.894425, 0.000000, 0.447215}, 	 
        {0.276385, 0.850640, 0.447215}, 	 
        {0.000000, 0.000000, 1.000000}, 
    };
    static const TextureCoord textureCoordinates[] = 
    {
        {0.648752, 0.445995},
        {0.914415, 0.532311},
        {0.722181, 0.671980},
        {0.722181, 0.671980},
        {0.914415, 0.532311},
        {0.914415, 0.811645},
        {0.254949, 0.204901},
        {0.254949, 0.442518},
        {0.028963, 0.278329},
        {0.480936, 0.278329},
        {0.254949, 0.442518},
        {0.254949, 0.204901},
        {0.838115, 0.247091},
        {0.713611, 0.462739},
        {0.589108, 0.247091},
        {0.722181, 0.671980},
        {0.914415, 0.811645},
        {0.648752, 0.897968},
        {0.648752, 0.445995},
        {0.722181, 0.671980},
        {0.484562, 0.671981},
        {0.254949, 0.204901},
        {0.028963, 0.278329},
        {0.115283, 0.012663},
        {0.480936, 0.278329},
        {0.254949, 0.204901},
        {0.394615, 0.012663},
        {0.838115, 0.247091},
        {0.589108, 0.247091},
        {0.713609, 0.031441},
        {0.648752, 0.897968},
        {0.484562, 0.671981},
        {0.722181, 0.671980},
        {0.644386, 0.947134},
        {0.396380, 0.969437},
        {0.501069, 0.743502},
        {0.115283, 0.012663},
        {0.394615, 0.012663},
        {0.254949, 0.204901},
        {0.464602, 0.031442},
        {0.713609, 0.031441},
        {0.589108, 0.247091},
        {0.713609, 0.031441},
        {0.962618, 0.031441},
        {0.838115, 0.247091},
        {0.028963, 0.613069},
        {0.254949, 0.448877},
        {0.254949, 0.686495},
        {0.115283, 0.878730},
        {0.028963, 0.613069},
        {0.254949, 0.686495},
        {0.394615, 0.878730},
        {0.115283, 0.878730},
        {0.254949, 0.686495},
        {0.480935, 0.613069},
        {0.394615, 0.878730},
        {0.254949, 0.686495},
        {0.254949, 0.448877},
        {0.480935, 0.613069},
        {0.254949, 0.686495},
    };
    
    static GLfloat  rot = 0.0f;
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.program use];
        
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(positionAttribute);
    
    glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glEnableVertexAttribArray(textureCoordinateAttribute);
    
    static const Vector3D rotationVector = {1.f, 1.f, 1.f};
    Matrix3DSetRotationByDegrees(rotationMatrix, rot, rotationVector);
    Matrix3DSetTranslation(translationMatrix, 0.f, 0.f, -3.f);
    Matrix3DMultiply(translationMatrix, rotationMatrix, modelViewMatrix);

    Matrix3DSetPerspectiveProjectionWithFieldOfView(projectionMatrix, 45.f, 
                                                 0.1f, 100.f, 
                                                 self.view.frame.size.width / 
                                                 self.view.frame.size.height);
    
    
    Matrix3DMultiply(projectionMatrix, modelViewMatrix, matrix);
    glUniformMatrix4fv(matrixUniform, 1, FALSE, matrix);
    
    glActiveTexture (GL_TEXTURE0);
    [texture use];
    glUniform1i (textureUniform, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices) / sizeof(Vertex3D));
    

    
    rot += 2.f;
    if (rot > 360.f)
        rot -= 360.f;
#else
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
    _pm->pcm()->addPCM16(pcm_data);
    
//    BufferManager *buffer = [_audioController getBufferManagerInstance];
//    _pm->pcm()->addPCMfloat(buffer->mPCMData, buffer->mPCMSamples);
    
    glClearColor( 0.0, 0.5, 0.0, 0.0 );
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    _pm->renderFrame();
    glFlush();
#endif
}
// END:draw
#pragma mark -
- (void)viewDidUnload 
{
    [super viewDidUnload];
}

@end
