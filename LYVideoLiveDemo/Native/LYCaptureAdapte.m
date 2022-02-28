//
//  LYCaptureAdapte.m
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import "LYCaptureAdapte.h"
#import "LYGPUInputFilter.h"
#import "LYEndFilter.h"

@interface  LYCaptureAdapter()
@property (nonatomic,strong)LYGPUInputFilter * inputFilter;
@property (nonatomic,strong)LYEndFilter * endFilter;
@property (nonatomic,strong)GPUImageFilter * filter;
@end
@implementation LYCaptureAdapter

- (void)pushVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!self.inputFilter) {
        self.inputFilter = [[LYGPUInputFilter alloc] initWithVideoFormat:LYGPUInputVideoFormatRGB];
        self.filter = [[GPUImageFilter alloc] init];
        [self.inputFilter addTarget:self.filter];
        [self.filter addTarget:self.renderView];
        
        self.endFilter = [[LYEndFilter alloc] init];
        [self.filter addTarget:self.endFilter];
    }
    [self.inputFilter progressSampleBuffer:sampleBuffer];
    
}
@end
