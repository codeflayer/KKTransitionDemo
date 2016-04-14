//
//  ViewController.m
//  KKTransition
//
//  Created by 黄凯展 on 16/3/25.
//  Copyright © 2016年 ShengCheng. All rights reserved.
//

#import "KKListTableViewController.h"

@interface KKListTableViewController ()<UINavigationControllerDelegate,UIViewControllerAnimatedTransitioning>
/***  标题*/
@property (nonatomic, strong) NSArray *titleArray;
/***  类名*/
@property (nonatomic, strong) NSArray *classArray;
/***  显示类型*/
@property (nonatomic, strong) NSArray *showTypeArray;
@end

@implementation KKListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    // 设置导航控制器的代理为当前控制器
//    self.navigationController.delegate = self;
}

#pragma mark - 数据源，不用管哦
- (NSArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = @[@"Push和Pop效果"];
    }
    return _titleArray;
}

- (NSArray *)classArray
{
    if (!_classArray) {
        _classArray = @[@"UIViewController"];
    }
    return _classArray;
}

- (NSArray *)showTypeArray
{
    if (!_showTypeArray) {
        // 1代表push 0代表modal
        _showTypeArray = @[@"1"];
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
    controller.view.backgroundColor = [UIColor grayColor];
    if (isModal) {
        
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - 导航控制器代理方法
/**
 *  当导航控制器要push/pop的时候，会调用这个方法，通过这个方法返回一个动画代理，
 *  然后导航控制器再去调用这个代理的动画实现方法
 *
 *  @param navigationController 导航控制器
 *  @param operation            操作类型枚举：push、pop。。。
 *  @param fromVC               当前页面控制器
 *  @param toVC                 要显示的页面控制器
 *
 *  @return 动画代理
 */
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    // 这里返回当前控制器，所以要在当前控制器实现动画
    // 仔细看返回值类型，要求返回值必须实现(id<UIViewControllerAnimatedTransitioning>)
    // 也就是当前控制器要实现这个代理才有效
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
    // 2.1不透明咯
    toViewController.view.alpha = 0;
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    
#warning 没事，就是建议你打断点看一下控制器类型
    
    // 3.这个view是包含视图，怎么说呢，几个控制器的view做的动画都是在这里面操作的，看我文章图
    UIView *containerView = [transitionContext containerView];
    // 3.1要显示必须添加到里面哦
    [containerView addSubview:toViewController.view];
    
    

    // 4.动画效果
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        // 用了淡入
        toViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        // 移除从哪里来的控制器的view
        [fromViewController.view removeFromSuperview];
        // 必须一定肯定要调用，用来告诉上下文说已经结束动画了
        [transitionContext completeTransition:YES];
    }];
}
@end
