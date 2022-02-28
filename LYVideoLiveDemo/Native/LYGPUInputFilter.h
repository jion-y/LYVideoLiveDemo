//
//  LYGPUInputFiter.h
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import <GPUImage/GPUImage.h>

typedef NS_ENUM(NSInteger,LYGPUInputVideoFormat) {
    LYGPUInputVideoFormatRGB,
    LYGPUInputVideoFormatNV12,
    LYGPUInputVideoFormatYUV,
};
NS_ASSUME_NONNULL_BEGIN

@interface LYGPUInputFilter : GPUImageOutput
- (instancetype)initWithVideoFormat:(LYGPUInputVideoFormat)format;

- (void)progressSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
