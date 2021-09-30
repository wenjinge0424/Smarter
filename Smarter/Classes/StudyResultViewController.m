//
//  StudyResultViewController.m
//  Smarter
//
//  Created by gao on 9/1/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "StudyResultViewController.h"
#import "StudyViewController.h"
#import "BIZPopupViewController.h"
#import "StudentQuestionViewController.h"

@interface StudyResultViewController ()
{
    IBOutlet UITextView *txtQuestion;
    IBOutlet UILabel *lblNumber;
    IBOutlet UITextView *txtDescription;
    
}
@end

@implementation StudyResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    lblNumber.text = [NSString stringWithFormat:@"Question No.%d", self.index + 1];
    
    txtQuestion.text = self.object[PARSE_QUESTION_QUESTION];
    if (self.isCorrect){
        txtDescription.text = [NSString stringWithFormat:@"%@", @"CORRECT!"];
    } else {
        NSMutableArray *answers = self.object[PARSE_QUESTION_ANSWER_LIST];
        NSString *ch = [ALPHA_ARRAY objectAtIndex:[self.object[PARSE_QUESTION_CORRECT_NUM] integerValue]];
        if (_isSkip){
            txtDescription.text = [NSString stringWithFormat:@"Question is skipped. The correct answer is %@. %@", ch, [answers objectAtIndex:[self.object[PARSE_QUESTION_CORRECT_NUM] integerValue]]];
        } else {
            txtDescription.text = [NSString stringWithFormat:@"INCORRECT. The correct answer is %@. %@", ch, [answers objectAtIndex:[self.object[PARSE_QUESTION_CORRECT_NUM] integerValue]]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onClose:(id)sender {
    [self gotoNextScreen];
}

- (void) gotoNextScreen {
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

@end
