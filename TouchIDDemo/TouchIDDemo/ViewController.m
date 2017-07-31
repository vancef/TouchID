//
//  ViewController.m
//  TouchIDDemo
//
//  Created by vance on 2017/3/6.
//  Copyright © 2017年 Vancef. All rights reserved.
//

#import "ViewController.h"
#import "TouchIDManager.h"
#import <RMessage.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)touchID:(UIButton *)sender {
    [TouchIDManager touchIDWithLocalizedReason:@"" cancelTitle:@"" fallbackTitle:@"" evaluatedState:nil successBlock:^(NSString *message, NSData *evaluatedState) {
        [self showNotificationWithTitle:message subtitle:message type:RMessageTypeSuccess];
    } failureBlock:^(NSString *message) {
        [self showNotificationWithTitle:message subtitle:message type:RMessageTypeWarning];
    } cancelBlock:^(NSString *message) {
        [self showNotificationWithTitle:message subtitle:message type:RMessageTypeWarning];
    } fallbacekBlock:^(NSString *message) {
        [self showNotificationWithTitle:message subtitle:message type:RMessageTypeError];
    } changeBlock:^(NSString *message) {
        [self showNotificationWithTitle:message subtitle:message type:RMessageTypeError];
    }];
}


- (void)showNotificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle type:(RMessageType)type {
    [RMessage showNotificationWithTitle:title subtitle:subtitle type:type customTypeName:nil callback:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
