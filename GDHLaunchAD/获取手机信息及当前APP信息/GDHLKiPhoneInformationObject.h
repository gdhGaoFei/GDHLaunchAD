//
//  GDHLKiPhoneInformationObject.h
//  GDHChatTest
//
//  Created by 高得华 on 16/12/14.
//  Copyright © 2016年 GaoFei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GDHLKiPhoneInformationObject : NSObject

/**
 单例

 @return GDHLKiPhoneInformationObject的对象
 */
+ (GDHLKiPhoneInformationObject *)ShareObject;

/**
 获取电池电量
 
 @return 电量
 */
- (NSString *)iPhoneBatteryQuantity;

/**
 获取电池状态(UIDeviceBatteryState为枚举类型)

 @return 当前电池什么状态
 */
- (NSString *)iPhoneBatteryStauts;

/**
 获取总内存大小

 @return 手机内存大小
 */
- (NSString *)iPhoneTotalMemorySize;

/**
 获取当前可用内存

 @return 获取当前可用内存
 */
- (NSString *)iPhoneAvailableMemorySize;

/**
 手机型号

 @param controller 当前视图控制器
 @return 手机型号
 */
- (NSString *)iPhoneCurrentDevice:(UIViewController *)controller;

/**
 IP地址 （只适用于WiFi）

 @return IP地址 （只适用于WiFi）
 */
- (NSString *)iPhoneDeviceIPAdressOnWiFi;

/**
 设备当前网络IP地址 (WiFi 手机流量通用)

 @return 设备当前网络IP地址 (WiFi 手机流量通用)
 */
- (NSString *)iPhoneDeviceIPAdressOnAll;

/**
 当前手机连接的WIFI名称(SSID)

 @return 当前手机连接的WIFI名称(SSID)
 */
- (NSString *)iPhoneDeviceIPWiFiName;

/**
 获取当前APP的Icon的图片名称

 @return Icon的图片名称
 */
- (NSString *)iPhoneCurrentAPPIcon;

/**
 获取当前启动页的图片名称

 @return 启动页的图片名称
 */
- (NSString *)iPhoneCurrentAPPLaunchImage;

@end
