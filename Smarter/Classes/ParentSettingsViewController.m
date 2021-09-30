//
//  ParentSettingsViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ParentSettingsViewController.h"
#import "ParentSyncChildViewController.h"
#import "LoginViewController.h"
#import "InformationViewController.h"
#import "ParentViewController.h"

@interface ParentSettingsViewController ()
{
    IBOutlet UIView *contentView;
    PFUser *me;
    NSMutableArray *userList;
    IBOutlet UILabel *lblUsername;
}
@end

@implementation ParentSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:contentView];
    me = [PFUser currentUser];
    userList = [[NSMutableArray alloc] init];
    lblUsername.text = [NSString stringWithFormat:@"Hello, %@!", me[PARSE_USER_FULLNAME]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSyncChild:(id)sender {
    ParentSyncChildViewController *vc = (ParentSyncChildViewController *)[Util getUIViewControllerFromStoryBoard:@"ParentSyncChildViewController"];
    [[ParentViewController getInstance] pushViewController:vc];
}

- (IBAction)onLogout:(id)sender {
    [SVProgressHUD showWithStatus:@"Logging out..." maskType:SVProgressHUDMaskTypeGradient];
    [PFUser logOutInBackgroundWithBlock:^(NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Logout" message:[error localizedDescription]];
        } else {
            [Util setLoginUserName:@"" password:@""];
            for (UIViewController *vc in [Util appDelegate].rootNavigationViewController.viewControllers){
                if ([vc isKindOfClass:[LoginViewController class]]){
                    [[Util appDelegate].rootNavigationViewController popToViewController:vc animated:YES];
                    break;
                }
            }
        }
    }];
}

- (IBAction)onAbout:(id)sender {
    [self gotoInformation:FLAG_ABOUT_THE_APP];
}

- (IBAction)onReview:(id)sender {
    [self rateApp];
}
- (IBAction)onSendFeedback:(id)sender {
    [self sendMail:ADMIN_EMAIL subject:@"Feedback about Smarter" message:nil];
}
- (IBAction)onTerms:(id)sender {
    [self gotoInformation:FLAG_TERMS_OF_SERVERICE];
}
- (IBAction)onPrivacy:(id)sender {
    [self gotoInformation:FLAG_PRIVACY_POLICY];
}

- (void) gotoInformation:(int) type {
    InformationViewController *vc = (InformationViewController *)[Util getUIViewControllerFromStoryBoard:@"InformationViewController"];
    vc.type = type;
    [self.navigationController pushViewController:vc animated:YES];
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
