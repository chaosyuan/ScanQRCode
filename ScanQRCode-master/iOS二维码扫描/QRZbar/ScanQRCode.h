//
//  ScanQRCode.h
//  iOS二维码扫描
//
//  Created by yuanwei on 15/4/27.
//  Copyright (c) 2015年 YuanWei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^yw_void_block_id)(id);

@interface ScanQRCode : UIViewController

@property (nonatomic,copy) yw_void_block_id  scanCompleteBlock;

@end
