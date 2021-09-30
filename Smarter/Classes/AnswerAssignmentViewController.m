//
//  AnswerAssignmentViewController.m
//  Smarter
//
//  Created by gao on 10/23/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "AnswerAssignmentViewController.h"

@interface AnswerAssignmentViewController ()
{
    IBOutlet UITextField *txtTitle;
    IBOutlet UIPlaceHolderTextView *txtQuestion;
    
    IBOutlet UITextField *txtAnswerone;
    IBOutlet UIButton *btnOne;
    IBOutlet UITextField *txtAnswerTwo;
    IBOutlet UIButton *btnTwo;
    IBOutlet UITextField *txtAnswerThree;
    IBOutlet UIButton *btnThree;
    IBOutlet UITextField *txtAnswerFour;
    IBOutlet UIButton *btnFour;
    
    NSInteger correctIndex;
    IBOutlet UILabel *lblCount;
    
    NSMutableArray *dataArray;
    int subNumber;
}
@end

@implementation AnswerAssignmentViewController
@synthesize assignment;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    subNumber = -1;
    [self refreshItems];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshItems {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_ASSIGNMENT];
    PFUser *me = [PFUser currentUser];
    NSMutableArray *teachers = me[PARSE_USER_TEACHER_LIST];
    [query whereKey:PARSE_ASSIGN_OWNER containedIn:teachers];
    [query whereKey:PARSE_ASSIGN_NUMBER equalTo:assignment[PARSE_ASSIGN_NUMBER]];
    [query addDescendingOrder:PARSE_ASSIGN_NUMBER];
    [query includeKey:PARSE_ASSIGN_OWNER];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) array;
            [self initData];
        }
    }];
}

- (IBAction)onback:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) initData {
    subNumber++;
    PFUser *user = assignment[PARSE_ANSWER_OWNER];
    user = [user fetchIfNeeded];
    
    txtTitle.text = [NSString stringWithFormat:@"%@ by (%@)", assignment[PARSE_ASSIGN_TITLE], user[PARSE_USER_FULLNAME]];
    lblCount.text = [NSString stringWithFormat:@"Question %d of %ld:", (subNumber+1), [assignment[PARSE_ASSIGN_COUNT] integerValue]];
    
    PFObject *object = [dataArray objectAtIndex:subNumber];
    NSMutableArray *answerList = object[PARSE_ASSIGN_ANSWER_LIST];
    txtQuestion.text = object[PARSE_ASSIGN_QUESTION];
    txtAnswerone.text = [answerList objectAtIndex:0];
    txtAnswerTwo.text = [answerList objectAtIndex:1];
    txtAnswerThree.text = [answerList objectAtIndex:2];
    txtAnswerFour.text = [answerList objectAtIndex:3];
    [self onChooseAnswer:nil];
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    
    if (subNumber == 0){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        PFQuery *delQuery = [PFQuery queryWithClassName:PARSE_TABLE_ANSWER_LOGS];
        [delQuery whereKey:PARSE_ANSWER_OWNER equalTo:[PFUser currentUser]];
        [delQuery whereKey:PARSE_ANSWER_ASSIGNMENT_NUMBER equalTo:assignment[PARSE_ASSIGN_NUMBER]];
        [delQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *err){
            if (err == nil && array.count > 0){
                [PFObject deleteAllInBackground:array block:^(BOOL succeed, NSError *errInfo){
                    if (errInfo == nil){
                        [self registerAssign];
                    } else {
                        [SVProgressHUD dismiss];
                        [Util showAlertTitle:self title:@"Error" message:[errInfo localizedDescription]];
                    }
                }];
            } else if (err) {
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Error" message:[err localizedDescription]];
            } else {
                [self registerAssign];
            }
        }];
    } else {
        [self registerAssign];
    }
}

- (void) registerAssign {
    PFObject *object = [dataArray objectAtIndex:subNumber];
    BOOL isCorrect = (correctIndex == [object[PARSE_ASSIGN_CORRECT_ANSWER] integerValue]);
    PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_ANSWER_LOGS];
    if (isCorrect)
        obj[PARSE_ANSWER_CORRECT] = @YES;
    else
        obj[PARSE_ANSWER_CORRECT] = @NO;
    obj[PARSE_ANSWER_ASSIGNMENT] = object;
    obj[PARSE_ANSWER_ASSIGNMENT_NUMBER] = object[PARSE_ASSIGN_NUMBER];
    obj[PARSE_ANSWER_OWNER] = [PFUser currentUser];
    obj[PARSE_ANSWER_ANSWER] = [NSNumber numberWithInteger:correctIndex];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            NSInteger count = [assignment[PARSE_ASSIGN_COUNT] integerValue];
            if (subNumber+1 >= count){
                [Util showAlertTitle:self title:@"" message:@"All Done!" finish:^(void){
                    [self onback:nil];
                }];
            } else {
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                    [self initData];
                }];
            }
        }
    }];
}

- (BOOL) isValid {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return NO;
    }
    if (correctIndex == -1){
        [Util showAlertTitle:self title:@"Error" message:@"Please choose your answer."];
        return NO;
    }
    
    return YES;
}

- (IBAction)onChooseAnswer:(id)sender {
    btnOne.selected = NO;
    btnTwo.selected = NO;
    btnThree.selected = NO;
    btnFour.selected = NO;
    NSInteger tag = [sender tag];
    correctIndex = tag - 101;
    if (tag == 101){
        btnOne.selected = YES;
    } else if (tag == 102){
        btnTwo.selected = YES;
    } else if (tag == 103){
        btnThree.selected = YES;
    } else if (tag == 104){
        btnFour.selected = YES;
    }
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
