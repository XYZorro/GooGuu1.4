//
//  UINavigationControlle+Autorotate.m
//  UIDemo
//
//  Created by Xcode on 13-7-4.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "UINavigationController+Autorotate.h"

@implementation UINavigationController (Autorotate)

//返回最上层的子Controller的shouldAutorotate
//子类要实现屏幕旋转需重写该方法
- (BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}

//返回最上层的子Controller的supportedInterfaceOrientations
- (NSUInteger)supportedInterfaceOrientations{

    return self.topViewController.supportedInterfaceOrientations;
}

@end