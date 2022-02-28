//
//  ViewController.m
//  LYVideoLiveDemo
//
//  Created by yoyo on 2022/2/20.
//

#import "ViewController.h"
#import "LYVideoCapture.h"
#import "LYCaptureAdapte.h"

@interface ViewController ()
@property (nonatomic,strong)LYVideoCapture * capture;
@property (nonatomic,strong)LYCaptureAdapter * adapter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.adapter = [[LYCaptureAdapter alloc] init];
    
    GPUImageView * renderView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 600)];
    self.adapter.renderView = renderView;
    
    self.capture = [[LYVideoCapture alloc] initWithAdapter:self.adapter];
    [self.capture startCapture];
    
  
    [self.view addSubview:renderView];
    
//    self.capture.mPreviewLayer.frame = CGRectMake(0, 0, 300, 500);
//    [self.view.layer addSublayer:self.capture.mPreviewLayer];
    
    
}


@end
