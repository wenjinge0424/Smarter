//
//  AddQuestionViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "AddQuestionViewController.h"
#import "IQDropDownTextField.h"

@interface AddQuestionViewController ()<UITableViewDelegate, UITableViewDataSource, IQDropDownTextFieldDelegate>
{
    IBOutlet IQDropDownTextField *txtSubject;
    IBOutlet IQDropDownTextField *txtGradeLevel;
    IBOutlet UIPlaceHolderTextView *txtQuestion;
    
    NSInteger correctIndex;
    IBOutlet UITextField *txtAnswerOne;
    IBOutlet UITextField *txtAnswerTwo;
    IBOutlet UITextField *txtAnswerThree;
    IBOutlet UITextField *txtAnswerFour;
    IBOutlet UIButton *btnOne;
    IBOutlet UIButton *btnTwo;
    IBOutlet UIButton *btnThree;
    IBOutlet UIButton *btnFour;
    IBOutlet UIView *viewSubject;
    IBOutlet UIView *viewGrade;
}
@end

@implementation AddQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:txtQuestion];
    [Util setCornerView:viewSubject];
    [Util setCornerView:viewGrade];
    
    txtQuestion.placeholder = @"Type your question...";
    txtSubject.itemList = ARRAY_SUBJECT;
    txtGradeLevel.itemList = ARRAY_GRADE;
    
    correctIndex = -1;
    
    txtSubject.delegate = self;
    txtGradeLevel.delegate = self;
    txtQuestion.delegate = self;
    txtAnswerOne.delegate = self;
    txtAnswerTwo.delegate = self;
    txtAnswerThree.delegate = self;
    txtAnswerFour.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender {
    if (![self isValid]){
        return;
    }
    NSString *msg = @"Are you sure you want to add this to your student’s study questions?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = NO;
    [alert addButton:@"Confirm" actionBlock:^(void) {
        [self saveQuestion];
    }];
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert showError:@"Create Question" subTitle:msg closeButtonTitle:nil duration:0.0f];
}

- (void) saveQuestion {
    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_QUESTION];
    object[PARSE_QUESTION_QUESTION] = txtQuestion.text;
    object[PARSE_QUESTION_CORRECT_NUM] = [NSNumber numberWithInteger:correctIndex];
    object[PARSE_QUESTION_OWNER] = [PFUser currentUser];
    object[PARSE_QUESTION_SUBJECT] = [NSNumber numberWithInteger:txtSubject.selectedRow];
    object[PARSE_QUESTION_GRADE] = [NSNumber numberWithInteger:(txtGradeLevel.selectedRow + 1)];
    NSMutableArray *answers = [[NSMutableArray alloc] init];
    [answers addObject:txtAnswerOne.text];
    [answers addObject:txtAnswerTwo.text];
    [answers addObject:txtAnswerThree.text];
    [answers addObject:txtAnswerFour.text];
    object[PARSE_QUESTION_ANSWER_LIST] = answers;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                [self onback:nil];
            }];
        }
    }];
}

- (void) removeHighLight {
    [Util setBorderView:viewSubject color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:viewGrade color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtQuestion color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtAnswerOne color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtAnswerTwo color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtAnswerThree color:COLOR_TRANSPARENT width:1.0];
    [Util setBorderView:txtAnswerFour color:COLOR_TRANSPARENT width:1.0];
}

- (BOOL) isValid {
    [self removeHighLight];
    
    if (txtSubject.selectedRow == -1){
        [Util showAlertTitle:self title:@"Error" message:@"Please select a subject."];
        [Util setBorderView:viewSubject color:COLOR_RED width:1.0];
        return NO;
    }
    if (txtGradeLevel.selectedRow == -1){
        [Util showAlertTitle:self title:@"Error" message:@"Please select a grade level."];
        [Util setBorderView:viewGrade color:COLOR_RED width:1.0];
        return NO;
    }
    txtQuestion.text = [Util trim:txtQuestion.text];
    NSString *question = txtQuestion.text;
    if (question.length == 0 || question.length > 300){
        [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank. Maximum length of 300 only." finish:^(void){
            [Util setBorderView:txtQuestion color:COLOR_RED width:1.0];
        }];
        return NO;
    }
    
    txtAnswerOne.text = [Util trim:txtAnswerOne.text];
    txtAnswerTwo.text = [Util trim:txtAnswerTwo.text];
    txtAnswerThree.text = [Util trim:txtAnswerThree.text];
    txtAnswerFour.text = [Util trim:txtAnswerFour.text];
    
    if (txtAnswerOne.text.length == 0 || txtAnswerOne.text.length > 20){
        [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank. Maximum length of 20 only." finish:^(void){
            [Util setBorderView:txtAnswerOne color:COLOR_RED width:1.0];
        }];
        return NO;
    }
    if (txtAnswerTwo.text.length == 0 || txtAnswerTwo.text.length > 20){
        [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank. Maximum length of 20 only." finish:^(void){
            [Util setBorderView:txtAnswerTwo color:COLOR_RED width:1.0];
        }];
        return NO;
    }
    if (txtAnswerThree.text.length == 0 || txtAnswerThree.text.length > 20){
        [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank. Maximum length of 20 only." finish:^(void){
            [Util setBorderView:txtAnswerThree color:COLOR_RED width:1.0];
        }];
        return NO;
    }
    if (txtAnswerFour.text.length == 0 || txtAnswerFour.text.length > 20){
        [Util showAlertTitle:self title:@"Error" message:@"Do not leave blank. Maximum length of 20 only." finish:^(void){
            [Util setBorderView:txtAnswerFour color:COLOR_RED width:1.0];
        }];
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

- (IBAction)onSubject:(id)sender {
    [txtSubject becomeFirstResponder];
}
- (IBAction)onGrade:(id)sender {
    [txtGradeLevel becomeFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self removeHighLight];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == txtAnswerOne){
        [txtAnswerTwo becomeFirstResponder];
    } else if (textField == txtAnswerTwo){
        [txtAnswerThree becomeFirstResponder];
    } else if (textField == txtAnswerThree){
        [txtAnswerFour becomeFirstResponder];
    } else if (textField == txtAnswerFour){
        [self.view endEditing:YES];
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
