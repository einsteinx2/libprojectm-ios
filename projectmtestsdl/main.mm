//
//  main.cpp
//  projectM-sdl
//
//  Created by Mischa Spiegelmock on 6/3/15.
//  Copyright (c) 2015 Mischa Spiegelmock. All rights reserved.
//
//  This is an implementation of projectM using libsdl2


#include "SDL.h"
//#include "SDL_opengles.h"

#include <OpenGLES/ES1/gl.h>
#include <UIKit/UIKit.h>

#include "projectM.hpp"
#include <iostream>
const float FPS = 60;

typedef struct {
    projectM *pm;
    SDL_Window *win;
    SDL_GLContext context;
    SDL_Renderer *rend;
    bool done;
    projectM::Settings settings;
    SDL_AudioDeviceID audioInputDevice;
} projectMApp;

int selectAudioInput(projectMApp *app) {
    // audio input stuff here is very platform-specific
    // too bad the libsdl2 audio capture support doesn't exist

    #ifdef __APPLE__
// UInt32 audioInputIsAvailable;
// UInt32 propertySize = sizeof (audioInputIsAvailable);
 
// AudioSessionGetProperty (
//     kAudioSessionProperty_AudioInputAvailable,
//     &propertySize,
//     &audioInputIsAvailable // A nonzero value on output means that
//                            // audio input is available
// );

    #endif

    return 1;
}

void renderFrame(projectMApp *app) {
    int i;
    short pcm_data[2][512];
    SDL_Event evt;
    
    SDL_PollEvent(&evt);
    switch (evt.type) {
        case SDL_KEYDOWN:
            // ...
            break;
        case SDL_QUIT:
            app->done = true;
            break;
    }


//        projectMEvent evt;
//        projectMKeycode key;
//        projectMModifier mod;
//
//        /** Process SDL events */
//        SDL_Event event;
//        while ( SDL_PollEvent( &event ) ) {
//            /** Translate into projectM codes and process */
//            evt = sdl2pmEvent( event );
//            key = sdl2pmKeycode( event.key.keysym.sym );
//            mod = sdl2pmModifier( (SDLMod)event.key.keysym.mod );
//            if ( evt == PROJECTM_KEYDOWN ) {
//                pm->key_handler( evt, key, mod );
//              }
//          }

    /** Produce some fake PCM data to stuff into projectM */
    for ( i = 0 ; i < 512 ; i++ ) {
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
    app->pm->pcm()->addPCM16(pcm_data);

    glClearColor( 0.0, 0.5, 0.0, 0.0 );
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    app->pm->renderFrame();
    glFlush();

    SDL_RenderPresent(app->rend);
}

/*
int main( int argc, char *argv[] ) {
    projectMApp app;
    app.done = 0;
    
    int width = [[UIScreen mainScreen] bounds].size.width;
    int height = [[UIScreen mainScreen] bounds].size.height;
//    int width = 784,
//        height = 784;
    
    if (SDL_Init(SDL_INIT_VIDEO) < 0)
    {
        printf("Unable to initialize SDL");
    }
    

//    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 5);
//    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 6);
//    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 5);
//    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 0);
//    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 0);
//    SDL_GL_SetAttribute(SDL_GL_RETAINED_BACKING, 0);
    
    //SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 1);
    //SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
    SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
    
    app.win = SDL_CreateWindow(NULL, 0, 0, width, height, SDL_WINDOW_OPENGL | SDL_WINDOW_BORDERLESS);

//    SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
//    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
//    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    
    //app.context = SDL_GL_CreateContext(app.win);
    
    // get an audio input device
    if (! selectAudioInput(&app)) {
        fprintf(stderr, "Failed to open audio input device\n");
        return 1;
    }

    
    
    
    // set up some OpenGL state
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    int screen_w, screen_h;
    SDL_GetWindowSize(app.win, &screen_w, &screen_h);
    glViewport(0, 0, screen_w, screen_h);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof((GLfloat) 0,
             (GLfloat) screen_w,
             (GLfloat) screen_h,
             (GLfloat) 0, 0.0, 1.0);
    
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glEnable(GL_POINT_SPRITE_OES);
    glTexEnvi(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, 1);
    
    
    app.rend = SDL_CreateRenderer(app.win, 0, SDL_RENDERER_ACCELERATED);
    if (! app.rend) {
        fprintf(stderr, "Failed to create renderer: %s\n", SDL_GetError());
        return PROJECTM_ERROR;
    }
    SDL_SetWindowTitle(app.win, "SDL Fun Party Time");
    printf("SDL init version 2\n");

    projectM::Settings settings;
    settings.meshX = 1;
    settings.meshY = 1;
    settings.fps   = 60;
    settings.textureSize = 2048;  // idk?
    settings.windowWidth = width;
    settings.windowHeight = height;
    settings.smoothPresetDuration = 1; // seconds
    settings.presetDuration = 3;//5; // seconds
    settings.beatSensitivity = 0.8;
    settings.aspectCorrection = 0;//1;
    settings.easterEgg = 0; // ???
    settings.shuffleEnabled = 0;//1;
    settings.softCutRatingsEnabled = 1; // ???
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *presetsPath = [bundlePath stringByAppendingString:@"/presets/"];
    NSString *fontsPath = [bundlePath stringByAppendingString:@"/fonts/"];
    //app.settings.presetURL = [[presetsPath stringByAppendingString:@"presets_milkdrop"] cStringUsingEncoding:NSUTF8StringEncoding];
    app.settings.presetURL = [[presetsPath stringByAppendingString:@"test"] cStringUsingEncoding:NSUTF8StringEncoding];
    app.settings.menuFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    app.settings.titleFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    
    // init projectM
    app.pm = new projectM(app.settings);
    app.pm->selectRandom(true);
    app.pm->projectM_resetGL(width, height);

    // standard main loop
    const Uint32 frame_delay = 1000/FPS;
    Uint32 last_time = SDL_GetTicks();
    while (! app.done) {
        renderFrame(&app);
        Uint32 elapsed = SDL_GetTicks() - last_time;
        if (elapsed < frame_delay)
            SDL_Delay(frame_delay - elapsed);
        last_time = SDL_GetTicks();
    }

    return PROJECTM_SUCCESS;
}*/



int main( int argc, char *argv[] ) {
    projectMApp app;
    app.done = 0;
    
    int width = 784,
    height = 784;
    
    // get an audio input device
    if (! selectAudioInput(&app)) {
        fprintf(stderr, "Failed to open audio input device\n");
        return 1;
    }
    
    SDL_Init(SDL_INIT_VIDEO);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 1);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
    SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
    
    app.win = SDL_CreateWindow("projectM", 0, 0, width, height, 0);
    app.context = SDL_GL_CreateContext(app.win);
    app.rend = SDL_CreateRenderer(app.win, 0, SDL_WINDOW_OPENGL | SDL_WINDOW_BORDERLESS);
    if (! app.rend) {
        fprintf(stderr, "Failed to create renderer: %s\n", SDL_GetError());
        return PROJECTM_ERROR;
    }
    SDL_SetWindowTitle(app.win, "SDL Fun Party Time");
    printf("SDL init version 2\n");
    
    app.settings.meshX = 1;
    app.settings.meshY = 1;
    app.settings.fps   = FPS;
    app.settings.textureSize = 2048;  // idk?
    app.settings.windowWidth = width;
    app.settings.windowHeight = height;
    app.settings.smoothPresetDuration = 8;//3; // seconds
    app.settings.presetDuration = 66;//5; // seconds
    app.settings.beatSensitivity = 0.8;
    app.settings.aspectCorrection = 1;
    app.settings.easterEgg = 0; // ???
    app.settings.shuffleEnabled = 1;
    app.settings.softCutRatingsEnabled = 1; // ???
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *presetsPath = [bundlePath stringByAppendingString:@"/presets/"];
    NSString *fontsPath = [bundlePath stringByAppendingString:@"/fonts/"];
    //app.settings.presetURL = [[presetsPath stringByAppendingString:@"presets_milkdrop"] cStringUsingEncoding:NSUTF8StringEncoding];
    app.settings.presetURL = [[presetsPath stringByAppendingString:@"test"] cStringUsingEncoding:NSUTF8StringEncoding];
    app.settings.menuFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    app.settings.titleFontURL = [[fontsPath stringByAppendingString:@"Vera.ttf"] cStringUsingEncoding:NSUTF8StringEncoding];
    
    // init projectM
    app.pm = new projectM(app.settings);
    app.pm->selectRandom(true);
    app.pm->projectM_resetGL(width, height);
    
    // standard main loop
    const Uint32 frame_delay = 1000/FPS;
    Uint32 last_time = SDL_GetTicks();
    while (! app.done) {
        renderFrame(&app);
        Uint32 elapsed = SDL_GetTicks() - last_time;
        if (elapsed < frame_delay)
            SDL_Delay(frame_delay - elapsed);
        last_time = SDL_GetTicks();
    }
    
    return PROJECTM_SUCCESS;
}

