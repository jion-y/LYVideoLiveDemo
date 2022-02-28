//
//  LYBaseVideoProgress.m
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import "LYBaseVideoProgress.h"

@implementation LYBaseVideoProgress
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // set default texture options
        _outputTextureOptions.minFilter = GL_LINEAR;
        _outputTextureOptions.magFilter = GL_LINEAR;
        _outputTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
        _outputTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
        _outputTextureOptions.internalFormat = GL_RGBA;
        _outputTextureOptions.format = GL_BGRA;
        _outputTextureOptions.type = GL_UNSIGNED_BYTE;
    }
    return self;
}
- (void)progressVideoSamplerBuffer:(CMSampleBufferRef)sampleBuffer {
    
}


@end
