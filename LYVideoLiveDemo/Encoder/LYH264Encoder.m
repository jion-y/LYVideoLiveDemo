//
//  LYH264Encoder.m
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/25.
//

#import "LYH264Encoder.h"
#import <VideoToolbox/VideoToolbox.h>

@interface LYH264Encoder() {
    VTCompressionSessionRef encodingSession;
}
@property(nonatomic,strong)dispatch_queue_t encoder_queue;
@property(nonatomic,copy)void(^ encoderCallbackBlock)(NSData * data) ;
@end
@implementation LYH264Encoder
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.width = -1;
        self.height = -1;
        self.encoder_queue = dispatch_queue_create("com.ly.encoder", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)initEncoder {
    
   OSStatus status = VTCompressionSessionCreate(NULL, self.width, self.height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self), &encodingSession);
    
    NSLog(@"H264: VTCompressionSessionCreate %d", (int)status);
    if (status != 0)
    {
        NSLog(@"H264: Unable to create a H264 session");
        return ;
    }
    
    // 设置实时编码输出（避免延迟）
    VTSessionSetProperty(encodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    VTSessionSetProperty(encodingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
    
    // 设置关键帧（GOPsize)间隔
    int frameInterval = 10;
    CFNumberRef  frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
    VTSessionSetProperty(encodingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
    
    // 设置期望帧率
    int fps = self.fps;
    CFNumberRef  fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
    VTSessionSetProperty(encodingSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
    
    
    //设置码率，均值，单位是byte
    int bitRate = self.width * self.height * 3 * 4 * 8;
    CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
    VTSessionSetProperty(encodingSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
    
    //设置码率，上限，单位是bps
    int bitRateLimit = self.width * self.height * 3 * 4;
    CFNumberRef bitRateLimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRateLimit);
    VTSessionSetProperty(encodingSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLimitRef);

    //不编码B帧
    VTSessionSetProperty(encodingSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
    
    // Tell the encoder to start encoding
    VTCompressionSessionPrepareToEncodeFrames(encodingSession);
    
}
- (void)encoderPixelBuffer:(CVPixelBufferRef)pixelBuffer completion:(void(^)(NSData * data))completion {
    self.encoderCallbackBlock = completion;
    CVPixelBufferRetain(pixelBuffer);
    dispatch_async(self.encoder_queue, ^{
        if (self.width <= 0) {
            self.width = (int32_t)CVPixelBufferGetWidth(pixelBuffer);
        }
        if (self.height <= 0) {
            self.height = (int32_t)CVPixelBufferGetHeight(pixelBuffer);
        }
        
        if (!self->encodingSession) {
            [self initEncoder];
        }
        
        CMTime presentationTimeStamp = CMTimeMake(100, 1000);
        VTEncodeInfoFlags flags;
        OSStatus statusCode = VTCompressionSessionEncodeFrame(self->encodingSession,
                                                              pixelBuffer,
                                                              presentationTimeStamp,
                                                              kCMTimeInvalid,
                                                              NULL, NULL, &flags);
        CVPixelBufferRelease(pixelBuffer);
        if (statusCode != noErr) {
            NSLog(@"H264: VTCompressionSessionEncodeFrame failed with %d", (int)statusCode);
            
            VTCompressionSessionInvalidate(self->encodingSession);
            CFRelease(self->encodingSession);
            self->encodingSession = NULL;
            return;
        }
        
    });
}

- (void)dealloc {
    VTCompressionSessionCompleteFrames(encodingSession, kCMTimeInvalid);
    VTCompressionSessionInvalidate(encodingSession);
    CFRelease(encodingSession);
    encodingSession = NULL;
}

// 编码完成回调
void didCompressH264(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer) {
    NSLog(@"didCompressH264 called with status %d infoFlags %d", (int)status, (int)infoFlags);
    if (status != 0) {
        return;
    }
    
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"didCompressH264 data is not ready ");
        return;
    }
    LYH264Encoder* encoder = (__bridge LYH264Encoder*)outputCallbackRefCon;
    
    NSMutableData * encoderData = [[NSMutableData alloc] init];
    
    bool keyframe = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    // 判断当前帧是否为关键帧
    // 获取sps & pps数据
    if (keyframe)
    {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
        if (statusCode == noErr)
        {
            // Found sps and now check for pps
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
            if (statusCode == noErr)
            {
                // Found pps
                NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                if (encoder)
                {
                    
                    const char bytes[] = "\x00\x00\x00\x01";
                    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
                    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
                    [encoderData appendData:ByteHeader];
                    [encoderData appendData:sps];
                    [encoderData appendData:ByteHeader];
                    [encoderData appendData:pps];
                }
            }
        }
    }
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4; // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
        // 循环获取nalu数据
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            uint32_t NALUnitLength = 0;
            // Read the NAL unit length
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            // 从大端转系统端
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            NSData* data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
            const char bytes[] = "\x00\x00\x00\x01";
            size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
            NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
            [encoderData appendData:ByteHeader];
            [encoderData appendData:data];
            // Move to the next NAL unit in the block buffer
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
        if (encoder.encoderCallbackBlock) {
            encoder.encoderCallbackBlock(encoderData);
        }
    }
}


@end
