//
//  LYCaptureAdapte.h
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import <GPUImage/GPUImage.h>

@protocol LYVideoAdapteEable  <NSObject>

- (void)pushVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_BEGIN
@interface LYCaptureAdapter : NSObject<LYVideoAdapteEable>

@property(nonatomic,strong)GPUImageView * renderView;

@end

NS_ASSUME_NONNULL_END
