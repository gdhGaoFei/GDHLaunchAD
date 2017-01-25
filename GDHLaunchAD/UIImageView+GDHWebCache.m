//
//  UIImageView+GDHWebCache.m
//  GDHLaunchADDemo
//
//  Created by 高得华 on 17/1/24.
//  Copyright © 2017年 GaoFei. All rights reserved.
//

#import "UIImageView+GDHWebCache.h"
#import "GDHLKEnDeHeader.h"//加密解密
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "objc/runtime.h"
#import <CommonCrypto/CommonDigest.h>

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...)
#endif

static char imageURLKey;

#pragma mark - ======== GDHWebCacheImageDownloader ========

@implementation GDHWebCacheImageDownloader

/**
 *  缓冲路径
 *
 *  @return 路径
 */
+ (NSString *)CacheImagePath {
    NSString *path =[NSHomeDirectory() stringByAppendingPathComponent:@"Library/GDHLaunchAdCache"];
    [self CheckDirectory:path];
    return path;
}

/**
 *  检查目录
 *
 *  @param path 路径
 */
+(void)CheckDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) { //判断是否为文件夹
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

#pragma mark ===== 在目录创建文件 =========
+ (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        DebugLog(@"create cache directory failed, error = %@", error);
    } else {
        DebugLog(@"LaunchAdCachePath:%@",path);
        // 标记无需备份目录
        NSURL *url = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (error) {
            DebugLog(@"error to set do not backup attribute, error = %@", error);
        }
    }
}

#pragma mark - 得到图片缓冲
+(UIImage *)getCacheImageWithURL:(NSURL *)url{
    if(!url) return nil;
    NSString *directoryPath = [self CacheImagePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      directoryPath,[GDHLKEnDe MD5_GDHTYPE:GDHMD5TYPE_32Bit encryption:url.absoluteString capital:NO]];
    return [UIImage GDHGifWithData:[NSData dataWithContentsOfFile:path]];
}

#pragma mark - 刷新图片缓冲
+(void)saveImage:(NSData *)data imageURL:(NSURL *)url{
    NSString *path = [NSString stringWithFormat:@"%@/%@",[self CacheImagePath],[GDHLKEnDe MD5_GDHTYPE:GDHMD5TYPE_32Bit encryption:url.absoluteString capital:NO]];
    if (data) {
        BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        if (!isOk) DebugLog(@"cache file error for URL: %@", url);
    }
}



@end

#pragma mark - ======== Gif图片 GDHGif =========

@implementation UIImage (GDHGif)

/**
 *  NSData -> UIImage
 *
 *  @param data Data
 *
 *  @return UIImage
 */
+ (UIImage *)GDHGifWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    UIImage * gifImage = nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    if (imageSource == NULL) {
        fprintf(stderr, "Image source is NULL\n");
    }else{
        CFStringRef imageType = CGImageSourceGetType(imageSource);
        // make sure the image's format is GIF
        if ([(__bridge NSString *)imageType isEqualToString:(NSString *)kUTTypeGIF]) {
            // how many frames in the gif image
            size_t frameCount = CGImageSourceGetCount(imageSource);
            NSMutableArray * frames = [NSMutableArray arrayWithCapacity:frameCount];
            NSTimeInterval animationDuration = 0.0;
            for (size_t i = 0; i< frameCount; i++) {
                CFDictionaryRef propertDic = CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
                // change the animation duration
                CFDictionaryRef gifDic = CFDictionaryGetValue(propertDic, kCGImagePropertyGIFDictionary);
                CFStringRef delayTimeRef = CFDictionaryGetValue(gifDic, kCGImagePropertyGIFDelayTime);
                animationDuration += [(__bridge NSString *)delayTimeRef doubleValue];
                CFRelease(propertDic);
                CGImageRef imgRef = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
                if (imgRef) {
                    [frames addObject:[UIImage imageWithCGImage:imgRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
                    CGImageRelease(imgRef);
                }
            }
            gifImage = [UIImage animatedImageWithImages:frames duration:animationDuration];
        }else {
            gifImage = [[UIImage alloc] initWithData:data];
        }
        CFRelease(imageSource);
    }
    return gifImage;
}

@end



#pragma mark - ======== 图片缓存 GDHWebCache ===========

@implementation UIImageView (GDHWebCache)

/**
 *  获取当前图像的URL
 */
- (NSURL *)GDH_ImageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

/**
 *  异步加载网络图片+缓存
 *
 *  @param url            图片url
 *  @param placeholderImage    默认图片
 *  @param completedBlock 加载完成回调
 */
- (void)GDH_SetImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholderImage
                  completed:(GDHWebImageCompletionBlock)completedBlock {
      [self GDH_SetImageWithURL:url placeholderImage:placeholderImage options:GDHWebImageDefault completed:completedBlock];
}

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
                 completed:(GDHWebImageCompletionBlock)completedBlock {
    if (placeholderImage) self.image = placeholderImage;
    if (url) {
        __weak typeof(self)weakSelf = self;
        objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if(!options) options = GDHWebImageDefault;
        //只加载,不缓存
        if(options&GDHWebImageOnlyLoad){
            [self dispatch_async:url result:^(UIImage *image, NSURL *url, NSData *data) {
                weakSelf.image = image;
                if(image&&completedBlock) completedBlock(image, url);
            }];
            return;
        }
        //有缓存,读取缓存,不重新加载,没缓存先加载,并缓存
        UIImage *image = [GDHWebCacheImageDownloader getCacheImageWithURL:url];
        if(image && completedBlock){
            weakSelf.image = image;
            if(image && completedBlock) completedBlock(image,url);
            if(options & GDHWebImageDefault) return;
        }
        //先读缓存,再加载刷新图片和缓存
        [self dispatch_async:url result:^(UIImage *image, NSURL *url, NSData *data) {
            weakSelf.image = image;
            if(image&&completedBlock) completedBlock(image,url);
            [GDHWebCacheImageDownloader saveImage:data imageURL:url];
        }];
    }
}

#pragma mark - 异步加载图片
- (void)dispatch_async:(NSURL *)url result:(GDHDispatch_asyncBlock)result{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage GDHGifWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) result(image,url, data);
        });
    });
}


@end
