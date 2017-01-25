//
//  GDHLaunchAD.h
//  GDHLaunchADDemo
//
//  Created by 高得华 on 17/1/23.
//  Copyright © 2017年 GaoFei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+GDHWebCache.h"

#pragma mark - ========= Block ===========


/**!
 * 点击广告视图时回调block
 */
typedef void(^GDHLaunchADClickBlock)();


/**
 广告视图加载完成之后返回数据Block

 @param image 图片
 @param imageURL 图片Url
 */
typedef void(^GDHLaunchAdCallBackBlock)(UIImage * image, NSString * imageURL);


/**!
 * 播放完成时回调block
 */
typedef void(^GDHLaunchAdCompletePlayBlock)();


#pragma mark - ============= 枚举 ===============

typedef NS_ENUM(NSUInteger, GDHLaunchADSkipShowType){
    
    GDHLaunchADSkipShowTypeNone = 0,       /** 无跳过 */
    GDHLaunchADSkipShowTypeDefault,        /** 跳过+倒计时*/
    GDHLaunchADSkipShowTypeAnimation,      /** 动画跳过 ⭕️ */
};



#pragma mark - =========== GDHLaunchAD 视图 ===============


@interface GDHLaunchAD : UIView

/**
 初始化GDHLaunchAD视图

 @param frame 视图的大小及位置
 @param imageURL 视图图片的URL
 @param timeNumber 显示时间
 @param showSkipType 跳过按钮的类型
 @param options 图片缓存模式
 @param launchAdCallBack 广告图片加载完成 回调
 @param imageClick 点击广告视图时回调
 @param completePlay 广告播放完成时 回调
 @return GDHLaunchAD对象
 */
+ (instancetype)CreateGDHLaunchADFrame:(CGRect)frame
                              ImageURL:(NSString *)imageURL
                            TimeNumber:(NSInteger)timeNumber
                          showSkipType:(GDHLaunchADSkipShowType)showSkipType
                               options:(GDHWebImageOptions)options
                      LaunchAdCallBack:(GDHLaunchAdCallBackBlock)launchAdCallBack
                            ImageClick:(GDHLaunchADClickBlock)imageClick
                          CompletePlay:(GDHLaunchAdCompletePlayBlock)completePlay;

/**定时器*/
@property (nonatomic, copy ) dispatch_source_t timer;
/**广告停留时间*/
@property (nonatomic, assign) NSInteger adDuration;
/**点击之后剩余的广告停留时间*/
@property (nonatomic, assign) NSInteger ShengAdDuration;
/**是否点击了图片*/
@property (nonatomic, assign) BOOL isImageClick;


/**
 *  设置动画跳过属性
 *
 *  @param strokeColor     转动颜色
 *  @param lineWidth       宽度
 *  @param backgroundColor 背景色
 *  @param textColor       字体颜色
 */
- (void)setAnimationSkipWithAttribute:(UIColor *)strokeColor lineWidth:(NSInteger)lineWidth backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor;

/**添加动画*/
-(void)animation:(NSInteger)duration;

@end
