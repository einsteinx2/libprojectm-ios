#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class GLProgram, GLTexture;

@interface GLViewController : UIViewController 
{
}
@property (nonatomic, strong) GLProgram *program;
@property (nonatomic, strong) GLTexture *texture;
- (void)draw;
- (void)setup;
@end
