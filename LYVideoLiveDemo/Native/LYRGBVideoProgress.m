//
//  LYRGBVideoProgress.m
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import "LYRGBVideoProgress.h"


@interface LYRGBVideoProgress()
@property(nonatomic,assign)GLuint inputImageTexture;

@property(nonatomic,assign)GLuint rgbTexture;
@end

@implementation LYRGBVideoProgress

- (void)progressVideoSamplerBuffer:(CMSampleBufferRef)sampleBuffer {
    [GPUImageContext useImageProcessingContext];
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    int bufferWidth = (int) CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int) CVPixelBufferGetHeight(pixelBuffer);
    
    self.bufferWidth = bufferWidth;
    self.bufferHeight = bufferHeight;
    
    
    int bytesPerRow = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
    self.outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(bytesPerRow / 4, bufferHeight) onlyTexture:YES];
    
    [self.outputFramebuffer activateFramebuffer];
    glBindTexture(GL_TEXTURE_2D, [self.outputFramebuffer texture]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bytesPerRow / 4, bufferHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(pixelBuffer));
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
}
@end
