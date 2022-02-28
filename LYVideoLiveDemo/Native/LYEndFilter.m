//
//  LYEndFilter.m
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import "LYEndFilter.h"
#import "LYH264Encoder.h"

@interface LYEndFilter() {
    GPUImageFramebuffer * inputFramebufferForEndcoder;
    uint8_t * pixelBuffer;
    
}
@property(nonatomic,strong)LYH264Encoder * encoder;
@end

@implementation LYEndFilter


- (BOOL)enabled {
    return YES;
}

- (void)endProcessing {
    
}

- (CGSize)maximumOutputSize {
    return CGSizeZero;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    if (!self.encoder) {
        self.encoder = [[LYH264Encoder alloc] init];
        self.encoder.fps = 30;
        self.encoder.width = inputFramebufferForEndcoder.size.width;
        self.encoder.height = inputFramebufferForEndcoder.size.height;
    }
    
    int width = inputFramebufferForEndcoder.size.width;
    int height = inputFramebufferForEndcoder.size.height;
    if (pixelBuffer == NULL) {
        pixelBuffer = malloc(width * height * 4 * sizeof(uint8_t));
    }
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixelBuffer);
    CVPixelBufferRef renderTarget = NULL;
    if (!renderTarget) {
      NSDictionary* pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
      CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                            width,
                                            height,
                                            kCVPixelFormatType_32BGRA,
                                            (__bridge CFDictionaryRef)(pixelAttributes),
                                            &renderTarget);
      if (result != noErr) {
        assert(result == noErr);
      }
    }
    
    CVPixelBufferLockBaseAddress(renderTarget, kCVPixelBufferLock_ReadOnly);
    void * baseAddrr = CVPixelBufferGetBaseAddress(renderTarget);
    memcpy(baseAddrr, pixelBuffer, width * height * 4);
    CVPixelBufferUnlockBaseAddress(renderTarget, kCVPixelBufferLock_ReadOnly);
    
    [self.encoder encoderPixelBuffer:renderTarget completion:^(NSData * _Nonnull data) {
        NSLog(@"dddddd");
    }];
    CVPixelBufferRelease(renderTarget);
}

- (void)releaseFrameBuffer {
    runSynchronouslyOnVideoProcessingQueue(^{
        [self->inputFramebufferForEndcoder unlock];
        self->inputFramebufferForEndcoder = nil;
    });
}

- (NSInteger) nextAvailableTextureIndex {
    return 0;
}

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue {
    
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    inputFramebufferForEndcoder = newInputFramebuffer;
    [inputFramebufferForEndcoder lock];
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
  
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {

}

- (BOOL)shouldIgnoreUpdatesToThisTarget {
    return NO;
}

- (BOOL)wantsMonochromeInput {
    return NO;
}

@end
