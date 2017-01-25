//
//  GDHLaunchAD.m
//  GDHLaunchADDemo
//
//  Created by 高得华 on 17/1/23.
//  Copyright © 2017年 GaoFei. All rights reserved.
//

#import "GDHLaunchAD.h"
#import "GDHLKiPhoneInformationObject.h"

#define kScreen_Bounds  [UIScreen mainScreen].bounds
#define kScreen_Height  [UIScreen mainScreen].bounds.size.height
#define kScreen_Width   [UIScreen mainScreen].bounds.size.width
#define kDefaultDuration 3;//默认停留时间

@interface GDHLaunchAD ()

@property (nonatomic, copy  ) NSString * imageURL;
/**点击图片响应事件*/
@property (nonatomic, copy  ) GDHLaunchADClickBlock ImageClickBlock;
/**加载完成图片时的Block*/
@property (nonatomic, copy  ) GDHLaunchAdCallBackBlock callBackBlock;
/**完成播放时的Block*/
@property (nonatomic, copy  ) GDHLaunchAdCompletePlayBlock completeBlock;
/**跳过按钮的类型*/
@property (nonatomic, assign) GDHLaunchADSkipShowType  showSkipType;
/**跳过按钮*/
@property (nonatomic, strong) UIButton * btnSkip;
/**shapelayer*/
@property (nonatomic, strong) CAShapeLayer * shapelayer;
/**定时器*/
@property (nonatomic, copy ) dispatch_source_t noDataTimer;

/**!
 * 广告视图
 */
@property (nonatomic, strong) UIImageView * launchAdImageView;

/**!
 * 广告视图的Frame
 */
@property (nonatomic, assign) CGRect launchAdViewFrame;

@end

@implementation GDHLaunchAD

/**
 初始化GDHLaunchAD视图
 
 @param frame 视图的大小及位置
 @param imageURL 视图图片的URL
 @param timeNumber 显示时间
 @param showSkipType 跳过按钮的类型
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
                          CompletePlay:(GDHLaunchAdCompletePlayBlock)completePlay {
    GDHLaunchAD * ad     = [[GDHLaunchAD alloc] initWithFrame:frame TimeInteger:timeNumber];
    ad.launchAdViewFrame = frame;
    ad.showSkipType      = showSkipType;
    UIImage * image      = [UIImage imageNamed:[[GDHLKiPhoneInformationObject ShareObject] iPhoneCurrentAPPLaunchImage]];
    if (!image) {
        image = [[UIImage alloc] init];
    }
    [ad.launchAdImageView GDH_SetImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:image options:options completed:^(UIImage *image, NSURL *url) {
        if (url) {
            //图片加载完成时Block
            if (launchAdCallBack) {
                launchAdCallBack(image,imageURL);
            }
            //添加Button按钮
            [ad addSubview:ad.btnSkip];
        }
    }];
    
    //点击图片的Block
    ad.ImageClickBlock = ^(){
        if (imageClick) {
            imageClick();
        }
    };
    
    ad.completeBlock = ^(){
        if (completePlay) {
            completePlay();
        }
    };
    
    return ad;
}


- (instancetype)initWithFrame:(CGRect)frame TimeInteger:(NSInteger)TimeInteger{
    if ([super initWithFrame:frame]) {
        self.launchAdViewFrame = frame;
        self.adDuration        = TimeInteger;
        self.ShengAdDuration   = TimeInteger;
        [self startNoDataDispath_tiemr];
    }
    return self;
}



#pragma mark - ============== 开始计时 ===========

#pragma mark =============== 动画跳过 =========
- (void)layoutSubviews{
    if(self.showSkipType == GDHLaunchADSkipShowTypeAnimation) {
        self.btnSkip.frame = CGRectMake(kScreen_Width - 40,40, 30, 30);
        [self animation:self.adDuration];
    }
}
/**添加动画*/
-(void)animation:(NSInteger)duration{
    CABasicAnimation *pathAnimaton = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    pathAnimaton.duration = duration-1;
    CGFloat start = (CGFloat)(self.adDuration - duration) / (CGFloat)self.adDuration;
    pathAnimaton.fromValue = @(start);
    pathAnimaton.toValue = @(1.0f);
    [self.shapelayer addAnimation:pathAnimaton forKey:nil];
}
//设置属性
- (void)setAnimationSkipWithAttribute:(UIColor *)strokeColor lineWidth:(NSInteger)lineWidth  backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor{
    if(self.showSkipType == GDHLaunchADSkipShowTypeAnimation){
        self.shapelayer = [CAShapeLayer layer];
        UIBezierPath *BezierPath = [UIBezierPath bezierPathWithOvalInRect:self.btnSkip.bounds];
        self.shapelayer.lineWidth = lineWidth?lineWidth:3.0;
        self.shapelayer.strokeColor = [strokeColor?strokeColor:[UIColor redColor] CGColor];
        self.shapelayer.fillColor = [UIColor clearColor].CGColor;
        self.shapelayer.path = BezierPath.CGPath;
        self.btnSkip.backgroundColor = backgroundColor?backgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4];
        [self.btnSkip.layer addSublayer:self.shapelayer];
    }
}



- (void)animateStart{
    CGFloat duration = kDefaultDuration;
    if(self.adDuration) duration = self.adDuration;
    duration= duration/4.0;
    if(duration>1.0) duration=1.0;
    [UIView animateWithDuration:duration animations:^{
        self.launchAdImageView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)startNoDataDispath_tiemr{
    
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _noDataTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_noDataTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    
    __block NSInteger duration = 3;
    dispatch_source_set_event_handler(_noDataTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.btnSkip setTitle:self.showSkipType==1?[NSString stringWithFormat:@"%ld 跳过",(long)duration]:@"跳过" forState:UIControlStateNormal];
            if(duration == 1){
                dispatch_source_cancel(_noDataTimer);
                [self launchAdRemoveBtnAct];
            }
            duration--;
            self.ShengAdDuration = duration;
        });
    });
    dispatch_resume(_noDataTimer);
}

- (void)dispath_tiemr{
    
    if(self.noDataTimer) dispatch_source_cancel(self.noDataTimer);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    
    __block NSInteger duration = kDefaultDuration;
    if(self.adDuration) duration = self.adDuration;
    dispatch_source_set_event_handler(_timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.btnSkip setTitle:self.showSkipType==1?[NSString stringWithFormat:@"%ld 跳过",(long)duration]:@"跳过" forState:UIControlStateNormal];
            if(duration == 1){
                dispatch_source_cancel(_timer);
                [self launchAdRemoveBtnAct];
            }
            duration--;
            self.ShengAdDuration = duration;
        });
    });
    dispatch_resume(_timer);
}

- (void)dispatch_Remove{
    CGFloat duration = kDefaultDuration;
    if(self.adDuration) duration = self.adDuration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self launchAdRemoveBtnAct];
    });
}

#pragma mark - ============ 点击广告视图的响应事件 =========
- (void)tapAction:(UITapGestureRecognizer *)sender {
    if (self.ImageClickBlock) {
        self.ImageClickBlock();
        self.isImageClick = YES;
    }
}

#pragma mark - ============ 移除广告 ==============
- (void)launchAdRemove{
    [UIView animateWithDuration:1.0 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.transform = CGAffineTransformMakeScale(1.5, 1.5);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if(self.shapelayer) [self.shapelayer removeAllAnimations];
    }];
}
- (void)launchAdRemoveBtnAct{
    [self launchAdRemove];

    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.completeBlock) self.completeBlock();
    });
}


#pragma mark - =========== Setter方法 =========
#pragma mark ======= 设置广告Frame =====
- (void)setLaunchAdViewFrame:(CGRect)launchAdViewFrame{
    _launchAdViewFrame = launchAdViewFrame;
    self.launchAdImageView.frame = launchAdViewFrame;
}

#pragma mark - =========== 懒加载 ============
- (UIImageView *)launchAdImageView {// ====== 广告视图
    if (!_launchAdImageView) {
        _launchAdImageView = [[UIImageView alloc] initWithFrame:self.launchAdViewFrame];
        _launchAdImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [_launchAdImageView addGestureRecognizer:tap];
        [self addSubview:_launchAdImageView];
    }
    return _launchAdImageView;
}

- (UIButton *)btnSkip{// ==== 跳过按钮
    if(!_btnSkip){
        _btnSkip = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSkip.frame = self.showSkipType==1?CGRectMake(kScreen_Width-70,30, 60, 30):CGRectMake(kScreen_Width-50,30, 30, 30);
        _btnSkip.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _btnSkip.layer.cornerRadius = self.showSkipType==1?15:15;
        _btnSkip.titleLabel.font = [UIFont systemFontOfSize:self.showSkipType==1?13.5:12];
        NSInteger duration = kDefaultDuration;
        if(self.adDuration) duration = self.adDuration;
        [_btnSkip setTitle:self.showSkipType == 1?[NSString stringWithFormat:@"%ld 跳过",(long)duration]:@"跳过" forState:UIControlStateNormal];
        [_btnSkip addTarget:self action:@selector(launchAdRemoveBtnAct) forControlEvents:UIControlEventTouchUpInside];
        [self dispath_tiemr];
    }
    return _btnSkip;
}



- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
