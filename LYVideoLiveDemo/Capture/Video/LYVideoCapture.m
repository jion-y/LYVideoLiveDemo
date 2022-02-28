//
//  LYVideoCapture.m
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/22.
//

#import "LYVideoCapture.h"
#import "LYCaptureAdapte.h"
@interface  LYVideoCapture()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic , strong) AVCaptureSession *mCaptureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic , strong) AVCaptureDeviceInput *mCaptureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureVideoDataOutput *mCaptureDeviceOutput; //

@property (nonatomic, strong) dispatch_queue_t mCaptureQueue;

@property (nonatomic,weak)id<LYVideoAdapteEable> adapter;
@end

@implementation LYVideoCapture

- (instancetype)initWithAdapter:(id<LYVideoAdapteEable>)adapter {
    self = [super init];
    if (self) {
        self.adapter = adapter;
        self.mCaptureQueue = dispatch_queue_create("com.ly.mCaptureQueue", DISPATCH_QUEUE_SERIAL);
        [self initSession];
    }
    return self;
}

- (void)initSession
{
    if (!self.mCaptureSession) {
        self.mCaptureSession = [[AVCaptureSession alloc] init];
        self.mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
        
        AVCaptureDevice *inputCamera = nil;
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices)
        {
            if ([device position] == AVCaptureDevicePositionFront)
            {
                inputCamera = device;
            }
        }
        
        self.mCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
        
        if ([self.mCaptureSession canAddInput:self.mCaptureDeviceInput]) {
            [self.mCaptureSession addInput:self.mCaptureDeviceInput];
        }
        
        self.mCaptureDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
        [self.mCaptureDeviceOutput setAlwaysDiscardsLateVideoFrames:NO];
        
        [self.mCaptureDeviceOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        [self.mCaptureDeviceOutput setSampleBufferDelegate:self queue:self.mCaptureQueue];
        if ([self.mCaptureSession canAddOutput:self.mCaptureDeviceOutput]) {
            [self.mCaptureSession addOutput:self.mCaptureDeviceOutput];
        }
        AVCaptureConnection *connection = [self.mCaptureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        
        self.mPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.mCaptureSession];
        [self.mPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    }
}

- (void)startCapture {
    [self.mCaptureSession startRunning];
}

- (void)stopCapture {
    [self.mCaptureSession stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (self.adapter && [self.adapter respondsToSelector:@selector(pushVideoSampleBuffer:)]) {
        [self.adapter pushVideoSampleBuffer:sampleBuffer];
    }
    
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"drop frame");
}
//- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"drop frame");
//}

@end
