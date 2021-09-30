//
//  MyAssignmentsViewController.m
//  Smarter
//
//  Created by gao on 10/23/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "MyAssignmentsViewController.h"
#import "AnswerAssignmentViewController.h"

@interface MyAssignmentsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIView *viewContent;
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
}
@end

@implementation MyAssignmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:viewContent];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_ASSIGNMENT];
    PFUser *me = [PFUser currentUser];
    NSMutableArray *teachers = me[PARSE_USER_TEACHER_LIST];
    [query whereKey:PARSE_ASSIGN_OWNER containedIn:teachers];
    [query addDescendingOrder:PARSE_ASSIGN_NUMBER];
    [query includeKey:PARSE_ASSIGN_OWNER];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = [[NSMutableArray alloc] init];
            PFObject *new = [PFObject objectWithClassName:PARSE_TABLE_ASSIGNMENT];
            int counter = 1;
            for (int i=0;i<array.count;i++){
                PFObject *assignment = [array objectAtIndex:i];
                NSString *numberId = assignment[PARSE_ASSIGN_NUMBER];
                
                if (i == 0){
                    new[PARSE_ASSIGN_NUMBER] = assignment[PARSE_ASSIGN_NUMBER];
                    new[PARSE_ASSIGN_TITLE] = assignment[PARSE_ASSIGN_TITLE];
                    new[PARSE_ASSIGN_COUNT] = [NSNumber numberWithInt:counter];
                    new[PARSE_ASSIGN_CORRECT_ANSWER] = assignment[PARSE_ASSIGN_CORRECT_ANSWER];
                    new[PARSE_ASSIGN_SUBNUMBER] = assignment[PARSE_ASSIGN_SUBNUMBER];
                    new[PARSE_ASSIGN_OWNER] = assignment[PARSE_ASSIGN_OWNER];
                    new[PARSE_ASSIGN_ANSWER_LIST] = assignment[PARSE_ASSIGN_ANSWER_LIST];
                    new[PARSE_ASSIGN_QUESTION] = assignment[PARSE_ASSIGN_QUESTION];
                    if (![dataArray containsObject:new])
                        [dataArray addObject:new];
                } else {
                    PFObject *assignmentPre = [array objectAtIndex:(i-1)];
                    NSString *numberId1 = assignmentPre[PARSE_ASSIGN_NUMBER];
                    if ([numberId1 isEqualToString:numberId]){
                        counter++;
                        if (i == array.count - 1){
                            new[PARSE_ASSIGN_COUNT] = [NSNumber numberWithInt:counter];
                            new[PARSE_ASSIGN_TITLE] = assignment[PARSE_ASSIGN_TITLE];
                            new[PARSE_ASSIGN_CORRECT_ANSWER] = assignment[PARSE_ASSIGN_CORRECT_ANSWER];
                            new[PARSE_ASSIGN_SUBNUMBER] = assignment[PARSE_ASSIGN_SUBNUMBER];
                            new[PARSE_ASSIGN_OWNER] = assignment[PARSE_ASSIGN_OWNER];
                            new[PARSE_ASSIGN_ANSWER_LIST] = assignment[PARSE_ASSIGN_ANSWER_LIST];
                            new[PARSE_ASSIGN_QUESTION] = assignment[PARSE_ASSIGN_QUESTION];
                            if (![dataArray containsObject:new])
                                [dataArray addObject:new];
                        }
                    } else {
                        new[PARSE_GUIDES_COUNT] = [NSNumber numberWithInt:counter];
                        if (![dataArray containsObject:new])
                            [dataArray addObject:new];
                        new = [PFObject objectWithClassName:PARSE_TABLE_ASSIGNMENT];
                        new[PARSE_ASSIGN_NUMBER] = numberId;
                        counter = 1;
                        new[PARSE_ASSIGN_TITLE] = assignment[PARSE_ASSIGN_TITLE];
                        new[PARSE_ASSIGN_COUNT] = [NSNumber numberWithInt:counter];
                        new[PARSE_ASSIGN_CORRECT_ANSWER] = assignment[PARSE_ASSIGN_CORRECT_ANSWER];
                        new[PARSE_ASSIGN_SUBNUMBER] = assignment[PARSE_ASSIGN_SUBNUMBER];
                        new[PARSE_ASSIGN_OWNER] = assignment[PARSE_ASSIGN_OWNER];
                        new[PARSE_ASSIGN_ANSWER_LIST] = assignment[PARSE_ASSIGN_ANSWER_LIST];
                        new[PARSE_ASSIGN_QUESTION] = assignment[PARSE_ASSIGN_QUESTION];
                    }
                }
            }
            if (dataArray.count == 0){
                [Util showAlertTitle:self title:@"" message:@"No Assignments for you."];
            }
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
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAssign"];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    PFObject *obj = [dataArray objectAtIndex:indexPath.row];
    label.text = [NSString stringWithFormat:@"%@(%d)", obj[PARSE_ASSIGN_TITLE], (int)[obj[PARSE_ASSIGN_COUNT] integerValue]];
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // check history if he had test for this assignment before
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    PFObject *obj = [dataArray objectAtIndex:indexPath.row];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_ANSWER_LOGS];
    [query whereKey:PARSE_ANSWER_OWNER equalTo:[PFUser currentUser]];
    [query whereKey:PARSE_ANSWER_ASSIGNMENT_NUMBER equalTo:obj[PARSE_ASSIGN_NUMBER]];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            if (objects.count > 0){
                [Util showAlertTitle:self title:@"Error" message:@"You cannot change your answer. You first result has been scored and recorded."];
            } else {
                AnswerAssignmentViewController *vc = (AnswerAssignmentViewController *)[Util getUIViewControllerFromStoryBoard:@"AnswerAssignmentViewController"];
                vc.assignment = obj;
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
    }];
}
@end
