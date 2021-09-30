//
//  GuidePayViewController.m
//  Smarter
//
//  Created by gao on 9/19/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "GuidePayViewController.h"
#import "StripeRest.h"
#import "StripeConnectionViewController.h"
#import "MyPaymentViewController.h"

@interface GuidePayViewController ()
{
    IBOutlet UITextView *txtContent;
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UIButton *btnPay;
}
@end

@implementation GuidePayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerView:txtContent];
    
    [self initializeData];
}
- (void) hidePayButton
{
    [btnPay setHidden:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self.guide fetchInBackgroundWithBlock:^(PFObject *obj, NSError *err){
        [SVProgressHUD dismiss];
        if (err){
            [Util showAlertTitle:self title:@"Error" message:[err localizedDescription]];
        } else {
            self.guide = obj;
            [self initializeData];
        }
    }];
}

- (void) initializeData {
    lblTitle.text = self.guide[PARSE_GUIDES_TITLE];
    
    NSString *subject = [ARRAY_SUBJECT objectAtIndex:[self.guide[PARSE_GUIDES_SUBJECT] integerValue]];
    NSString *grade = [NSString stringWithFormat:@"%ld",[self.guide[PARSE_GUIDES_GRADE_LEVEL] integerValue]];
    if ([grade hasSuffix:@"1"]){
        grade = [NSString stringWithFormat:@"%@%@ Grade", grade, @"st"];
    } else if ([grade hasSuffix:@"2"]){
        grade = [NSString stringWithFormat:@"%@%@ Grade", grade, @"nd"];
    } else if ([grade hasSuffix:@"3"]){
        grade = [NSString stringWithFormat:@"%@%@ Grade", grade, @"rd"];
    } else {
        grade = [NSString stringWithFormat:@"%@%@ Grade", grade, @"th"];
    }
    NSString *price = [NSString stringWithFormat:@"$ %.2f", [self.guide[PARSE_GUIDES_PRICE] doubleValue]];
    NSString *desc = self.guide[PARSE_GUIDES_DESCRIPTION];
    NSString *ref = self.guide[PARSE_GUIDES_REFERENCE];
    NSString *content = [NSString stringWithFormat:@"\n%@ - %@\n\n%@\n\n%@\n \n%@", subject, grade, ref, price, desc];
    txtContent.text = content;
    
    if ([self.guide[PARSE_GUIDES_PRICE] doubleValue] == 0){
        [btnPay setTitle:@"FREE" forState:UIControlStateNormal];
    } else {
        [btnPay setTitle:@"PAY" forState:UIControlStateNormal];
    }
    
    [txtContent setContentOffset:CGPointZero animated:NO];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onPay:(id)sender {
    if ([self.guide[PARSE_GUIDES_PRICE] doubleValue] == 0){
        [self PaySuccess:nil];
    } else {
        PFUser *owner = self.guide[PARSE_GUIDES_OWNER];
        double price = [self.guide[PARSE_GUIDES_PRICE] doubleValue];
        int amount = (int) price * 100;
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        [owner fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error) {
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^(void) {
                }];
            } else {
                // check stripe account
                [StripeRest getAccount:owner[PARSE_USER_ACCOUNT_ID] completionBlock:^(id data, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (error) {
                        NSString *confirmStr = @"This user requires a connected ‘Stripe’ account";
                        [Util showAlertTitle:self title:@"" message:confirmStr finish:^(void){
                            
                        }];
                    } else {
                        MyPaymentViewController *vc = (MyPaymentViewController *)[Util getUIViewControllerFromStoryBoard:@"MyPaymentViewController"];
                        PayModel *payModel = [[PayModel alloc] init];
                        payModel.amount = [NSString stringWithFormat:@"%d", amount];
                        payModel.accountId = owner[PARSE_USER_ACCOUNT_ID];
                        vc.payModel = payModel;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }];
            }
        }];
    }
}

- (void) PaySuccess:(NSNotification *) notif {
    int price = (int)[self.guide[PARSE_GUIDES_PRICE] doubleValue];
    NSMutableArray *array = self.guide[PARSE_GUIDES_TEACHER_LIST];
    if (!array){
        array = [[NSMutableArray alloc] init];
    }
    [array addObject:[PFUser currentUser]];
    self.guide[PARSE_GUIDES_TEACHER_LIST] = array;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [self.guide saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (succeed && !error){
            PFObject *objHistory = [PFObject objectWithClassName:PARSE_TABLE_PAYMENT_HISTORY];
            objHistory[PARSE_PAYMENT_AMOUNT] = [NSNumber numberWithInt:price];
            objHistory[PARSE_PAYMENT_TO_USER] = self.guide[PARSE_GUIDES_OWNER];
            objHistory[PARSE_PAYMENT_FROM_USER] = [PFUser currentUser];
            [objHistory saveInBackground];
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                [self onback:nil];
            }];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }
    }];
}

@end
