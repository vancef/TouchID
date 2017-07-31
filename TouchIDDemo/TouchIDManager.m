//
//  TouchIDManager.m
//  TouchIDDemo
//
//  Created by vance on 2017/3/6.
//  Copyright © 2017年 Vancef. All rights reserved.
//

#import "TouchIDManager.h"
#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

#define Later(Version) [UIDevice currentDevice].systemVersion.floatValue >= Version

@implementation TouchIDManager

/**
 检测是否支持TouchID
 
 @param support yes为设备支持，no为包括没有开启或设置密码
 @return 返回布尔值
 */
+ (BOOL)validateTouchID:(BOOL)support {
    //创建LAContext
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if (Later(8.0)) {//iOS8以上
        if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            if (support) {
                if (error.code == LAErrorTouchIDNotAvailable) {//不支持指纹识别
                    return NO;//不支持指纹识别
                } else {
                    return YES;
                }
            } else {
                if (error.code == LAErrorTouchIDNotAvailable) {//不支持指纹识别
                    return NO;//不支持指纹识别
                } else if (error.code == LAErrorTouchIDNotEnrolled) {//未开启
                    return NO;
                } else if (error.code == LAErrorPasscodeNotSet) {//未设置密码
                    return NO;
                } else {
                    return YES;
                }
            }
        } else {
            return YES;//开启指纹识别
        }
    } else {//iOS8以下
        return NO;//不支持指纹识别
    }
}

/**
 检测TouchID-返回信息
 
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @param noSupportBlock 不支持回调
 */
+ (void)validateTouchIDWithsuccessBlock:(TouchIDManagerSuccessBlock)successBlock failureBlock:(TouchIDManagerFailureBlock)failureBlock noSupport:(TouchIDManagerNoSupportBlock)noSupportBlock {
    //创建LAContext
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if (Later(8.0)) {//iOS8以上
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            successBlock(TouchIDEvaluateSuccess, nil);
        } else {
            [self errorHandle:error.code failureBlock:failureBlock cancelBlock:nil fallbacekBlock:nil];
        }
    } else {//iOS8以下
        noSupportBlock(TouchIDNoSupport);//不支持指纹识别
    }
}

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
+ (void)touchIDWithLocalizedReason:(NSString *)localizedReason cancelTitle:(NSString *)cancelTitle fallbackTitle:(NSString *)fallbackTitle evaluatedState:(NSData*)evaluatedState successBlock:(TouchIDManagerSuccessBlock)successBlock failureBlock:(TouchIDManagerFailureBlock)failureBlock cancelBlock:(TouchIDManagerCancelBlock)cancelBlock fallbacekBlock:(TouchIDManagerFallbackBlock)fallbackBlock changeBlock:(TouchIDManagerChangeBlock)changeBlock {
    //创建LAContext
    LAContext *context = [[LAContext alloc] init];
    if (Later(10.0)) {//iOS10以上
        context.localizedCancelTitle = cancelTitle;//可以自定义取消按钮文字，内容为空不显示按钮
    }
    if (!fallbackTitle || fallbackTitle.length == 0) {
        context.localizedFallbackTitle = @"";//内容为空不显示按钮
    } else {
        context.localizedFallbackTitle = fallbackTitle;//内容为空不显示按钮
    }
    [self evaluatePolicy:context localizedReason:localizedReason evaluatedState:evaluatedState successBlock:^(NSString *message, NSData *evaluatedState) {
        if (successBlock) {
            successBlock(message, evaluatedState);
        }
    } failureBlock:^(NSString *message) {
        if (failureBlock) {
            failureBlock(message);
        }
    } cancelBlock:^(NSString *message) {
        if (cancelBlock) {
            cancelBlock(message);
        }
    } fallbacekBlock:^(NSString *message) {
        if (fallbackBlock) {
            fallbackBlock(message);
        }
    } changeBlock:^(NSString *message) {
        if (changeBlock) {
            changeBlock(message);
        }
    }];
}

+ (void)evaluatePolicy:(LAContext *)context localizedReason:(NSString *)localizedReason evaluatedState:(NSData*)evaluatedState successBlock:(TouchIDManagerSuccessBlock)successBlock failureBlock:(TouchIDManagerFailureBlock)failureBlock cancelBlock:(TouchIDManagerCancelBlock)cancelBlock fallbacekBlock:(TouchIDManagerFallbackBlock)fallbackBlock changeBlock:(TouchIDManagerChangeBlock)changeBlock {
    NSError *evaluateError = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&evaluateError]) {
        if (!evaluatedState || [context.evaluatedPolicyDomainState isEqualToData:evaluatedState]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:localizedReason reply:^(BOOL success, NSError * _Nullable error) {
                //指纹识别使用子线程，识别完毕调用主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        //验证成功
                        successBlock(TouchIDEvaluateSuccess, context.evaluatedPolicyDomainState);
                    } else {//失败结果处理
                        [self errorHandle:error.code failureBlock:failureBlock cancelBlock:cancelBlock fallbacekBlock:fallbackBlock];
                    }
                });
            }];
        } else {//指纹数据改变
            if (changeBlock) {
                changeBlock(ChangeTouchID);
            }
        }
    } else {
        if (evaluateError.code == LAErrorTouchIDLockout) {//指纹被锁定，触发验证密码
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:localizedReason reply:^(BOOL success, NSError * _Nullable error) {
                //指纹识别使用子线程，识别完毕调用主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!success) {//失败结果处理，验证密码后，激活指纹
                        [self errorHandle:error.code failureBlock:failureBlock cancelBlock:cancelBlock fallbacekBlock:fallbackBlock];
                    }
                });
            }];
        } else {
            [self errorHandle:evaluateError.code failureBlock:failureBlock cancelBlock:cancelBlock fallbacekBlock:fallbackBlock];
        }
    }
}

/**
 指纹识别错误处理
 
 @param error 错误码
 @param failureBlock 识别失败回调
 @param cancelBlock 取消识别回调
 @param fallbackBlock 密码回调
 */
+ (void)errorHandle:(NSInteger)error failureBlock:(TouchIDManagerFailureBlock)failureBlock cancelBlock:(TouchIDManagerCancelBlock)cancelBlock fallbacekBlock:(TouchIDManagerFallbackBlock)fallbackBlock {
    switch (error) {
        case LAErrorAuthenticationFailed://1
        {
            //身份验证并不成功，因为用户没有提供有效的凭证。
            if (failureBlock)
                failureBlock(ErrorAuthenticationFailed);
            break;
        }
        case LAErrorUserCancel://2
        {
            //认证被取消了由用户(例如了取消按钮)。
            if (cancelBlock)
                cancelBlock(ErrorUserCancel);
            break;
        }
        case LAErrorUserFallback://3
        {
            //身份验证被取消了，因为用户点击了后退按钮(输入密码)。
            if (fallbackBlock)
                fallbackBlock(ErrorUserFallback);
            break;
        }
        case LAErrorSystemCancel://4
        {
            //身份验证被系统取消了(如另一个应用程序去前台)。
            if (cancelBlock)
                cancelBlock(ErrorSystemCancel);
            break;
        }
        case LAErrorPasscodeNotSet://5
        {
            //身份验证无法启动，因为密码不是在设备上设置的。
            if (failureBlock)
                failureBlock(ErrorPasscodeNotSet);
            break;
        }
        case LAErrorTouchIDNotAvailable://6
        {
            //身份验证无法启动，因为设备上无法使用Touch ID。
            if (failureBlock)
                failureBlock(ErrorTouchIDNotAvailable);
            break;
        }
        case LAErrorTouchIDNotEnrolled://7
        {
            //身份验证无法启动，因为Touch ID没有注册的手指。
            if (failureBlock)
                failureBlock(ErrorTouchIDNotEnrolled);
            break;
        }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
        case LAErrorTouchIDLockout://8
        {
            //连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
            if (failureBlock)
                failureBlock(ErrorTouchIDLockout);
            break;
        }
        case LAErrorAppCancel://9
        {
            //如突然来了电话，电话应用进入前台，APP被挂起啦
            if (cancelBlock)
                cancelBlock(ErrorAppCancel);
            break;
        }
        case LAErrorInvalidContext://10
        {
            //LAContext传递给这个调用之前已经失效
            if (failureBlock)
                failureBlock(ErrorInvalidContext);
            break;
        }
#else
#endif
        default:
        {
            if (failureBlock)
                failureBlock(ErrorTouchIDFailure);
            break;
        }
    }
}

@end
