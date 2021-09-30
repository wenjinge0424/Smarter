
//
//  StudyViewController.m
//  Smarter
//
//  Created by gao on 9/1/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "StudyViewController.h"
#import "StudyResultViewController.h"
#import "BIZPopupViewController.h"
#import "StudentViewController.h"
#import "StudentQuestionViewController.h"

@interface StudyViewController ()
{
    IBOutlet UILabel *lblNumber;
    
    IBOutlet UILabel *lblQuestion;
    IBOutlet UILabel *lblOne;
    IBOutlet UILabel *lblTwo;
    IBOutlet UILabel *lblThree;
    IBOutlet UILabel *lblFour;
    
    NSInteger correctNumber;
    NSTimer *timer;
    IBOutlet UITextView *txtQuestion;
}
@end

@implementation StudyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [txtQuestion setHidden:YES];
    [Util setCircleView:lblNumber];
    lblNumber.text = [NSString stringWithFormat:@"Question No.%d", self.index + 1];
    self.object = [self.object fetchIfNeeded];
    lblQuestion.text = self.object[PARSE_QUESTION_QUESTION];
    NSMutableArray *answers = self.object[PARSE_QUESTION_ANSWER_LIST];
    lblOne.text = [NSString stringWithFormat:@"A. %@", [answers objectAtIndex:0]];
    lblTwo.text = [NSString stringWithFormat:@"B. %@", [answers objectAtIndex:1]];
    lblThree.text = [NSString stringWithFormat:@"C. %@", [answers objectAtIndex:2]];
    lblFour.text = [NSString stringWithFormat:@"D. %@", [answers objectAtIndex:3]];
    correctNumber = [self.object[PARSE_QUESTION_CORRECT_NUM] integerValue];
    
    if ([Util getBoolValue:ALARM_ALLOW]){
//        AudioServicesPlaySystemSound (1103);
        [Util playSound];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:60
                                                      target:self
                                                    selector:@selector(checkState)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkState {
    if ([timer isValid]){
        [timer invalidate];
    }
    timer = nil;
    [self skipToNextScreen:4];
}


- (IBAction)onClickOne:(id)sender {
    if (correctNumber == 0){
        [self saveHistory:YES number:0];
    } else {
        [self saveHistory:NO number:0];
    }
}

- (IBAction)onClickTwo:(id)sender {
    if (correctNumber == 1){
        [self saveHistory:YES number:1];
    } else
        [self saveHistory:NO number:1];
}

- (IBAction)onClickThree:(id)sender {
    if (correctNumber == 2){
        [self saveHistory:YES number:2];
    } else {
        [self saveHistory:NO number:2];
    }
}

- (IBAction)onClickFour:(id)sender {
    if (correctNumber == 3){
        [self saveHistory:YES number:3];
    } else {
        [self saveHistory:NO number:3];
    }
}

- (void) saveHistory:(BOOL)isCorrect number:(NSInteger )number{
    PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_STUDY_LOGS];
    if (isCorrect){
        object[PARSE_STUDY_IS_CORRECT] = @YES;
    } else {
        object[PARSE_STUDY_IS_CORRECT] = @NO;
    }
    object[PARSE_STUDY_QUESTION] = self.object;
    object[PARSE_STUDY_ANSWER] = [NSNumber numberWithInteger:number];
    object[PARSE_STUDY_STUDY_NUMBER] = self.timeStamp;
    object[PARSE_STUDY_SUB_NUMBER] = [NSNumber numberWithInteger:self.index + 1];
    object[PARSE_STUDY_OWNER] = [PFUser currentUser];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [object saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            [self gotoNextScreen:isCorrect number:number];
        }
    }];
}

- (IBAction)onSkip:(id)sender {
    [self saveHistory:NO number:4];
}

- (void) gotoNextScreen:(BOOL)correct number:(NSInteger)num {
    CGFloat width = self.view.frame.size.width - 40;
    CGSize size = CGSizeMake(280, 300);
    StudyResultViewController *vc = (StudyResultViewController *)[Util getUIViewControllerFromStoryBoard:@"StudyResultViewController"];
    vc.object = self.object;
    vc.count = self.count;
    vc.timeStamp = self.timeStamp;
    vc.isCorrect = correct;
    vc.index = self.index;
    vc.dataArray = self.dataArray;
    if (num == 4){
        vc.isSkip = YES;
    } else {
        vc.isSkip = NO;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    if ([timer isValid]){
        [timer invalidate];
    }
    timer = nil;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:vc contentSize:size];
    [[StudentQuestionViewController getInstance] pushViewController:popUp];
}
- (void) skipToNextScreen:(NSInteger)num
{
    if (self.index >= self.dataArray.count - 1){
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    CGFloat width = self.view.frame.size.width - 40;
    CGSize size = CGSizeMake(280, 400);
    StudyViewController *vc = (StudyViewController *)[Util getUIViewControllerFromStoryBoard:@"StudyViewController"];
    vc.count = self.count;
    vc.timeStamp = self.timeStamp;
    vc.dataArray = self.dataArray;
    vc.index = self.index + 1;
    vc.timeStamp = self.timeStamp;
    vc.object = [_dataArray objectAtIndex:(self.index + 1)];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:vc contentSize:size];
    [[StudentQuestionViewController getInstance] pushViewController:popUp];
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
