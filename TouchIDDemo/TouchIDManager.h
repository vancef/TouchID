//
//  TouchIDManager.h
//  TouchIDDemo
//
//  Created by vance on 2017/3/6.
//  Copyright © 2017年 Vancef. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ErrorAuthenticationFailed @"身份验证并不成功，因为用户没有提供有效的凭证。"
#define ErrorUserCancel @"认证被取消了由用户(例如了取消按钮)。"
#define ErrorUserFallback @"身份验证被取消了，因为用户点击了后退按钮(输入密码)。"
#define ErrorSystemCancel @"身份验证被系统取消了(如另一个应用程序去前台)。"
#define ErrorPasscodeNotSet @"身份验证无法启动，因为密码不是在设备上设置的。"
#define ErrorTouchIDNotAvailable @"身份验证无法启动，因为设备上无法使用Touch ID。"
#define ErrorTouchIDNotEnrolled @"身份验证无法启动，因为Touch ID没有注册的手指。"
#define ErrorTouchIDLockout @"TouchID功能被锁定"
#define ErrorAppCancel @"APP被挂起"
#define ErrorInvalidContext @"LAContext传递给这个调用之前已经失效"
#define ErrorTouchIDFailure @"Touch ID失效"

#define TouchIDEvaluateSuccess @"指纹识别成功"
#define TouchIDNoSupport @"不支持TouchID"
#define ChangeTouchID @"指纹数据改变"

typedef void(^TouchIDManagerSuccessBlock)(NSString *message, NSData *evaluatedState);
typedef void(^TouchIDManagerFailureBlock)(NSString *message);
typedef void(^TouchIDManagerCancelBlock)(NSString *message);
typedef void(^TouchIDManagerFallbackBlock)(NSString *message);
typedef void(^TouchIDManagerChangeBlock)(NSString *message);
typedef void(^TouchIDManagerNoSupportBlock)(NSString *message);

@interface TouchIDManager : NSObject

/**
 检测是否支持TouchID
 
 @param support yes为设备支持，no为包括没有开启或设置密码
 @return 返回布尔值
 */
+ (BOOL)validateTouchID:(BOOL)support;

/**
 指纹识别
 
 @param localizedReason 标题
 @param cancelTitle 取消按钮标题，iOS 10可以自定义，内容为空不显示按钮
 @param fallbackTitle 密码按钮标题，内容为空不显示按钮
 @param evaluatedState 校验指纹改变数据
 @param successBlock 识别成功回调
 @param failureBlock 识别失败回调
 @param cancelBlock 取消识别回调
 @param fallbackBlock 密码回调
 @param changeBlock 指纹改变回调
 */
+ (void)touchIDWithLocalizedReason:(NSString *)localizedReason cancelTitle:(NSString *)cancelTitle fallbackTitle:(NSString *)fallbackTitle evaluatedState:(NSData*)evaluatedState successBlock:(TouchIDManagerSuccessBlock)successBlock failureBlock:(TouchIDManagerFailureBlock)failureBlock cancelBlock:(TouchIDManagerCancelBlock)cancelBlock fallbacekBlock:(TouchIDManagerFallbackBlock)fallbackBlock changeBlock:(TouchIDManagerChangeBlock)changeBlock;

@end
