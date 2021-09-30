//
//  SignUpTwoViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SignUpTwoViewController.h"
#import "SignUpThreeViewController.h"

@interface SignUpTwoViewController ()
{
    IBOutlet UITextField *txtPassword;
    IBOutlet UIButton *btnLength;
    IBOutlet UIButton *btnUpper;
    IBOutlet UIButton *btnLower;
    IBOutlet UIButton *btnNumber;
    
    IBOutlet UILabel *lblOne;
    IBOutlet UILabel *lblTwo;
    IBOutlet UILabel *lblThree;
    IBOutlet UILabel *lblFour;
    IBOutlet UIView *viewField;
}
@end

@implementation SignUpTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [txtPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [Util setCornerView:viewField];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self adjustFontSize];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self adjustFontSize];
}

- (void) adjustFontSize {
    CGFloat actualFontSize;
    [lblTwo.text sizeWithFont:lblTwo.font
                  minFontSize:lblTwo.minimumFontSize
               actualFontSize:&actualFontSize
                     forWidth:lblTwo.bounds.size.width
                lineBreakMode:lblTwo.lineBreakMode];
    lblOne.font = [UIFont systemFontOfSize:actualFontSize];
    lblThree.font = [UIFont systemFontOfSize:actualFontSize];
    lblFour.font = [UIFont systemFontOfSize:actualFontSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    self.user[PARSE_USER_PASSWORD] = txtPassword.text;
    self.user.password = txtPassword.text;
    SignUpThreeViewController *vc = (SignUpThreeViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpThreeViewController"];
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL) isValid {
    NSString *password = txtPassword.text;
    int errCount = 0;
    if (!btnLength.selected){
        errCount++;
    } else if (!btnUpper.selected){
        errCount++;
    } else if (!btnLower.selected){
        errCount++;
    } else if (!btnNumber.selected){
        errCount++;
    }
    if (password.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your password."];
        return NO;
    }
    if (errCount > 0){
        [Util showAlertTitle:self title:@"Error" message:@"Password must meet all requirements. Please check and try again."];
        return NO;
    }
    
    if (!btnLength.selected){
        [Util showAlertTitle:self title:@"Error" message:@"Password is too short. Please check and try again." finish:^(void){
            [txtPassword becomeFirstResponder];
        }];
        return NO;
    }
    if (password.length > 30){
        [Util showAlertTitle:self title:@"Error" message:@"Password is too long. Please check and try again." finish:^(void){
            [txtPassword becomeFirstResponder];
        }];
        return NO;
    }
    if (!btnUpper.selected){
        [Util showAlertTitle:self title:@"Error" message:@"Password must have at least 1 upper case letter. Please check and try again." finish:^(void){
            [txtPassword becomeFirstResponder];
        }];
        return NO;
    }
    if (!btnLower.selected){
        [Util showAlertTitle:self title:@"Error" message:@"Password must have at least 1 lower case letter. Please check and try again." finish:^(void){
            [txtPassword becomeFirstResponder];
        }];
        return NO;
    }
    if (!btnNumber.selected){
        [Util showAlertTitle:self title:@"Error" message:@"Password must have at least 1 number. Please check and try again." finish:^(void){
            [txtPassword becomeFirstResponder];
        }];
        return NO;
    }
    return YES;
}

-(void)textFieldDidChange :(UITextField *) textField{
    NSString *password = txtPassword.text;
    btnLength.selected = (password.length >= 6);
    btnUpper.selected = [Util isContainsUpperCase:password];
    btnLower.selected = [Util isContainsLowerCase:password];
    btnNumber.selected = [Util isContainsNumber:password];
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
