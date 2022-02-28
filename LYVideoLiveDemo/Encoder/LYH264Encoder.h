//
//  LYH264Encoder.h
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface LYH264Encoder : NSObject
@property(nonatomic,assign)int32_t width;
@property(nonatomic,assign)int32_t height;
@property(nonatomic,assign)int fps;

- (void)encoderPixelBuffer:(CVPixelBufferRef)pixelBuffer completion:(void(^)(NSData * data))completion;

@end

NS_ASSUME_NONNULL_END
