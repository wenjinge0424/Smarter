//
//  AddGuideViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "AddGuideViewController.h"
#import "TeacherSettingsViewController.h"
#import "IQDropDownTextField.h"
#import "CustomTextField.h"

@interface AddGuideViewController ()<UITextViewDelegate>
{
    IBOutlet UITextField *txtPrice;
    IBOutlet IQDropDownTextField *txtSubject;
    IBOutlet UITextField *txtTitle;
    IBOutlet CustomTextField *txtGradelLevel;
    IBOutlet UIPlaceHolderTextView *txtDescription;
    IBOutlet UITextField *txtReferences;
}
@end

@implementation AddGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtDescription.placeholder = @"Enter study guide";
    [Util setCornerView:txtDescription];
    txtSubject.itemList = ARRAY_SUBJECT;
    
    txtSubject.delegate = self;
    txtTitle.delegate = self;
    txtDescription.delegate = self;
    
    txtPrice.delegate = self;
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
    PFObject *guide = [PFObject objectWithClassName:PARSE_TABLE_GUIDES];
    guide[PARSE_GUIDES_OWNER] = [PFUser currentUser];
    guide[PARSE_GUIDES_REFERENCE] = txtReferences.text;
    guide[PARSE_GUIDES_SUBJECT] = [NSNumber numberWithInteger:[txtSubject selectedRow]];
    guide[PARSE_GUIDES_GRADE_LEVEL] = [NSNumber numberWithInt:[txtGradelLevel.text intValue]];
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
            [Util showAlertTitle:self title:@"Create Study Guide" message:@"Success" finish:^(void){
                [self onback:nil];
                [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_CREATE_SUCCESS object:nil];
            }];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^{
                
            }];
        }
    }];
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

- (BOOL) isValid {
    txtPrice.text = [Util trim:txtPrice.text];
    txtDescription.text = [Util trim:txtDescription.text];
    txtTitle.text = [Util trim:txtTitle.text];
    txtGradelLevel.text = [Util trim:txtGradelLevel.text];
    txtReferences.text = [Util trim:txtReferences.text];
    txtDescription.text = [Util trim:txtDescription.text];
    if (txtPrice.text.length == 0){
        
    }
    [Util setBorderView:txtPrice color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtDescription color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtTitle color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtSubject color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtGradelLevel color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtReferences color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtDescription color:COLOR_TRANSPARENT width:1.0];
    double price = [txtPrice.text doubleValue];
    NSString *title = txtTitle.text;
    NSString *description = txtDescription.text;
    
    BOOL condition1 = (price < 0 || price > 10000);
    if (txtPrice.text.length == 0){
        condition1 = YES;
    }
    BOOL condition2 = (txtSubject.selectedRow == -1);
    BOOL condition3 = (title.length < 6 || title.length > 30);
    BOOL condition4 = (description.length > 60000 || description.length == 0);
    
    int count = 0;
    if (condition1){
        [Util setBorderView:txtPrice color:COLOR_RED width:1.0];
        count++;
    }
    if (condition2) {
        [Util setBorderView:txtSubject color:COLOR_RED width:1.0];
        count++;
    }
    if (condition3) {
        [Util setBorderView:txtTitle color:COLOR_RED width:1.0];
        count++;
    }
    if (condition4) {
        [Util setBorderView:txtDescription color:COLOR_RED width:1.0];
        count++;
    }
    if (count > 1){
        [Util showAlertTitle:self title:@"Error" message:@"Please check your entries and try again."];
        return NO;
    }
    
    if (condition1){
        [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank. Maximum price of $10,000 only." finish:^{
        }];
        return NO;
    }
    if (condition2){
        [Util showAlertTitle:self title:@"Error" message:@"Please select a subject." finish:^{
        }];
        return NO;
    }
    if (condition3){
        [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank. Minimum 6 letters, maximum of 30." finish:^{
        }];
        return NO;
    }
    if (condition4){
        if (description.length != 0)
            [Util showAlertTitle:self title:@"Error" message:@"We apologize, this can only hold a maximum of 60,000 characters." finish:^{
            }];
        else
            [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank." finish:^{
            }];
        return NO;
    }
    
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [Util setBorderView:textField color:COLOR_TRANSPARENT width:1.0];
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    [Util setBorderView:textView color:COLOR_TRANSPARENT width:1.0];
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
