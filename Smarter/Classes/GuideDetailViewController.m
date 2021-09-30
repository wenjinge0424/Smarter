//
//  GuideDetailViewController.m
//  Smarter
//
//  Created by gao on 8/25/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "GuideDetailViewController.h"
#import "EditGuideViewController.h"

@interface GuideDetailViewController ()
{
    IBOutlet UITextView *txtContent;
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnEdit;
}
@end

@implementation GuideDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerView:txtContent];
    PFUser *me = [PFUser currentUser];
    PFUser *owner = (PFUser *) self.guide[PARSE_GUIDES_OWNER];
    btnEdit.hidden = ![me.objectId isEqualToString:owner.objectId];
    
    txtContent.editable = NO;
    [self initializeData];
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
    NSString *content = [NSString stringWithFormat:@"\n \n %@\n%@\n%@\n%@\n \n %@", subject, grade, ref, price, desc];
    txtContent.text = content;
    [txtContent setContentOffset:CGPointZero animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onEdit:(id)sender {
    EditGuideViewController *vc = (EditGuideViewController *)[Util getUIViewControllerFromStoryBoard:@"EditGuideViewController"];
    vc.guide = self.guide;
    [self.navigationController pushViewController:vc animated:YES];
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

@end
