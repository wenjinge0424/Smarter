//
//  UserOptionViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "UserOptionViewController.h"
#import "SignUpOneViewController.h"
#import "SignUpFourViewController.h"
#import "PagerViewController.h"

@interface UserOptionViewController ()

@end

@implementation UserOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)onSignup:(id)sender {
    [AppStateManager sharedInstance].user_type = [sender tag];
    if (self.user){
        self.user[PARSE_USER_TYPE] = [NSNumber numberWithInteger:[sender tag]];
        self.user[PARSE_USER_STUDENT_LIST] = [NSMutableArray new];
        self.user[PARSE_USER_TEACHER_LIST] = [NSMutableArray new];
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        if (self.user[PARSE_USER_FACEBOOKID]){
            [self.user saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                [Util setLoginUserName:self.user.username password:self.user[PARSE_USER_PASSWORD]];
                [SVProgressHUD dismiss];
                PagerViewController *vc = (PagerViewController *)[Util getUIViewControllerFromStoryBoard:@"PagerViewController"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        } else if (self.user[PARSE_USER_GOOGLEID]){
            [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [SVProgressHUD dismiss];
                [Util setLoginUserName:self.user.username password:self.user[PARSE_USER_PASSWORD]];
                if (!error) {
                    PagerViewController *vc = (PagerViewController *)[Util getUIViewControllerFromStoryBoard:@"PagerViewController"];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    [Util showAlertTitle:self title:@"" message:@"This email has already been used. Please try logging in."];
                }
            }];
        }
        
    } else {
        SignUpOneViewController *vc = (SignUpOneViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpOneViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
