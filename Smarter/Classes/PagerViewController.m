//
//  PagerViewController.m
//  Eye On
//
//  Created by developer on 03/04/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "PagerViewController.h"
#import "PageItemViewController.h"
#import "LoginViewController.h"
#import "StudentViewController.h"
#import "ParentViewController.h"
#import "TeacherViewController.h"

@interface PagerViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    IBOutlet UIView *pagerContainer;
    UIPageViewController *pagerVC;
    NSArray *pageTitles;
    NSArray *pageDescriptions;
    NSArray *pageImages;

    IBOutlet UIButton *btnSkip;
    IBOutlet UIButton *btnNext;
    
}
@end

@implementation PagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self launchPageViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidLayoutSubviews {
    pagerVC.view.frame = pagerContainer.frame;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


- (void) launchPageViewController {
    pageTitles = @[@"Welcome to Smarter!", @"Parents",
                   @"Students", @"Teachers"
                      ];
    
    pageDescriptions = @[@"The world's latest innovation in adjusting study habits for kids distracted by cellphones, computers, or televisions.", (@"Program the app to ask certain questions at certain time intervals. Get reports of your child's Performance!"), (@"Receive popup questions on your phone and study while you're playing video games, surfing the net, or watching a movie!"), (@"Upload your personal study guides for your students to access. Make education easily available!")];
    
    pageImages = @[@"ic_share",
                        @"ic_upload",
                        @"ic_like",
                        @"groups"];
    
    pagerVC = (UIPageViewController *)[Util getUIViewControllerFromStoryBoard:@"pageviewcontroller"];
    pagerVC.dataSource = self;
    pagerVC.delegate = self;
    PageItemViewController *startingVC = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingVC];
    [pagerVC setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    [self addChildViewController:pagerVC];
    [self.view addSubview:pagerVC.view];
    [pagerVC didMoveToParentViewController:self];
}
- (IBAction)onNext:(id)sender {
    PageItemViewController *vc = [pagerVC.viewControllers lastObject];
    vc = [self viewControllerAtIndex:vc.pageIndex +1];
    if (vc){
        [pagerVC setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward  animated:YES completion:^(BOOL finished){
            if (vc.pageIndex == pageTitles.count -1){
                [self setLastValue];
            } else {
                [self setFirstValue];
            }
        }];
    }
    else { // All Done
        [self gotoMainScreen];
    }
}
- (IBAction)onSkip:(id)sender {
    [self gotoMainScreen];
}

- (void) gotoMainScreen {
    if (USER_TYPE == USER_TYPE_STUDENT){// student
        StudentViewController *vc = (StudentViewController *)[Util getUIViewControllerFromStoryBoard:@"StudentViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (USER_TYPE == USER_TYPE_PARENT){// parent
        ParentViewController *vc = (ParentViewController *)[Util getUIViewControllerFromStoryBoard:@"ParentViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (USER_TYPE == USER_TYPE_TEACHER){// teacher
        TeacherViewController *vc = (TeacherViewController *)[Util getUIViewControllerFromStoryBoard:@"TeacherViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void) setLastValue {
    [btnNext setTitle:@"All Done" forState:UIControlStateNormal];
    btnSkip.hidden = YES;
}
- (void) setFirstValue {
    [btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
    btnSkip.hidden = NO;
}
- (PageItemViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([pageTitles count] == 0) || (index >= [pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageItemViewController *pageContentViewController =(PageItemViewController *) [Util getUIViewControllerFromStoryBoard:@"PageItemViewController"];
    
    pageContentViewController.desctiptionText = pageDescriptions[index];
    pageContentViewController.imageFile = pageImages[index];
    pageContentViewController.title = pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((PageItemViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index --;
    return [self viewControllerAtIndex:index];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((PageItemViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == [pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed){
        PageItemViewController *vc = [pageViewController.viewControllers lastObject];
        if (vc.pageIndex == pageTitles.count-1){
            [self setLastValue];
        } else {
            [self setFirstValue];
        }
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController { // this is the current control position
    PageItemViewController *vc = [pagerVC.viewControllers lastObject];
    return vc.pageIndex;
}

@end
