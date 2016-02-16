//
//  ScanQRCode.m
//  iOS二维码扫描
//
//  Created by yuanwei on 15/4/27.
//  Copyright (c) 2015年 YuanWei. All rights reserved.
//

//获取屏幕信息（尺寸，宽，高）
#define LcdSize     [[UIScreen mainScreen] bounds]
#define LCDW        LcdSize.size.width
#define LCDH        LcdSize.size.height

//动画key
#define scanLineAnimationKey     @"scanLineAnimation"

//color
#define makeColor(_r, _g, _b, _a)   [UIColor colorWithRed:(float)_r/255 green:(float)_g/255 blue:(float)_b/255 alpha:_a]

#import "ScanQRCode.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <ZBarSDK.h>

@interface ScanQRCode ()<ZBarReaderViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureMetadataOutputObjectsDelegate,UIApplicationDelegate>

@property (strong,nonatomic) ZBarReaderView *reader;
@property (strong,nonatomic) UIImageView *boardView;
@property (strong,nonatomic) UIView *scanView;
@property (assign,nonatomic) BOOL isSpark;
@property (nonatomic,strong) AVAudioPlayer  *beepPlayer;
@property (strong, nonatomic) UIImageView          *imgLine;
@property (strong, nonatomic) UILabel              *lblTip;

@end

@implementation ScanQRCode


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString * wavPath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"];
        NSData* data       = [[NSData alloc] initWithContentsOfFile:wavPath];
        _beepPlayer        = [[AVAudioPlayer alloc] initWithData:data error:nil];
        
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:@"kAppDidBecomeActive" object:nil];
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"ZBarSDk";
    
    [self initScanView];

    //启动扫描
    [_reader start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.imgLine.layer removeAnimationForKey:scanLineAnimationKey];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self beginAnimation];
}
- (void)initScanView
{
    //ZBarReaderView配置
    _reader = [[ZBarReaderView alloc] init];
    _reader.readerDelegate = self;
    _reader.frame = self.view.frame;
    _reader.backgroundColor = [UIColor clearColor];
    _reader.torchMode = 0;
    _reader.allowsPinchZoom = YES;
    _reader.trackingColor = [UIColor greenColor];
    _reader.showsFPS = NO;
    _reader.scanCrop = CGRectMake(0.1, 0.3, 0.8, 0.4);
    ZBarImageScanner * scanner = _reader.scanner;
    [scanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];
    
     [self.view addSubview:_reader];
    
    
    CGFloat c_width  = LCDW - 100;
    CGFloat s_height = LCDH - 40;
    CGFloat y = (s_height - c_width) / 2 - s_height / 6;
    
    _lblTip = [[UILabel alloc] initWithFrame:CGRectMake(0,y + 90 + c_width + 30, LCDW, 15)];
    _lblTip.text = @"将二维码放入框内,即可自动扫描";
    _lblTip.textColor = [UIColor whiteColor];
    _lblTip.font = [UIFont systemFontOfSize:15];
    _lblTip.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lblTip];
    
    CGFloat corWidth = 16;
    
    UIImageView* img1 = [[UIImageView alloc] initWithFrame:CGRectMake(49, y + 76+ 30, corWidth, corWidth)];
    img1.image = [UIImage imageNamed:@"cor1"];
    [self.view addSubview:img1];
    
    UIImageView* img2 = [[UIImageView alloc] initWithFrame:CGRectMake(35 + c_width, y + 76+ 30, corWidth, corWidth)];
    img2.image = [UIImage imageNamed:@"cor2"];
    [self.view addSubview:img2];
    
    UIImageView* img3 = [[UIImageView alloc] initWithFrame:CGRectMake(49, y + c_width + 64+ 30, corWidth, corWidth)];
    img3.image = [UIImage imageNamed:@"cor3"];
    [self.view addSubview:img3];
    
    UIImageView* img4 = [[UIImageView alloc] initWithFrame:CGRectMake(35 + c_width, y + c_width + 64+ 30, corWidth, corWidth)];
    img4.image = [UIImage imageNamed:@"cor4"];
    [self.view addSubview:img4];
    
    _imgLine = [[UIImageView alloc] init];
    
    _imgLine.image = [UIImage imageNamed:@"barcode_effect_line2"];
    [self.view addSubview:_imgLine];
    [self addOtherLay:CGRectMake(50, y + 107, 220, 220)];
}
#pragma mark 启动动画
- (void)beginAnimation
{
    CGFloat c_width  = LCDW - 100;
    CGFloat s_height = LCDH - 40;
    CGFloat y = (s_height - c_width) / 2 - s_height / 6;
    _imgLine.frame = CGRectMake(52,  y + 106, LCDW-104, 12);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.fromValue      = [NSNumber numberWithInt:0];
    animation.toValue        = [NSNumber numberWithDouble:c_width-8];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration       = 2;
    animation.repeatCount    = HUGE_VALF;
    animation.autoreverses   = YES;
    [_imgLine.layer addAnimation:animation forKey:scanLineAnimationKey];
}
#pragma mark 返回上一个视图
- (void)pressReturnBtn
{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 打开相册
- (void)pressPhoneBtn
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
#pragma mark 设置闪光灯开关
- (void)pressSparkBtn:(UIButton *)button
{
    if (_isSpark == NO) {
        _reader.torchMode = 1;
        [button setImage:[UIImage imageNamed:@"QRCode_scan_spark_on@2x"] forState:UIControlStateNormal];
        _isSpark = !_isSpark;
    }else{
        _reader.torchMode = 0;
        [button setImage:[UIImage imageNamed:@"QRCode_scan_spark@2x"] forState:UIControlStateNormal];
        _isSpark = !_isSpark;
    }
}
#pragma mark 调整焦距
- (void)cameraTransform:(UISlider *)slider
{
    [_reader setZoom:slider.value animated:YES];
}
#pragma mark ZBarReaderViewDelegate
- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image;
{
    static NSString *text = nil;
    ZBarSymbol *symbol = nil ;
    for (symbol in symbols) {
        break;
    }
    text = symbol.data;
    // 解决中文乱码问题
    if  ([text  canBeConvertedToEncoding : NSShiftJISStringEncoding ]) {
        text = [ NSString   stringWithCString :[text  cStringUsingEncoding : NSShiftJISStringEncoding ]  encoding : NSUTF8StringEncoding ];
    }
    [_reader stop];
    
    if (self.scanCompleteBlock) {
        [_beepPlayer play];
        self.scanCompleteBlock(text);
    }
    
    [self popToPreviousController];
}
#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGImageRef cgImageRef = image.CGImage;
    
    ZBarImage *zBarImage = [[ZBarImage alloc] initWithCGImage:cgImageRef];
    [_reader.scanner scanImage:zBarImage];
    
    ZBarSymbolSet* symbols = _reader.scanner.results;
    
    ZBarSymbol* symbol = nil;
    
    for(symbol in symbols)
        break;
    
    //result
    NSString *text = symbol.data;
    
    // 解决中文乱码问题
    if  ([text  canBeConvertedToEncoding : NSShiftJISStringEncoding ]) {
        text = [ NSString   stringWithCString :[text  cStringUsingEncoding : NSShiftJISStringEncoding ]  encoding : NSUTF8StringEncoding ];
    }
    
    [_reader stop];
    
    if (self.scanCompleteBlock) {
        self.scanCompleteBlock(text);
    }
    
    [self popToPreviousController];
}
- (void)popToPreviousController
{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addOtherLay:(CGRect)rect
{
    CAShapeLayer* layerTop   = [[CAShapeLayer alloc] init];
    layerTop.fillColor       = [UIColor blackColor].CGColor;
    layerTop.opacity         = 0.6;
    layerTop.path            = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, LCDW, rect.origin.y)].CGPath;
    [self.reader.layer addSublayer:layerTop];
    
    CAShapeLayer* layerLeft   = [[CAShapeLayer alloc] init];
    layerLeft.fillColor       = [UIColor blackColor].CGColor;
    layerLeft.opacity         = 0.6;
    layerLeft.path            = [UIBezierPath bezierPathWithRect:CGRectMake(0,
                                                                            rect.origin.y ,
                                                                            50,
                                                                            LCDH)].CGPath;
    [self.reader.layer addSublayer:layerLeft];
    
    CAShapeLayer* layerRight   = [[CAShapeLayer alloc] init];
    layerRight.fillColor       = [UIColor blackColor].CGColor;
    layerRight.opacity         = 0.6;
    layerRight.path            = [UIBezierPath bezierPathWithRect:CGRectMake([UIScreen mainScreen].bounds.size.width - 50,
                                                                             rect.origin.y ,
                                                                             50,
                                                                             [UIScreen mainScreen].bounds.size.height)].CGPath;
    [self.reader.layer addSublayer:layerRight];
    
    
    CGFloat c_width  = LCDW - 100;
    CGFloat s_height = LCDH - 40;
    CGFloat y = (s_height - c_width) / 2 - s_height / 6;
    CAShapeLayer* layerBottom   = [[CAShapeLayer alloc] init];
    layerBottom.fillColor       = [UIColor blackColor].CGColor;
    layerBottom.opacity         = 0.6;
    layerBottom.path            = [UIBezierPath bezierPathWithRect:CGRectMake(50,
                                                                              (y + c_width + 108),
                                                                              [UIScreen mainScreen].bounds.size.width - 100,
                                                                              LCDH - (y + c_width + 94))].CGPath;
    [self.reader.layer addSublayer:layerBottom];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
