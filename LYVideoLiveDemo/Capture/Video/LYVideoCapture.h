//
//  LYVideoCapture.h
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/22.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LYVideoAdapteEable;

@interface LYVideoCapture : NSObject

- (instancetype)initWithAdapter:(id<LYVideoAdapteEable>) adapter;

@property (nonatomic , strong) AVCaptureVideoPreviewLayer *mPreviewLayer;

- (void)startCapture;

- (void)stopCapture;

@end

NS_ASSUME_NONNULL_END
