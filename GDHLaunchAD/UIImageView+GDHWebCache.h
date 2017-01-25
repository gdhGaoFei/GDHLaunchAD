//
//  UIImageView+GDHWebCache.h
//  GDHLaunchADDemo
//
//  Created by 高得华 on 17/1/24.
//  Copyright © 2017年 GaoFei. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - ========= Block 及 枚举 ===========
typedef NS_ENUM(NSUInteger, GDHWebImageOptions) {
    GDHWebImageDefault = 1 << 0,         // 有缓存,读取缓存,不重新加载,没缓存先加载,并缓存
    GDHWebImageOnlyLoad = 1 << 1,        // 只加载,不缓存
    GDHWebImageRefreshCached = 1 << 2    // 先读缓存,再加载刷新图片和缓存
};

typedef void(^GDHWebImageCompletionBlock)(UIImage *image, NSURL *url);
typedef void(^GDHDispatch_asyncBlock)(UIImage *image, NSURL *url, NSData *data);

#pragma mark - ====== 图片缓存及清理管理器 ==========

@interface GDHWebCacheImageDownloader : NSObject

/**
 *  缓冲路径
 *
 *  @return 路径
 */
+ (NSString *)CacheImagePath;

/**
 *  检查目录
 *
 *  @param path 路径
 */
+(void)CheckDirectory:(NSString *)path;


@end


#pragma mark - ========== Gif图片加载 =======

@interface UIImage (GDHGif)

/**
 *  NSData -> UIImage
 *
 *  @param data Data
 *
 *  @return UIImage
 */
+ (UIImage *)GDHGifWithData:(NSData *)data;

@end



#pragma mark - ======== 图片缓存 ===========

@interface UIImageView (GDHWebCache)

/**
 *  获取当前图像的URL
 */
- (NSURL *)GDH_ImageURL;

/**
 *  异步加载网络图片+缓存
 *
 *  @param url            图片url
 *  @param placeholderImage    默认图片
 *  @param completedBlock 加载完成回调
 */
- (void)GDH_SetImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholderImage
                  completed:(GDHWebImageCompletionBlock)completedBlock;

/**
 *  异步加载网络图片+缓存
 *
 *  @param url            图片url
 *  @param placeholderImage    默认图片
 *  @param options        缓存机制
 *  @param completedBlock 加载完成回调
 */
-(void)GDH_SetImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholderImage
                   options:(GDHWebImageOptions)options
                 completed:(GDHWebImageCompletionBlock)completedBlock;

@end
