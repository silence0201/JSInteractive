//
//  ViewController.m
//  JSInteractive
//
//  Created by 杨晴贺 on 2018/4/17.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "ViewController.h"
#import "NativeAPIViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)NativeAPIAction:(id)sender {
    [self.navigationController pushViewController:[NativeAPIViewController new] animated:YES];
}

@end
