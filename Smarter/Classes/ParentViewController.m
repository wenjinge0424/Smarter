//
//  ParentViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ParentViewController.h"
#import "ParentTabbarViewController.h"

typedef enum {
    TAB_QUESTION = 1,
    TAB_MAIN,
    TAB_SETTINGS
} TAB_INDEX;


@interface ParentViewController ()
{
    ParentTabbarViewController *tabbarController;
    IBOutlet UIButton *btnQuesion;
    IBOutlet UIButton *btnMain;
    IBOutlet UIButton *btnSettings;
}
@end
static ParentViewController *_sharedViewController = nil;
@implementation ParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sharedViewController = self;
    [tabbarController setSelectedIndex:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (ParentViewController *)getInstance{
    return _sharedViewController;
}

- (IBAction)onTabSelect:(id)sender {
    NSInteger tag = [sender tag];
    
    [tabbarController setSelectedIndex:(tag-1)];
    
    [self selectTabButton:tag];
}

- (void) selectTabButton:(NSInteger)tag {
    btnQuesion.selected = NO;
    btnSettings.selected = NO;
    switch (tag) {
        case TAB_QUESTION:
            btnQuesion.selected = YES;
            break;
        case TAB_SETTINGS:
            btnSettings.selected = YES;
            break;
    }
}

- (void) pushViewController:(UIViewController *) viewController{
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void) pushViewController:(UIViewController *)viewController animation:(BOOL) animate{
    [self.navigationController pushViewController:viewController animated:animate];
}
- (void) presentViewController:(UIViewController *) viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainerParent"]) {
        tabbarController = segue.destinationViewController;
        [tabbarController setHidesBottomBarWhenPushed:YES];
    }
}

@end
