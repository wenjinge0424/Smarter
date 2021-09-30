//
//  TeacherSettingsViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "TeacherSettingsViewController.h"
#import "StudentsViewController.h"
#import "LoginViewController.h"
#import "InformationViewController.h"
#import "StripeConnectionViewController.h"

@interface TeacherSettingsViewController ()
{
    IBOutlet UIView *contentView;
    IBOutlet UILabel *lblUsername;
    
    IBOutlet UIView *viewNotif;
    IBOutlet UILabel *lblCount;
    
    PFUser *me;
}
@end

@implementation TeacherSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerView:contentView];
    me = [PFUser currentUser];
    lblUsername.text = [NSString stringWithFormat:@"Hello, %@!", me[PARSE_USER_FULLNAME]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setbadgeCount];
}

- (void) setbadgeCount {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
    [query whereKey:PARSE_NOTIFICATION_TYPE equalTo:[NSNumber numberWithInt:NOTIFICATION_JOIN_CLASS]];
    [query whereKey:PARSE_NOTIFICATION_STATE equalTo:[NSNumber numberWithInt:NOTIFICATION_STATE_PENDING]];
    [query whereKey:PARSE_NOTIFICATION_TO_USER equalTo:me];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            lblCount.text = [NSString stringWithFormat:@"%ld", objects.count];
            viewNotif.hidden = (objects.count == 0);
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onMyStudents:(id)sender {
    StudentsViewController *vc = (StudentsViewController *)[Util getUIViewControllerFromStoryBoard:@"StudentsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onlogout:(id)sender {
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
- (IBAction)onTerms:(id)sender {
    [self gotoInformation:FLAG_TERMS_OF_SERVERICE];
}

- (IBAction)onReview:(id)sender {
    [self rateApp];
}
- (IBAction)onFeedback:(id)sender {
    [self sendMail:ADMIN_EMAIL subject:@"Feedback about Smarter" message:nil];
}
- (IBAction)onPrivacy:(id)sender {
    [self gotoInformation:FLAG_PRIVACY_POLICY];
}

- (void) gotoInformation:(int) type {
    InformationViewController *vc = (InformationViewController *)[Util getUIViewControllerFromStoryBoard:@"InformationViewController"];
    vc.type = type;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onPayment:(id)sender {
    StripeConnectionViewController *vc = (StripeConnectionViewController *)[Util getUIViewControllerFromStoryBoard:@"StripeConnectionViewController"];
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
