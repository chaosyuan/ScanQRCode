//
//  ViewController.m
//  iOS二维码扫描
//
//  Created by yuanwei on 15/4/27.
//  Copyright (c) 2015年 YuanWei. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "QRCodeReaderViewController.h"
#import "ScanQRCode.h"

@interface ViewController ()<QRCodeReaderDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    int padding1 = 10;
    
    UIButton *btn1 = [UIButton new];
    btn1.backgroundColor = [UIColor purpleColor];
    [btn1 addTarget:self action:@selector(pushNextOne) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton new];
    btn2.backgroundColor = [UIColor purpleColor];
    [btn2 addTarget:self action:@selector(pushNextTwo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    
    typeof(&*self) __weak weakSelf = self;
    
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(weakSelf.view.mas_centerY);
        make.left.equalTo(weakSelf.view.mas_left).with.offset(padding1);
        make.right.equalTo(btn2.mas_left).with.offset(-padding1);
        make.height.mas_equalTo(@150);
        make.width.equalTo(btn2);
    }];
    
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(weakSelf.view.mas_centerY);
        make.left.equalTo(btn1.mas_right).with.offset(padding1);
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-padding1);
        make.height.mas_equalTo(@150);
        make.width.equalTo(btn1);
    }];
}

- (void)pushNextTwo
{
    ScanQRCode *qrVc  = [[ScanQRCode alloc] init];
    
    [qrVc setScanCompleteBlock:^(id result){
        
        NSString *QRTeststring = (NSString *)result;
        
        NSLog(@"QRTeststring===%@",QRTeststring);
    
    }];
    [self.navigationController pushViewController:qrVc animated:YES];
    
}

- (void)pushNextOne
{
    QRCodeReaderViewController *reader = [QRCodeReaderViewController new];
    reader.delegate = self;
    
    __weak  typeof(&*self)  weakSelf = self;
    
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
        [[[UIAlertView alloc] initWithTitle:@"" message:resultAsString delegate:weakSelf cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    
    [self.navigationController pushViewController:reader animated:YES];
    
}
#pragma mark -
#pragma mark - QRCodeReader Delegate Methods
#pragma mark -
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QRCodeReader" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
