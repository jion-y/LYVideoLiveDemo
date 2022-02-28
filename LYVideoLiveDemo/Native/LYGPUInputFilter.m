//
//  LYGPUInputFiter.m
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import "LYGPUInputFilter.h"
#import "LYRGBVideoProgress.h"


@interface LYGPUInputFilter (){
    dispatch_semaphore_t frameRenderingSemaphore;
    
}
@property(nonatomic,assign)LYGPUInputVideoFormat videoFormat;
@property(nonatomic,strong)LYBaseVideoProgress * videoProgress;

@end
@implementation LYGPUInputFilter
- (instancetype)initWithVideoFormat:(LYGPUInputVideoFormat)format {
    self = [super init];
    if (self) {
        self.videoFormat = format;
        frameRenderingSemaphore = dispatch_semaphore_create(1);
        [self createVideoProgress];
    }
    return self;
}

- (void)progressSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    if (dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return;
    }
    CFRetain(sampleBuffer);
    runAsynchronouslyOnVideoProcessingQueue(^{
        CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        [self.videoProgress progressVideoSamplerBuffer:sampleBuffer];
        self->outputFramebuffer = self.videoProgress.outputFramebuffer;
        [self updateTargetsForVideoCameraUsingCacheTextureAtWidth:self.videoProgress.bufferWidth
                                                           height:self.videoProgress.bufferHeight
                                                             time:currentTime];
        CFRelease(sampleBuffer);
        dispatch_semaphore_signal(self->frameRenderingSemaphore);
    });
    
}

- (void)updateTargetsForVideoCameraUsingCacheTextureAtWidth:(int)bufferWidth height:(int)bufferHeight time:(CMTime)currentTime;
{
    BOOL captureAsYUV = self.videoFormat != LYGPUInputVideoFormatRGB;
    // First, update all the framebuffers in the targets
    for (id<GPUImageInput> currentTarget in targets)
    {
        if ([currentTarget enabled])
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                [currentTarget setInputRotation:kGPUImageNoRotation atIndex:textureIndexOfTarget];
                [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:textureIndexOfTarget];
                
                if ([currentTarget wantsMonochromeInput] && captureAsYUV)
                {
                    [currentTarget setCurrentlyReceivingMonochromeInput:YES];
                    // TODO: Replace optimization for monochrome output
                    [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
                }
                else
                {
                    [currentTarget setCurrentlyReceivingMonochromeInput:NO];
                    [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
                }
            }
            else
            {
                [currentTarget setInputRotation:kGPUImageNoRotation atIndex:textureIndexOfTarget];
                [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
            }
        }
    }
    
    // Then release our hold on the local framebuffer to send it back to the cache as soon as it's no longer needed
    [outputFramebuffer unlock];
    outputFramebuffer = nil;
    
    // Finally, trigger rendering as needed
    for (id<GPUImageInput> currentTarget in targets)
    {
        if ([currentTarget enabled])
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                [currentTarget newFrameReadyAtTime:currentTime atIndex:textureIndexOfTarget];
            }
        }
    }
}

- (void)createVideoProgress {
    if (self.videoFormat == LYGPUInputVideoFormatRGB) {
        self.videoProgress = [[LYRGBVideoProgress alloc] init];
    }
}
@end
