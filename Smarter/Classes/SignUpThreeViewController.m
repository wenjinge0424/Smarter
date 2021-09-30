//
//  SignUpThreeViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SignUpThreeViewController.h"
#import "SignUpFourViewController.h"

@interface SignUpThreeViewController ()
{
    IBOutlet UITextField *txtRepassword;
    IBOutlet UIButton *btnMatch;
    
    IBOutlet UIButton *btnNext;
    IBOutlet UIView *viewField;
}
@end

@implementation SignUpThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [Util setCornerView:viewField];
    [txtRepassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    btnNext.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onNext:(id)sender {
    SignUpFourViewController *vc = (SignUpFourViewController *)[Util getUIViewControllerFromStoryBoard:@"SignUpFourViewController"];
    vc.user = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidChange :(UITextField *) textField{
    btnMatch.selected = [self.user[PARSE_USER_PASSWORD] isEqualToString:txtRepassword.text];
    btnNext.enabled = btnMatch.selected;
}

@end
