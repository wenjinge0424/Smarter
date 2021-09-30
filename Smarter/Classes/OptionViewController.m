//
//  OptionViewController.m
//  Smarter
//
//  Created by gao on 10/23/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "OptionViewController.h"
#import "AddGuideViewController.h"
#import "AddAssignmentViewController.h"

@interface OptionViewController ()

@end

@implementation OptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(createdSuccess:) name:NOTIFICATION_CREATE_SUCCESS object:nil];
}

- (void) createdSuccess:(NSNotification *) notif {
    [self onback:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onGuide:(id)sender {
    AddGuideViewController *vc = (AddGuideViewController *)[Util getUIViewControllerFromStoryBoard:@"AddGuideViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onAssignment:(id)sender {
    AddAssignmentViewController *vc = (AddAssignmentViewController *)[Util getUIViewControllerFromStoryBoard:@"AddAssignmentViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
