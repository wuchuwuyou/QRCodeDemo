//
//  ViewController.m
//  QRCodeDemo
//
//  Created by Tiny on 15/4/22.
//  Copyright (c) 2015年 Tianjin TianFang Science and Technology Development Co.,Ltd. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic,assign) IBOutlet UIView *carmeraView;
@property (nonatomic,assign) IBOutlet UILabel *resultLabel;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UIView *lineView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.carmeraView.frame.size.width, 1)];
    self.lineView.backgroundColor = [UIColor blackColor];
    
    [self.carmeraView addSubview:self.lineView];
    [self setupCarmera];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_session && ![_session isRunning]) {
        [_session startRunning];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_session stopRunning];
    [_timer invalidate];
}
- (void)animation1{
    CGFloat top = self.lineView.frame.origin.y;
    if (top >= self.carmeraView.frame.size.height) {
        top = 0;
    }
    top ++;
    self.lineView.frame = CGRectMake(0, top, self.carmeraView.frame.size.width, 1);
}
- (void)setupCarmera{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        
        _output =[[AVCaptureMetadataOutput alloc] init];
        
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        _session = [[AVCaptureSession alloc] init];
        
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        if ([_session canAddInput:_input]) {
            [_session addInput:_input];
        }
        
        if ([_session canAddOutput:_output]) {
            [_session addOutput:_output];
        }
       
        NSLog(@"%@",_output.availableMetadataObjectTypes);
        _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
            
            _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            _preview.frame = self.carmeraView.bounds;
            
            [self.carmeraView.layer insertSublayer:_preview atIndex:0];
            
            [_session startRunning];
        });
        
    });
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue;
    
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        
        stringValue = metadataObject.stringValue;
        dispatch_async(dispatch_get_main_queue(), ^{
           
            self.resultLabel.text = stringValue;
            
        });
    }
    
    [_session stopRunning];
    [_timer invalidate];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
