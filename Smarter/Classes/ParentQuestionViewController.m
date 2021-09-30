//
//  ParentQuestionViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "IQDropDownTextField.h"
#import "ParentQuestionViewController.h"

@interface ParentQuestionViewController ()<IQDropDownTextFieldDelegate>
{
    IBOutlet IQDropDownTextField *txtNumberQuestions;
    IBOutlet UIView *contentView;
    IBOutlet IQDropDownTextField *txtSubjects;
    IBOutlet IQDropDownTextField *txtMinutes;
    
    IBOutlet IQDropDownTextField *txtAge;
    IBOutlet IQDropDownTextField *txtStudents;
    
    NSMutableArray *dataArray;
    PFUser *me;
    IBOutlet UISwitch *switchAlarm;
    
    
    IBOutlet UIView *viewCategory;
    IBOutlet UIView *viewNumber;
    IBOutlet UIView *viewMins;
    IBOutlet UIView *viewAge;
    IBOutlet UIView *viewStudent;
}
@end

@implementation ParentQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:contentView];
    [Util setCornerView:viewCategory];
    [Util setCornerView:viewStudent];
    
    txtSubjects.itemList = ARRAY_SUBJECT;
    txtSubjects.isOptionalDropDown = YES;
    txtNumberQuestions.itemList = ARRAY_NUMBER_QUESTIONS;
    txtNumberQuestions.isOptionalDropDown = NO;
    txtMinutes.itemList = ARRAY_NUMBER_MINUTES;
    txtMinutes.isOptionalDropDown = NO;
    txtAge.itemList = ARRAY_NUMBER_AGE;
    txtAge.isOptionalDropDown = NO;
    txtStudents.itemList = ARRAY_NUMBER_AGE;
    
    txtNumberQuestions.selectedRow = -1;
    txtMinutes.selectedRow = -1;
    txtAge.selectedRow = -1;
    txtStudents.selectedRow = -1;
    
    txtNumberQuestions.delegate = self;
    txtSubjects.delegate = self;
    txtMinutes.delegate = self;
    txtStudents.delegate = self;
    txtAge.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self removeHightLight];
    
    txtSubjects.itemList = nil;
    
    [txtSubjects setSelectedRow:-1];
    [txtNumberQuestions setSelectedRow:0];
    [txtMinutes setSelectedRow:0];
    [txtAge setSelectedRow:0];
    [txtStudents setSelectedRow:-1];
    
    [txtSubjects setSelectedItem:@""];
    [txtNumberQuestions setSelectedItem:@"5"];
    [txtMinutes setSelectedItem:@"1"];
    [txtAge setSelectedItem:@"1"];
    [txtStudents setSelectedItem:@""];
    
    txtSubjects.text = @"";
    txtNumberQuestions.text = @"5";
    txtMinutes.text = @"1";
    txtAge.text = @"1";
    txtStudents.text = @"";
    
    
    me = [PFUser currentUser];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me fetchInBackgroundWithBlock:^(PFObject *user, NSError *error){
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            NSMutableArray *array = user[PARSE_USER_STUDENT_LIST];
            dataArray = [[NSMutableArray alloc] init];
            for (int i=0;i<array.count;i++){
                PFUser *user = [array objectAtIndex:i];
                [dataArray addObject:user[PARSE_USER_FULLNAME]];
            }
            txtStudents.itemList = dataArray;
        }
        [SVProgressHUD dismiss];
    }];
    
    txtSubjects.itemList = ARRAY_SUBJECT;
}
- (IBAction)onSubject:(id)sender {
    [txtSubjects becomeFirstResponder];
}
- (IBAction)onQuestions:(id)sender {
    [txtNumberQuestions becomeFirstResponder];
}
- (IBAction)onMinuets:(id)sender {
    [txtMinutes becomeFirstResponder];
}
- (IBAction)onAge:(id)sender {
    [txtAge becomeFirstResponder];
}
- (IBAction)onStudent:(id)sender {
    [txtStudents becomeFirstResponder];
}
- (IBAction)onStartStudy:(id)sender {
    if (![self isValid]){
        return;
    }
    
    NSInteger subject = txtSubjects.selectedRow;
    NSInteger max = [txtNumberQuestions.selectedItem integerValue];
    NSInteger mins = [txtMinutes.selectedItem integerValue];
    NSInteger age = [txtAge.selectedItem integerValue];
    BOOL alarm = switchAlarm.isOn;
    NSMutableArray *array = me[PARSE_USER_STUDENT_LIST];
    PFUser *toUser = [array objectAtIndex:txtStudents.selectedRow];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInteger:max], @"max",
                         [NSNumber numberWithInteger:mins], @"time",
                         (alarm?@YES:@NO), @"alarm",
                         [NSNumber numberWithInteger:subject], @"subject",
                         [NSNumber numberWithInteger:age], @"age",
                         nil];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          toUser.username, @"email",
                          @"", @"alert",
                          @"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          dic, @"data",
                          [NSNumber numberWithInt:NOTIFICATION_START_STUDY], @"type",
                          nil];
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_QUESTION];
    [query whereKey:PARSE_QUESTION_OWNER equalTo:me];
    [query whereKey:PARSE_QUESTION_SUBJECT equalTo:[NSNumber numberWithInteger:subject]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            if (array.count == 0){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Error" message:@"No question for selected subject."];
            } else {
                [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                    [SVProgressHUD dismiss];
                    if (err) {
                        [Util showAlertTitle:self title:@"Error" message:[err localizedDescription]];
                    } else {
                        [Util showAlertTitle:self title:@"Success" message:@"Push sent."];
                    }
                }];
            }
        }
    }];
}

- (void) removeHightLight {
    [Util setBorderView:viewCategory color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:viewStudent color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:viewNumber color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:viewAge color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:viewMins color:COLOR_TRANSPARENT width:1.0];
}

- (BOOL) isValid {
    [self removeHightLight];
    
    int errCnt = 0;
    
    if (txtSubjects.selectedRow == -1 || !txtSubjects.hasText){
        [Util setBorderView:viewCategory color:COLOR_RED width:1.0];
        errCnt++;
    }
    if (txtNumberQuestions.selectedRow == -1){
        [Util setBorderView:viewNumber color:COLOR_RED width:1.0];
        errCnt++;
    }
    if (txtMinutes.selectedRow == -1){
        [Util setBorderView:viewMins color:COLOR_RED width:1.0];
        errCnt++;
    }
    if (txtAge.selectedRow == -1){
        [Util setBorderView:viewAge color:COLOR_RED width:1.0];
        errCnt++;
    }
    if (txtStudents.selectedRow == -1){
        [Util setBorderView:viewStudent color:COLOR_RED width:1.0];
        errCnt++;
    }
    
    if (errCnt > 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please make sure all settings are filled up."];
        return NO;
    }
    
    return YES;
}

- (void) textField:(IQDropDownTextField *)textField didSelectItem:(NSString *)item {
    [self removeHightLight];
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
