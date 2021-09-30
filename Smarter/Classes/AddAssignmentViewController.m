//
//  AddAssignmentViewController.m
//  Smarter
//
//  Created by gao on 10/23/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "AddAssignmentViewController.h"
#import "IQKeyboardManager.h"

@interface AddAssignmentViewController ()<UIScrollViewDelegate, UITableViewDelegate>
{
    IBOutlet UIPlaceHolderTextView *txtQuestion;
    
    IBOutlet UITextField *txtAnswerOne;
    IBOutlet UIButton *btnOne;
    IBOutlet UITextField *txtAnswerTwo;
    IBOutlet UIButton *btnTwo;
    IBOutlet UITextField *txtAnswerThree;
    IBOutlet UIButton *btnThree;
    IBOutlet UITextField *txtAnswerFour;
    IBOutlet UIButton *btnFour;
    
    NSInteger correctIndex;
    NSInteger subNumber;
    IBOutlet UITextField *txtTitle;
    NSString *index;
    IBOutlet UITableView *tableview;
}
@end

@implementation AddAssignmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:txtQuestion];
    txtQuestion.placeholder = @"Type your question...";
    
    index = [Util convertDate2StringWithFormat:[NSDate date] dateFormat:@"yyyyMMddHHmmss"];
    subNumber = 0;
    [self initData];
    
    tableview.delegate = self;
    
    txtAnswerOne.delegate = self;
    txtAnswerTwo.delegate = self;
    txtAnswerThree.delegate = self;
    txtAnswerFour.delegate = self;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void) initData {
    correctIndex = -1;
    [self onChooseAnswer:nil];
    if (subNumber == 0){
        txtTitle.enabled = YES;
        txtTitle.text = @"";
    } else {
        txtTitle.enabled = NO;
    }
    txtAnswerOne.text = @"";
    txtAnswerTwo.text = @"";
    txtAnswerThree.text = @"";
    txtAnswerFour.text = @"";
    txtQuestion.text = @"";
    
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
    NSString *msg = @"Are you sure you want to add this to your student's assignment?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"CANCEL" actionBlock:^(void) {
    }];
    [alert addButton:@"CONFIRM" actionBlock:^(void) {
        if (![self isValid]){
            return;
        }
        subNumber++;
        NSMutableArray *answerList = [[NSMutableArray alloc] init];
        [answerList addObject:txtAnswerOne.text];
        [answerList addObject:txtAnswerTwo.text];
        [answerList addObject:txtAnswerThree.text];
        [answerList addObject:txtAnswerFour.text];
        PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_ASSIGNMENT];
        object[PARSE_ASSIGN_OWNER] = [PFUser currentUser];
        object[PARSE_ASSIGN_NUMBER] = index;
        object[PARSE_ASSIGN_SUBNUMBER] = [NSNumber numberWithInteger:subNumber];
        object[PARSE_ASSIGN_TITLE] = txtTitle.text;
        object[PARSE_ASSIGN_QUESTION] = txtQuestion.text;
        object[PARSE_ASSIGN_CORRECT_ANSWER] = [NSNumber numberWithInteger:correctIndex];
        object[PARSE_ASSIGN_ANSWER_LIST] = answerList;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (succeed){
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                    [self onback:nil];
                    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_CREATE_SUCCESS object:nil];
                }];
            } else {
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            }
        }];
    }];
    [alert showError:@"Sign Up" subTitle:msg closeButtonTitle:nil duration:0.0f];
}

- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    subNumber++;
    NSMutableArray *answerList = [[NSMutableArray alloc] init];
    [answerList addObject:txtAnswerOne.text];
    [answerList addObject:txtAnswerTwo.text];
    [answerList addObject:txtAnswerThree.text];
    [answerList addObject:txtAnswerFour.text];
    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_ASSIGNMENT];
    object[PARSE_ASSIGN_OWNER] = [PFUser currentUser];
    object[PARSE_ASSIGN_NUMBER] = index;
    object[PARSE_ASSIGN_SUBNUMBER] = [NSNumber numberWithInteger:subNumber];
    object[PARSE_ASSIGN_TITLE] = txtTitle.text;
    object[PARSE_ASSIGN_QUESTION] = txtQuestion.text;
    object[PARSE_ASSIGN_CORRECT_ANSWER] = [NSNumber numberWithInteger:correctIndex];
    object[PARSE_ASSIGN_ANSWER_LIST] = answerList;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (succeed){
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                [self initData];
            }];
        } else {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }
    }];
}

- (BOOL) isValid {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return NO;
    }
    txtTitle.text = [Util trim:txtTitle.text];
    txtQuestion.text = [Util trim:txtQuestion.text];
    txtAnswerOne.text = [Util trim:txtAnswerOne.text];
    txtAnswerTwo.text = [Util trim:txtAnswerTwo.text];
    txtAnswerThree.text = [Util trim:txtAnswerThree.text];
    txtAnswerFour.text = [Util trim:txtAnswerFour.text];
    NSString *title = txtTitle.text;
    NSString *question = txtQuestion.text;
    NSString *answerOne = txtAnswerOne.text;
    NSString *answerTwo = txtAnswerTwo.text;
    NSString *answerThree = txtAnswerThree.text;
    NSString *answerFour = txtAnswerFour.text;
    if (title.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your title." finish:^(void){
            [txtTitle becomeFirstResponder];
        }];
        return NO;
    }
    if (question.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your title." finish:^(void){
            [txtQuestion becomeFirstResponder];
        }];
        return NO;
    }
    if (question.length > 300){
        [Util showAlertTitle:self title:@"Error" message:@"Question is too long." finish:^(void){
            [txtQuestion becomeFirstResponder];
        }];
        return NO;
    }
    if (answerOne.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your answer A." finish:^(void){
            
        }];
        return NO;
    }
    if (answerTwo.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your answer B." finish:^(void){
            
        }];
        return NO;
    }
    if (answerThree.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your answer C." finish:^(void){
            
        }];
        return NO;
    }
    if (answerFour.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your answer D." finish:^(void){
            
        }];
        return NO;
    }
    if (answerOne.length > 20){
        [Util showAlertTitle:self title:@"Error" message:@"Answer A is too long." finish:^(void){
            
        }];
        return NO;
    }
    if (answerTwo.length > 20){
        [Util showAlertTitle:self title:@"Error" message:@"Answer B is too long." finish:^(void){
            
        }];
        return NO;
    }
    if (answerThree.length > 20){
        [Util showAlertTitle:self title:@"Error" message:@"Answer C is too long." finish:^(void){
            
        }];
        return NO;
    }
    if (answerFour.length > 20){
        [Util showAlertTitle:self title:@"Error" message:@"Answer D is too long." finish:^(void){
            
        }];
        return NO;
    }
    if (correctIndex < 0){
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

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
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
