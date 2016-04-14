//
//  KKModalAndDismissController.m
//  KKTransition
//
//  Created by 黄凯展 on 16/3/26.
//  Copyright © 2016年 ShengCheng. All rights reserved.
//

#import "KKModalAndDismissController.h"

@implementation KKModalAndDismissController

- (instancetype)init
{
    if (self = [super init]) {
//        self.modalTransitionDelegate = [[KKModalTransition alloc] init];
//        self.dismissTransitionDelegate = [[KKDismissTransition alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"我是modal的控制器";
    [self.view addSubview:label];
}


- (void)viewTap:(UITapGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
