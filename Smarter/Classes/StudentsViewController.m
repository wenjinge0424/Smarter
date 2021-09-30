//
//  StudentsViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "StudentsViewController.h"
#import "HistoryViewController.h"

@interface StudentsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIButton *btnStudents;
    IBOutlet UIButton *btnRequests;
    IBOutlet UIView *viewStudents;
    IBOutlet UIView *viewRequests;
    
    IBOutlet UITableView *tableStudents;
    IBOutlet UITableView *tableRequests;
    
    NSMutableArray *dataArray;
    PFUser *me;
}
@end

@implementation StudentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [Util setCornerView:viewStudents];
    [Util setCornerView:viewRequests];
    
    me = [PFUser currentUser];
    [self refreshItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshItems { // My Students
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [SVProgressHUD dismiss];
        dataArray = (NSMutableArray *) me[PARSE_USER_STUDENT_LIST];
        [tableStudents reloadData];
        if (dataArray.count == 0){
            [Util showAlertTitle:self title:@"" message:@"No student found."];
        }
    }];
}

- (void) refreshRequestItems {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
    [query whereKey:PARSE_NOTIFICATION_TYPE equalTo:[NSNumber numberWithInt:NOTIFICATION_JOIN_CLASS]];
    [query whereKey:PARSE_NOTIFICATION_STATE equalTo:[NSNumber numberWithInt:NOTIFICATION_STATE_PENDING]];
    [query whereKey:PARSE_NOTIFICATION_TO_USER equalTo:me];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) objects;
            [tableRequests reloadData];
            if (dataArray.count == 0){
                [Util showAlertTitle:self title:@"" message:@"No student request found."];
            }
        }
    }];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onStudents:(id)sender {
    [btnStudents setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnRequests setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    viewStudents.hidden = NO;
    viewRequests.hidden = YES;
    
    [self refreshItems];
}

- (IBAction)onRequests:(id)sender {
    [btnRequests setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnStudents setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    viewRequests.hidden = NO;
    viewStudents.hidden = YES;
    
    [self refreshRequestItems];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (tableView == tableStudents){
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellStudent"];
        UIButton *btnRemove = (UIButton *)[cell viewWithTag:4];
        UILabel *lblName = (UILabel *)[cell viewWithTag:5];
        
        PFUser *student = [dataArray objectAtIndex:indexPath.row];
        student = [student fetchIfNeeded];
        lblName.text = student[PARSE_USER_FULLNAME];
        
        [btnRemove addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    } else if (tableView == tableRequests){
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellRequest"];
        UILabel *lblName = (UILabel *)[cell viewWithTag:1];
        UIButton *btnAccept = (UIButton *)[cell viewWithTag:2];
        UIButton *btnRemove = (UIButton *)[cell viewWithTag:3];
        
        PFObject *notif = [dataArray objectAtIndex:indexPath.row];
        PFUser *student = notif[PARSE_NOTIFICATION_FROM_USER];
        student = [student fetchIfNeeded];
        lblName.text = student[PARSE_USER_FULLNAME];
        
        [btnAccept addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [btnRemove addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryViewController *vc = (HistoryViewController *)[Util getUIViewControllerFromStoryBoard:@"HistoryViewController"];
    PFUser *student = [dataArray objectAtIndex:indexPath.row];
    vc.user = student;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)checkButtonTapped:(id)sender
{
    NSInteger tag = [sender tag];
    if (tag == 4){ // remove in Student
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableStudents];
        NSIndexPath *indexPath = [tableStudents indexPathForRowAtPoint:buttonPosition];
        PFUser *student = [dataArray objectAtIndex:indexPath.row];
        student = [student fetchIfNeeded];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                student.objectId, @"fromId",
                @"", @"parentId",
                me.objectId, @"teacherId",
                @"", @"studentId",
                @NO, @"isConnected",
                nil];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [PFCloud callFunctionInBackground:@"setConnection" withParameters:data block:^(id object, NSError *err) {
            [SVProgressHUD dismiss];
            if (err) {
                [Util showAlertTitle:self title:@"Error" message:[err localizedDescription] finish:nil];
            } else {
                [Util sendPushNotification:student.username message:[NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FULLNAME], @"removed you."] type:NOTIFICATION_DECLINED state:NOTIFICATION_STATE_REJECT fromUser:me toUser:student];
                
                PFQuery *querys = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
                [querys whereKey:PARSE_NOTIFICATION_TO_USER equalTo:me];
                [querys whereKey:PARSE_NOTIFICATION_TYPE equalTo:[NSNumber numberWithInteger:NOTIFICATION_JOIN_CLASS]];
                [querys whereKey:PARSE_NOTIFICATION_FROM_USER equalTo:student];
                [querys findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                    if (objects.count > 0){
                        for (int i=0;i<objects.count;i++){
                            PFObject *objItem = [objects objectAtIndex:i];
                            [objItem deleteInBackground];
                        }
                    }
                    [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                        [self refreshItems];
                    }];
                }];
            }
        }];
    } else if (tag == 2) { // accept in Request
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableRequests];
        NSIndexPath *indexPath = [tableRequests indexPathForRowAtPoint:buttonPosition];
        PFObject *notif = [dataArray objectAtIndex:indexPath.row];
        PFUser *student = notif[PARSE_NOTIFICATION_FROM_USER];
        student = [student fetchIfNeeded];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              student.objectId, @"fromId",
                              @"", @"parentId",
                              me.objectId, @"teacherId",
                              @"", @"studentId",
                              @YES, @"isConnected",
                              nil];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [PFCloud callFunctionInBackground:@"setConnection" withParameters:data block:^(id object, NSError *err) {
            [SVProgressHUD dismiss];
            if (err) {
                [Util showAlertTitle:self title:@"Error" message:[err localizedDescription] finish:nil];
            } else {
                notif[PARSE_NOTIFICATION_STATE] = [NSNumber numberWithInt:NOTIFICATION_STATE_ACCEPT];
                [notif saveInBackground];
                
                [Util sendPushNotification:student.username message:[NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FULLNAME], @"accepted your request."] type:NOTIFICATION_ACCEPTED state:NOTIFICATION_STATE_ACCEPT fromUser:me toUser:student];
                
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                    [self refreshRequestItems];
                }];
            }
        }];
    } else if (tag == 3) { // remove in Request
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableRequests];
        NSIndexPath *indexPath = [tableRequests indexPathForRowAtPoint:buttonPosition];
        PFObject *notif = [dataArray objectAtIndex:indexPath.row];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [notif deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            if (succeed && !error){
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                    [self refreshRequestItems];
                }];
            }
        }];
    }
}

@end
