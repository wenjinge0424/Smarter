//
//  StudentViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "StudentViewController.h"
#import "StudentTabbarController.h"

typedef enum {
    TAB_MENU = 1,
    TAB_QUESTION,
    TAB_SETTING
} TAB_INDEX;

static StudentViewController *_sharedViewController = nil;

@interface StudentViewController ()
{
    IBOutlet UIButton *btnSetting;
    IBOutlet UIButton *btnMenu;
    StudentTabbarController *tabbarController;
}
@end

@implementation StudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sharedViewController = self;
    
    [tabbarController setSelectedIndex:1];
    [self selectTabButton:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (StudentViewController *)getInstance{
    return _sharedViewController;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onTabSelect:(id)sender {
    NSInteger tag = [sender tag];
    
    [tabbarController setSelectedIndex:(tag-1)];
    
    [self selectTabButton:tag];
}

- (void) selectTabButton:(NSInteger)tag {
    btnMenu.selected = NO;
    btnSetting.selected = NO;
    switch (tag) {
        case TAB_MENU:
            btnMenu.selected = YES;
            break;
        case TAB_SETTING:
            btnSetting.selected = YES;
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"]) {
        tabbarController = segue.destinationViewController;
        [tabbarController setHidesBottomBarWhenPushed:YES];
    }
}

- (void) pushViewController:(UIViewController *) viewController{
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void) pushViewController:(UIViewController *)viewController animation:(BOOL) animate{
    [self.navigationController pushViewController:viewController animated:animate];
}
- (void) presentViewController:(UIViewController *) viewController{
    [self presentViewController:viewController animated:YES completion:^(void){
        
    }];
}

@end
