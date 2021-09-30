//
//  AssignmentsViewController.m
//  Smarter
//
//  Created by gao on 10/23/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "AssignmentsViewController.h"

@interface AssignmentsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    IBOutlet UILabel *lbltitle;
    
    PFUser *me;
    NSMutableArray *studentList;
    IBOutlet UIView *contentView;
}
@end

@implementation AssignmentsViewController
@synthesize assignment;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:contentView];
    me = [PFUser currentUser];
    [self refreshItems];
}

- (void) refreshItems {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me fetchInBackgroundWithBlock:^(PFObject *user, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            me = (PFUser *)user;
            studentList = me[PARSE_USER_STUDENT_LIST];
            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_ANSWER_LOGS];
            [query whereKey:PARSE_ANSWER_OWNER containedIn:studentList];
            [query whereKey:PARSE_ANSWER_ASSIGNMENT_NUMBER equalTo:assignment[PARSE_ASSIGN_NUMBER]];
            [query addDescendingOrder:PARSE_ANSWER_OWNER];
            [query includeKey:PARSE_ANSWER_OWNER];
            [query includeKey:PARSE_ANSWER_ASSIGNMENT];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *err){
                dataArray = [[NSMutableArray alloc] init];
                if (err){
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                } else {
                    for (int i=0;i<studentList.count;i++){
                        PFUser *student = [studentList objectAtIndex:i];
                        student = [student fetchIfNeeded];
                        PFObject *object = [PFObject objectWithClassName:PARSE_TABLE_TEMP];
                        object[PARSE_TEMP_USER] = student;
                        object[PARSE_TEMP_TOTAL] = assignment[PARSE_ASSIGN_COUNT];
                        object[PARSE_TEMP_CORRECT] = [NSNumber numberWithInteger:[self getCorrectCount:[studentList objectAtIndex:i] data:(NSMutableArray *)objects]];
                        [dataArray addObject:object];
                    }
                }
                [tableview reloadData];
                [SVProgressHUD dismiss];
            }];
        }
    }];
}

- (NSInteger) getCorrectCount:(PFUser *)user data:(NSMutableArray *)array{
    int count = 0;
    for (PFObject *obj in array){
        PFUser *user = obj[PARSE_ANSWER_OWNER];
        if ([user.objectId isEqualToString:user.objectId] && [obj[PARSE_ANSWER_CORRECT] boolValue]){
            count++;
        }
    }
    return count;
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
- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellAssign"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UILabel *lblScore = (UILabel *)[cell viewWithTag:2];
    PFObject *obj = [dataArray objectAtIndex:indexPath.row];
    PFUser *owner = obj[PARSE_TEMP_USER];
    lblName.text = owner[PARSE_USER_FULLNAME];
    lblScore.text = [NSString stringWithFormat:@"%ld/%ld", [obj[PARSE_TEMP_CORRECT] integerValue], [obj[PARSE_TEMP_TOTAL] integerValue]];
    return cell;
}

@end
