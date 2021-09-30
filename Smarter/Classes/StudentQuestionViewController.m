//
//  StudentQuestionViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "StudentQuestionViewController.h"
#import "IQDropDownTextField.h"
#import "GuideViewController.h"
#import "StudyViewController.h"
#import "BIZPopupViewController.h"
#import "StudentViewController.h"
#import "MyAssignmentsViewController.h"

static StudentQuestionViewController *_sharedViewController = nil;

@interface StudentQuestionViewController ()<IQDropDownTextFieldDelegate>
{
    IBOutlet UIView *contentView;
    IBOutlet IQDropDownTextField *txtNumberQuestions;
    
    IBOutlet IQDropDownTextField *txtSubject;
    IBOutlet IQDropDownTextField *txtMinutes;
    IBOutlet IQDropDownTextField *txtAge;
    IBOutlet UISwitch *txtAlarm;
    
    NSMutableArray *dataArray;
    
    IBOutlet UIView *viewCategory;
    IBOutlet UIView *viewQuestions;
    IBOutlet UIView *viewMins;
    IBOutlet UIView *viewAge;
    
}
@end

@implementation StudentQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerView:contentView];
    [Util setCornerView:viewCategory];
    
    txtSubject.itemList = ARRAY_SUBJECT;
    txtNumberQuestions.itemList = (NSArray *)[ARRAY_NUMBER_QUESTIONS copy];
    txtMinutes.itemList = (NSArray *)[ARRAY_NUMBER_MINUTES copy];
    txtAge.itemList = (NSArray *)[ARRAY_NUMBER_AGE copy];
    
    [txtNumberQuestions setSelectedRow:1];
    [txtMinutes setSelectedRow:1];
    [txtAge setSelectedRow:1];
    
    _sharedViewController = self;
    [Util setBoolValue:ALARM_ALLOW value:txtAlarm.isOn];
    
    txtSubject.delegate = self;
    txtNumberQuestions.delegate = self;
    txtMinutes.delegate = self;
    txtAge.delegate = self;
    txtNumberQuestions.delegate = self;
}

+(StudentQuestionViewController *) getInstance {
    return _sharedViewController;
}

- (void) pushViewController:(UIViewController *)vc {
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onGuide:(id)sender {
    GuideViewController *vc = (GuideViewController *)[Util getUIViewControllerFromStoryBoard:@"GuideViewController"];
    [[StudentViewController getInstance] pushViewController:vc];
}

- (IBAction)onStartStudying:(id)sender {
    if (![self isValid]){
        return;
    }
    int number = 5;
    PFUser *me = [PFUser currentUser];
    me = [me fetchIfNeeded];
    PFUser *parent = me[PARSE_USER_PARENT];
    if(!parent){
        [Util showAlertTitle:self title:@"Warning" message:@"No parent found."];
    }
        
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_QUESTION];
    [query whereKey:PARSE_QUESTION_OWNER equalTo:parent];
    [query whereKey:PARSE_QUESTION_SUBJECT equalTo:[NSNumber numberWithInteger:txtSubject.selectedRow]];
    [query setLimit:1000];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (array.count > number){
            dataArray = (NSMutableArray *) [array subarrayWithRange:NSMakeRange(0, number)];
        } else {
            dataArray = (NSMutableArray *) array;
        }
        if (dataArray.count > 0)
            [self startTest];
        else
            [Util showAlertTitle:self title:@"Warning" message:@"No guide found."];
    }];
}

- (IBAction)onAnswerAssignment:(id)sender {
    MyAssignmentsViewController *vc = (MyAssignmentsViewController *)[Util getUIViewControllerFromStoryBoard:@"MyAssignmentsViewController"];
    [[StudentViewController getInstance] pushViewController:vc];
}

- (void) startTest {
    [Util setInterval:[[ARRAY_NUMBER_MINUTES objectAtIndex:txtMinutes.selectedRow] integerValue]];
    [Util setBoolValue:ALARM_ALLOW value:txtAlarm.isOn];
    NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    
    CGFloat width = self.view.frame.size.width - 40;
    CGSize size = CGSizeMake(280, 400);
    StudyViewController *vc = (StudyViewController *)[Util getUIViewControllerFromStoryBoard:@"StudyViewController"];
    vc.object = (PFObject *) [dataArray objectAtIndex:0];
    vc.count = dataArray.count;
    vc.timeStamp = intervalString;
    vc.dataArray = dataArray;
    vc.index = 0;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:vc contentSize:size];
    [self presentViewController:popUp animated:YES completion:nil];
}

- (void) startTest:(NSDictionary *) data {
    NSInteger age = [[data objectForKey:@"age"] integerValue];
    BOOL alarm = [[data objectForKey:@"alarm"] boolValue];
    NSInteger numberofQuestions = [[data objectForKey:@"max"] integerValue];
    NSInteger minutes = [[data objectForKey:@"time"] integerValue];
    NSInteger subject = [[data objectForKey:@"subject"] integerValue];
    
    PFUser *me = [PFUser currentUser];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    me = [me fetchIfNeeded];
    PFUser *parent = me[PARSE_USER_PARENT];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_QUESTION];
    [query whereKey:PARSE_QUESTION_OWNER equalTo:parent];
    [query whereKey:PARSE_QUESTION_SUBJECT equalTo:[NSNumber numberWithInteger:subject]];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (array.count > numberofQuestions){
            dataArray = (NSMutableArray *) [array subarrayWithRange:NSMakeRange(0, numberofQuestions)];
        } else {
            dataArray = (NSMutableArray *) array;
        }
        if (dataArray.count > 0){
            [Util setInterval:minutes];
            [Util setBoolValue:ALARM_ALLOW value:alarm];
            NSTimeInterval  today = [[NSDate date] timeIntervalSince1970];
            NSString *intervalString = [NSString stringWithFormat:@"%f", today];
            
            CGFloat width = self.view.frame.size.width - 40;
            CGSize size = CGSizeMake(280, 450);
            StudyViewController *vc = (StudyViewController *)[Util getUIViewControllerFromStoryBoard:@"StudyViewController"];
            vc.object = (PFObject *) [dataArray objectAtIndex:0];
            vc.count = dataArray.count;
            vc.timeStamp = intervalString;
            vc.dataArray = dataArray;
            vc.index = 0;
            BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:vc contentSize:size];
            [self presentViewController:popUp animated:YES completion:nil];
        } else
            [Util showAlertTitle:self title:@"Warning" message:@"No guide found."];
    }];
}

- (BOOL) isValid {
    [self removeHightLight];
    
    int errCount = 0;
    
    if (txtSubject.selectedRow == -1){
        [Util setBorderView:viewCategory color:COLOR_RED width:1.0];
        errCount++;
    }
    if (txtNumberQuestions.selectedRow == -1){
        [Util setBorderView:viewQuestions color:COLOR_RED width:1.0];
        errCount++;
    }
    if (txtMinutes.selectedRow == -1){
        [Util setBorderView:viewMins color:COLOR_RED width:1.0];
        errCount++;
    }
    if (txtAge.selectedRow == -1){
        [Util setBorderView:viewAge color:COLOR_RED width:1.0];
        errCount++;
    }
    if (errCount > 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please make sure all settings are filled up."];
        return NO;
    }
    return YES;
}

- (void) removeHightLight {
    [Util setBorderView:viewCategory color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:viewQuestions color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:viewAge color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:viewMins color:COLOR_TRANSPARENT width:1.0];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onCategory:(id)sender {
    [txtSubject becomeFirstResponder];
}
- (IBAction)onMinutes:(id)sender {
    [txtMinutes becomeFirstResponder];
}
- (IBAction)onAge:(id)sender {
    [txtAge becomeFirstResponder];
}

- (IBAction)onQuestions:(id)sender {
    [txtNumberQuestions becomeFirstResponder];
}

- (IBAction)onAlarmEvent:(id)sender {
    [Util setBoolValue:ALARM_ALLOW value:txtAlarm.isOn];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self.view endEditing:YES];
}

@end
