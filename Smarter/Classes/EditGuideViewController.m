//
//  EditGuideViewController.m
//  Smarter
//
//  Created by gao on 8/31/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "EditGuideViewController.h"
#import "TeacherSettingsViewController.h"
#import "IQDropDownTextField.h"
#import "CustomTextField.h"

@interface EditGuideViewController ()
{
    IBOutlet UITextField *txtPrice;
    IBOutlet IQDropDownTextField *txtSubject;
    IBOutlet UITextField *txtTitle;
    IBOutlet CustomTextField *txtGrade;
    IBOutlet UIPlaceHolderTextView *txtDescription;
    IBOutlet UITextField *txtReference;
    
}
@end

@implementation EditGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setCornerView:txtDescription];
    txtDescription.placeholder = @"Enter study guide";
    txtPrice.text = [NSString stringWithFormat:@"%.2f", [self.guide[PARSE_GUIDES_PRICE] doubleValue]] ;
    txtSubject.itemList = ARRAY_SUBJECT;
    [txtSubject setSelectedRow:[self.guide[PARSE_GUIDES_SUBJECT] integerValue]];
    txtSubject.selectedItem = [ARRAY_SUBJECT objectAtIndex:[self.guide[PARSE_GUIDES_SUBJECT] integerValue]];
    txtTitle.text = self.guide[PARSE_GUIDES_TITLE];
    txtGrade.text = [NSString stringWithFormat:@"%ld", [self.guide[PARSE_GUIDES_GRADE_LEVEL] integerValue]] ;
    txtDescription.text = self.guide[PARSE_GUIDES_DESCRIPTION];
    txtReference.text = self.guide[PARSE_GUIDES_REFERENCE];
    
    [self initHighLight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSettings:(id)sender {
    TeacherSettingsViewController *vc = (TeacherSettingsViewController *)[Util getUIViewControllerFromStoryBoard:@"TeacherSettingsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSubmit:(id)sender {
    if (![self isValid]){
        return;
    }
    PFObject *guide = self.guide;
    guide[PARSE_GUIDES_REFERENCE] = txtReference.text;
    guide[PARSE_GUIDES_SUBJECT] = [NSNumber numberWithInteger:[txtSubject selectedRow]];
    guide[PARSE_GUIDES_GRADE_LEVEL] = [NSNumber numberWithInt:[txtGrade.text intValue]];
    guide[PARSE_GUIDES_TITLE] = txtTitle.text;
    guide[PARSE_GUIDES_DESCRIPTION] = txtDescription.text;
    guide[PARSE_GUIDES_PRICE] = [NSNumber numberWithDouble:[txtPrice.text doubleValue]];
    NSMutableArray *teacherList = [[NSMutableArray alloc] init];
    [teacherList addObject:[PFUser currentUser]];
    guide[PARSE_GUIDES_TEACHER_LIST] = teacherList;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [guide saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (succeed && !error){
            [Util showAlertTitle:self title:@"Edit Study Guide" message:@"Success" finish:^(void){
                [self onback:nil];
            }];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^{
                
            }];
        }
    }];
}

- (void) initHighLight {
    [Util setBorderView:txtPrice color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtDescription color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtTitle color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtGrade color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtReference color:COLOR_TRANSPARENT width:1.0];
}

- (BOOL) isValid {
    [self initHighLight];
    txtPrice.text = [Util trim:txtPrice.text];
    txtTitle.text = [Util trim:txtTitle.text];
    txtGrade.text = [Util trim:txtGrade.text];
    txtReference.text = [Util trim:txtReference.text];
    txtDescription.text = [Util trim:txtDescription.text];
    if (txtPrice.text.length == 0){
        
    }
    double price = [txtPrice.text doubleValue];
    if (price < 0 || price > 10000 || txtPrice.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank. Maximum price of $10,000 only." finish:^{
            [Util setBorderView:txtPrice color:COLOR_RED width:1.0];
        }];
        return NO;
    }
    if (txtSubject.selectedRow == -1){
        [Util showAlertTitle:self title:@"Error" message:@"Please select a subject." finish:^{
            [Util setBorderView:txtSubject color:COLOR_RED width:1.0];
        }];
        return NO;
    }
    NSString *title = txtTitle.text;
    if (title.length < 6 || title.length > 30){
        [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank. Minimum 6 letters, maximum of 30." finish:^{
            [Util setBorderView:txtTitle color:COLOR_RED width:1.0];
        }];
        return NO;
    }
    NSString *description = txtDescription.text;
    if (description.length > 60000 || description.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"We apologize, this can only hold a maximum of 60,000 characters." finish:^{
            [Util setBorderView:txtDescription color:COLOR_RED width:1.0];
        }];
        return NO;
    }
    
    return YES;
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
