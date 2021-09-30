//
//  MyPaymentViewController.m
//  Eye On
//
//  Created by developer on 03/05/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import "MyPaymentViewController.h"
#import <Stripe/Stripe.h>
#import "StripeRest.h"
@interface MyPaymentViewController ()<STPPaymentCardTextFieldDelegate>
{
    IBOutlet UIButton *btnPay;
    IBOutlet UIView *cardInfoView;
    STPPaymentCardTextField *paymentField;
    IBOutlet UITableView *tableview;
}
@end

@implementation MyPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [tableview layoutIfNeeded];
    [cardInfoView layoutIfNeeded];
    paymentField = [[STPPaymentCardTextField alloc] initWithFrame:cardInfoView.frame];
    paymentField.delegate = self;
    [tableview addSubview:paymentField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onPay:(id)sender {
    if (self.payModel.accountId){ // pay to accountId - event
        // 90% -venue owner   10%-app owner
        double amount = [self.payModel.amount doubleValue];
        NSString *payAmount = [NSString stringWithFormat:@"%f", amount];
//        NSString *feeAmount = [NSString stringWithFormat:@"%f", 0.1 * amount];
        [self processStripe:payAmount accountId:self.payModel.accountId completionBlock:^(id response, NSError *error){
            if (!error) {
//                [self processStripe:feeAmount accountId:nil completionBlock:^(id resp, NSError *err){
//                    if (!err){
                        [Util showAlertTitle:self title:@"Success" message:@"Your payment was successful." finish:^(void) {
                            [self onback:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAY_SUCCESS_EVENT object:nil];
                        }];
//                    }
//                }];
            }
        }];
    }
}

- (void) processStripe:(NSString *)amount accountId:(NSString *)accountId completionBlock: (void (^)(id, NSError *))completionBlock {
    PFUser *me = [PFUser currentUser];
    NSString *name = me[PARSE_USER_FULLNAME]?me[PARSE_USER_FULLNAME]:me.username;
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     @"iOS", @"DeviceType",
                                     name, @"User Name",
                                     me.username, @"User Email",
                                     nil];
    NSMutableDictionary *chargeDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       amount, @"amount",
                                       @"usd", @"currency",
                                       self.payModel.description, @"description",
                                       metadata, @"metadata",
                                       nil];
    NSMutableDictionary *tokenDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       paymentField.cardParams.number, @"number",
                                       [NSString stringWithFormat:@"%lu", (unsigned long)paymentField.cardParams.expYear], @"exp_year",
                                       [NSString stringWithFormat:@"%lu", (unsigned long)paymentField.cardParams.expMonth], @"exp_month",
                                       paymentField.cardParams.cvc, @"cvc",
                                       @"usd", @"currency",
                                       nil],
                                      @"card",
                                      nil];
    if (accountId) {
        [chargeDict setObject:accountId forKey:@"destination"];
    }
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [StripeRest setCharges:chargeDict tokenDict:tokenDict completionBlock:^(id response, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            [Util showAlertTitle:self title:@"Error" message:@"Unable to process payment. Please check your details and try again." finish:^(void) {
                if (completionBlock)
                    completionBlock (response, err);
            }];
        } else {
            if (completionBlock)
                completionBlock (response, err);
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

#pragma mark STPPaymentCardTextFieldDelegate

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    NSLog(@"Card number: %@ Exp Month: %@ Exp Year: %@ CVC: %@", textField.cardParams.number, @(textField.cardParams.expMonth), @(textField.cardParams.expYear), textField.cardParams.cvc);
    btnPay.enabled = textField.isValid;
}

@end
