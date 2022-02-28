//
//  LYBaseVideoProgress.h
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>

@protocol LYVideoProgress <NSObject>
- (void)progressVideoSamplerBuffer:(CMSampleBufferRef)sampleBuffer;
@end
NS_ASSUME_NONNULL_BEGIN

@interface LYBaseVideoProgress : NSObject<LYVideoProgress>

@property(nonatomic,strong,nullable)GLProgram * program;
@property(nonatomic,assign)GLuint postionAttribute;
@property(nonatomic,assign)GLuint textureCoordinateAttribute;

@property(nonatomic,strong)GPUImageFramebuffer * outputFramebuffer;

@property(readwrite, nonatomic) GPUTextureOptions outputTextureOptions;

@property(nonatomic,assign)int bufferWidth;
@property(nonatomic,assign)int bufferHeight;

@end

NS_ASSUME_NONNULL_END
