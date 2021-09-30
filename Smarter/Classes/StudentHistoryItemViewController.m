//
//  StudentHistoryItemViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "StudentHistoryItemViewController.h"

@interface StudentHistoryItemViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIView *viewContent;
    
    IBOutlet UILabel *lblDate;
    IBOutlet UILabel *lblScore;
    IBOutlet UITableView *tableview;
    NSMutableArray *dataArray;
    
}
@end

@implementation StudentHistoryItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lblDate.text = self.date;
    lblScore.text = self.score;
    [Util setCornerView:viewContent];
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) refreshItems {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_STUDY_LOGS];
    [query whereKey:PARSE_STUDY_OWNER equalTo:[PFUser currentUser]];
    [query whereKey:PARSE_STUDY_STUDY_NUMBER equalTo:self.studyNumber];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error) {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) array;
            [tableview reloadData];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellHistory"];
    UILabel *lblQuestion = (UILabel *)[cell viewWithTag:1];
    UILabel *lblAnswer = [cell viewWithTag:2];
    
    PFObject *log = [dataArray objectAtIndex:indexPath.row];
    PFObject *question = log[PARSE_STUDY_QUESTION];
    question = [question fetchIfNeeded];
    BOOL isCorrect = [log[PARSE_STUDY_IS_CORRECT] boolValue];
    NSInteger answerNum = [log[PARSE_STUDY_ANSWER] integerValue];
    NSMutableArray *answers = question[PARSE_QUESTION_ANSWER_LIST];
    NSString *title = [NSString stringWithFormat:@"%ld.) %@", indexPath.row+1, question[PARSE_QUESTION_QUESTION]];
    lblQuestion.text = title;
    if (isCorrect){
        NSString *answer = [NSString stringWithFormat:@"You Answer: %@. %@.(correct)", [ARRAY_ANSWER objectAtIndex:answerNum], [answers objectAtIndex:answerNum]];
        lblAnswer.text = answer;
        
        lblQuestion.textColor = [UIColor blackColor];
        lblAnswer.textColor = [UIColor blackColor];
        
    } else {
        NSString *answer;
        if (answerNum == 4){
            answer = [NSString stringWithFormat:@"You Answer: %@.(incorrect)", [ARRAY_ANSWER objectAtIndex:answerNum]];
                      } else {
                          answer = [NSString stringWithFormat:@"You Answer: %@. %@.(incorrect)", [ARRAY_ANSWER objectAtIndex:answerNum], [answers objectAtIndex:answerNum]];
                          
                      }
        lblAnswer.text = answer;
        
        lblQuestion.textColor = [UIColor redColor];
        lblAnswer.textColor = [UIColor redColor];
    }
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

@end
