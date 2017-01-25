//
//  GDHLaunchADViewController.h
//  GDHLaunchADDemo
//
//  Created by 高得华 on 17/1/24.
//  Copyright © 2017年 GaoFei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDHLaunchAD.h"
@class GDHLaunchADViewController;

#pragma mark - ============== Block ==============

/**
 加载完成视图图片

 @param image 图片
 @param imageURL 图片URL
 */
typedef void(^GDHLaunchADImageLoadedBlock)(UIImage * image, NSString * imageURL);


/**
 点击广告视图

 @param GDHLaunchADVC 广告视图控制器
 */
typedef void(^GDHLaunchADClickImageBlock)(GDHLaunchADViewController * GDHLaunchADVC);


/**
 广告加载完成Block
 */
typedef void(^GDHLaunchADCompleteBlock)();


@interface GDHLaunchADViewController : UIViewController


/**
 创建广告视图

 @param frame 广告视图的大小
 @param imageURL 图片URL
 @param timeNumber 广告时间
 @param strokeColor 转动时的⭕️颜色
 @param lineWidth 转动的线宽
 @param backgroundColor button 跳过按钮的背景颜色
 @param textColor 跳过按钮的字体颜色
 @param showSkipType 跳过 按钮样式
 @param options 广告图片缓存类型
 @param launchAdCallBack 加载完成广告图片
 @param imageClick 点击广告视图Block
 @param completePlay 广告图片播放完成
 */
+ (void)ShowGDHLaunchADFrame:(CGRect)frame
                    ImageURL:(NSString *)imageURL
                  timeNumber:(NSInteger)timeNumber
                 strokeColor:(UIColor *)strokeColor
                   lineWidth:(NSInteger)lineWidth
             backgroundColor:(UIColor *)backgroundColor
                   textColor:(UIColor *)textColor
                showSkipType:(GDHLaunchADSkipShowType)showSkipType
                     options:(GDHWebImageOptions)options
            LaunchAdCallBack:(GDHLaunchADImageLoadedBlock)launchAdCallBack
                  ImageClick:(GDHLaunchADClickImageBlock)imageClick
                CompletePlay:(GDHLaunchADCompleteBlock)completePlay;


@end
