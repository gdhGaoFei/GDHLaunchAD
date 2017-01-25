//
//  GDHLaunchADViewController.m
//  GDHLaunchADDemo
//
//  Created by 高得华 on 17/1/24.
//  Copyright © 2017年 GaoFei. All rights reserved.
//

#import "GDHLaunchADViewController.h"

@interface GDHLaunchADViewController ()

@property (nonatomic, strong)  GDHLaunchAD *LaunchAD;

@end

@implementation GDHLaunchADViewController


-(void)viewWillAppear:(BOOL)animated{
    if(self.LaunchAD.timer && self.LaunchAD.adDuration > 0 && self.LaunchAD.isImageClick){
        NSLog(@"==========%ld========",self.LaunchAD.ShengAdDuration);
        [self.LaunchAD animation:self.LaunchAD.ShengAdDuration];
        dispatch_resume(self.LaunchAD.timer);
    }
    self.LaunchAD.isImageClick = NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    if(self.LaunchAD.timer && self.LaunchAD.adDuration > 0 && self.LaunchAD.isImageClick){
        dispatch_suspend(self.LaunchAD.timer);
    }
}


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
                CompletePlay:(GDHLaunchADCompleteBlock)completePlay {
    
    GDHLaunchADViewController * adVC = [[GDHLaunchADViewController alloc] init];
    adVC.LaunchAD = [GDHLaunchAD CreateGDHLaunchADFrame:frame ImageURL:imageURL TimeNumber:timeNumber showSkipType:showSkipType options:options LaunchAdCallBack:^(UIImage *image, NSString *imageURL) {
        if (launchAdCallBack) {
            launchAdCallBack(image, imageURL);
        }
    } ImageClick:^{
        if (imageClick) {
            imageClick(adVC);
        }
    } CompletePlay:^{
        if (completePlay) {
            completePlay();
        }
    }];
    
    [adVC.LaunchAD setAnimationSkipWithAttribute:strokeColor lineWidth:lineWidth backgroundColor:backgroundColor textColor:textColor];
    
    [adVC.view addSubview:adVC.LaunchAD];
    [[UIApplication sharedApplication].delegate window].rootViewController = adVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
