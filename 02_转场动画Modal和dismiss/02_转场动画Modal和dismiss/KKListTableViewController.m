//
//  ViewController.m
//  KKTransition
//
//  Created by 黄凯展 on 16/3/25.
//  Copyright © 2016年 ShengCheng. All rights reserved.
//

#import "KKListTableViewController.h"
#import "KKModalAndDismissController.h"

@interface KKListTableViewController ()
/***  标题*/
@property (nonatomic, strong) NSArray *titleArray;
/***  类名*/
@property (nonatomic, strong) NSArray *classArray;
/***  显示类型*/
@property (nonatomic, strong) NSArray *showTypeArray;
/***  是否modal*/
@property (nonatomic, assign) BOOL isDismiss;
@end

@implementation KKListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - 数据源，不用管哦
- (NSArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = @[@"Modal和Dismiss效果",@"Modal和Dismiss效果"];
    }
    return _titleArray;
}

- (NSArray *)classArray
{
    if (!_classArray) {
        _classArray = @[@"KKModalAndDismissController",@"KKModalAndDismissController"];
    }
    return _classArray;
}

- (NSArray *)showTypeArray
{
    if (!_showTypeArray) {
        // 1代表push 0代表modal
        _showTypeArray = @[@"0",@"0"];
    }
    return _showTypeArray;
}

#pragma mark - tableview代理,不用管哦
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    NSString *title = [self.titleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isModal = ![[self.showTypeArray objectAtIndex:indexPath.row] boolValue];
    NSString *classString = [self.classArray objectAtIndex:indexPath.row];
    Class class = NSClassFromString(classString);
    UIViewController *controller = [[class alloc] init];
    if (isModal) {
        
//         这是系统默认的代理动画，有淡入，翻页等
//        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        // 设置控制器的动画代理
        controller.modalPresentationStyle = UIModalPresentationCustom;
        controller.transitioningDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - modal和dismiss的代理
// 赋值modal的代理
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

// 赋值dismiss的代理
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

#pragma mark - 动画代理来咯
// 返回手势动画速度，暂时不管，看我后面介绍的手势交互文章
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

/**
 *  实现动画，目前这个方法push和pop都使用了淡入，后面会分出
 *
 *  @param transitionContext 动画上下文
 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // 1.从哪里来的控制器，这里是当前控制器
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // 2.要去哪里的控制器，这是是UIViewController
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // 3.这个view是包含视图，怎么说呢，几个控制器的view做的动画都是在这里面操作的，看我文章图
    UIView *containerView = [transitionContext containerView];
    
    
    if (self.isDismiss) {
        self.isDismiss = NO;
        // dismiss动画实现
        [UIView animateWithDuration:3.0 * 0.5 / 4.0
                              delay:0.5 / 4.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             fromViewController.view.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [fromViewController.view removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
        
        [UIView animateWithDuration:2.0 * 0.5
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:-15.0
                            options:0
                         animations:^{
                             fromViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
                         }
                         completion:nil];
    } else {
        
        self.isDismiss = YES;
        // modal动画实现
        // 3.1 更改了显示的容器frame哦
        [containerView addSubview:toViewController.view];
        CGRect frame = containerView.bounds;
        CGFloat width = frame.size.width * 0.5;
        CGFloat left = width * 0.5;
        CGFloat top = frame.size.height * 0.5 - width;
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(top, left, width, left));
        
        // 3.2 更改modal的控制器
        toViewController.view.frame = frame;
        toViewController.view.alpha = 0.0;
        toViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
        
        // 4.动画效果
        [UIView animateWithDuration:0.5 / 2.0 animations:^{
            toViewController.view.alpha = 1.0;
        }];
        
        CGFloat damping = 0.55;
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:1.0 / damping options:0 animations:^{
            toViewController.view.transform = CGAffineTransformIdentity;
            fromViewController.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}
@end
