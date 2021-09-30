//
//  ResetPasswordViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "UserOptionViewController.h"

@interface ResetPasswordViewController ()
{
    IBOutlet UIButton *btnRegistered;
    IBOutlet UITextField *txtEmail;
    
    NSMutableArray *dataArray;
}
@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtEmail.delegate = self;
    [txtEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    dataArray = [[NSMutableArray alloc] init];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *user = [array objectAtIndex:i];
                [dataArray addObject:user[PARSE_USER_NAME]];
            }
        }
    }];
}

-(void)textFieldDidChange :(UITextField *) textField{
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    if ([dataArray containsObject:email])
        btnRegistered.selected = YES;
    else
        btnRegistered.selected = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSubmit:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"Error" message:@"Please check your entry and try again." finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    if (!btnRegistered.selected){
        NSString *msg = @"This email does not exist in our records. Please try again or sign up to new account.";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Try again" actionBlock:^(void) {
        }];
        [alert addButton:@"Sign Up" actionBlock:^(void) {
            UserOptionViewController *vc = (UserOptionViewController *)[Util getUIViewControllerFromStoryBoard:@"UserOptionViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [alert showError:@"Error" subTitle:msg closeButtonTitle:nil duration:0.0f];
        return;
    }
    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded,NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            [Util showAlertTitle:self
                           title:@"Success"
                         message: @"We have sent a password reset link to your email address. Please check your email."
                          finish:^(void) {
                              [self onback:nil];
                          }];
        } else {
            if (![Util isConnectableInternet]){
                if ([SVProgressHUD isVisible]){
                    [SVProgressHUD dismiss];
                }
                [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
                return;
            }
            NSString *errorString = [error localizedDescription];
            [Util showAlertTitle:self
                           title:@"Error" message:errorString
                          finish:^(void) {
                          }];
        }
    }];
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
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    btnRegistered.selected = NO;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    if ([dataArray containsObject:email])
        btnRegistered.selected = YES;
    else
        btnRegistered.selected = NO;
}

@end
