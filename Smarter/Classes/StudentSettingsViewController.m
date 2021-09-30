//
//  StudentSettingsViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "StudentSettingsViewController.h"
#import "AcceptParentViewController.h"
#import "TeachersViewController.h"
#import "LoginViewController.h"
#import "InformationViewController.h"
#import "StudentViewController.h"
#import "GuideViewController.h"

@interface StudentSettingsViewController ()
{
    IBOutlet UIView *contentView;
    IBOutlet UILabel *lblUsername;
    
    IBOutlet UIView *viewnotif;
    IBOutlet UILabel *lblNotif;
}
@end

@implementation StudentSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:contentView];
    
    PFUser *me = [PFUser currentUser];
    lblUsername.text = me[PARSE_USER_FULLNAME];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(syncPending:) name:NOTIFICATION_SYNC_PENDING object:nil];
}

- (void) syncPending:(NSNotification *) notif {
    [self viewWillAppear:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
    [query whereKey:PARSE_NOTIFICATION_TO_USER equalTo:[PFUser currentUser]];
    [query whereKey:PARSE_NOTIFICATION_TYPE equalTo:[NSNumber numberWithInt:NOTIFICATION_PARENT_SYNC]];
    [query whereKey:PARSE_NOTIFICATION_STATE equalTo:[NSNumber numberWithInt:NOTIFICATION_STATE_PENDING]];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            viewnotif.hidden = (array.count == 0);
            lblNotif.text = [NSString stringWithFormat:@"%ld", array.count];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onAcceptParent:(id)sender {
    AcceptParentViewController *vc = (AcceptParentViewController *)[Util getUIViewControllerFromStoryBoard:@"AcceptParentViewController"];
    [[StudentViewController getInstance] pushViewController:vc];
}

- (IBAction)onMyTeachers:(id)sender {
    TeachersViewController *vc = (TeachersViewController *)[Util getUIViewControllerFromStoryBoard:@"TeachersViewController"];
    [[StudentViewController getInstance] pushViewController:vc];
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

- (IBAction)onGuides:(id)sender {
    GuideViewController *vc = (GuideViewController *)[Util getUIViewControllerFromStoryBoard:@"GuideViewController"];
    [[StudentViewController getInstance] pushViewController:vc];
}

- (IBAction)onAbout:(id)sender {
    [self gotoInformationViewController:FLAG_ABOUT_THE_APP];
}
- (IBAction)onReview:(id)sender {
    [self rateApp];
}
- (IBAction)onSendFeedback:(id)sender {
    [self sendMail:ADMIN_EMAIL subject:@"Feedback about Smarter" message:nil];
}
- (IBAction)onTerms:(id)sender {
    [self gotoInformationViewController:FLAG_TERMS_OF_SERVERICE];
}
- (IBAction)onPrivacy:(id)sender {
    [self gotoInformationViewController:FLAG_PRIVACY_POLICY];
}

- (void) gotoInformationViewController:(int)type {
    InformationViewController *vc = (InformationViewController *)[Util getUIViewControllerFromStoryBoard:@"InformationViewController"];
    vc.type = type;
    [[StudentViewController getInstance] pushViewController:vc];
}

@end
