//
//  SignUpOneViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SignUpOneViewController.h"
#import "SignUpTwoViewController.h"

@interface SignUpOneViewController ()
{
    IBOutlet UIButton *btnValidEmail;
    IBOutlet UIButton *btnNotUse;
    
    IBOutlet UITextField *txtEmail;
    NSMutableArray *dataArray;
}
@end

@implementation SignUpOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [txtEmail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    txtEmail.delegate = self;
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onNext:(id)sender {
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    if (email.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your email address." finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    if (!btnValidEmail.selected){
        [Util showAlertTitle:self title:@"Error" message:@"Please check your email and try again." finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    if (!btnNotUse.selected){
        [Util showAlertTitle:self title:@"Error" message:@"This email is already registered." finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return;
    }
    PFUser *user = [PFUser user];
    user.username = txtEmail.text;
    user[PARSE_USER_EMAIL] = txtEmail.text;
    user[PARSE_USER_TYPE] = [NSNumber numberWithInteger:USER_TYPE];
    SignUpTwoViewController *vc = (SignUpTwoViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpTwoViewController"];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)textFieldDidChange :(UITextField *) textField{
    txtEmail.text = [Util trim:txtEmail.text];
    NSString *email = txtEmail.text;
    btnValidEmail.selected = [email isEmail];
    if (![email isEmail]){
        btnNotUse.selected = NO;
        return;
    }
    if ([email containsString:@".."]){
        btnValidEmail.selected = NO;
        btnNotUse.selected = NO;
        return;
    }
    if ([dataArray containsObject:email])
        btnNotUse.selected = NO;
    else if ([email isEmail])
        btnNotUse.selected = YES;
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    btnNotUse.selected = NO;
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
