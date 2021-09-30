//
//  TeachersViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "TeachersViewController.h"
#import "IQDropDownTextField.h"

@interface TeachersViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, IQDropDownTextFieldDelegate>
{
    IBOutlet UIView *contentView;
    IBOutlet UITableView *tableview;
    IBOutlet UIButton *btnTeachers;
    IBOutlet UIButton *btnJoin;
    IBOutlet UIView *viewJoin;
    IBOutlet UISearchBar *searchTeacher;
    IBOutlet UITableView *tableviewSearch;
    IBOutlet IQDropDownTextField *txtTeachers;
    
    PFUser *me;
    NSMutableArray *dataArray;
    IBOutlet UILabel *lblNoTeacher;
    
    NSMutableArray *myTeacherList;
}
@end

@implementation TeachersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:contentView];
    [Util setCornerView:viewJoin];
    [Util setCornerView:searchTeacher];
    [Util setCornerView:txtTeachers];
    [Util setCornerView:tableviewSearch];
    
    me = [PFUser currentUser];
    dataArray = [[NSMutableArray alloc] init];
    myTeacherList = [[NSMutableArray alloc] init];
    [self refreshItems];
    searchTeacher.delegate = self;
    txtTeachers.delegate = self;
    lblNoTeacher.hidden = YES;
}

- (void) refreshItems {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            me = (PFUser *) object;
            dataArray = (NSMutableArray *) me[PARSE_USER_TEACHER_LIST];
            [tableview reloadData];
            lblNoTeacher.hidden = !(dataArray.count == 0);
            myTeacherList = dataArray;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTeachers:(id)sender {
    [self.view endEditing:YES];
    
    [self refreshItems];
    [btnTeachers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnJoin setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    contentView.hidden = NO;
    viewJoin.hidden = YES;
}

- (IBAction)onJoinClass:(id)sender {
    [self.view endEditing:YES];
    
    [btnJoin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnTeachers setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    contentView.hidden = YES;
    viewJoin.hidden = NO;

    if (txtTeachers.hasText){
        return;
    }
    
    searchTeacher.text = @"";
    txtTeachers.text = @"";
    dataArray = [NSMutableArray new];
    [tableviewSearch reloadData];
    
    [self refreshSuggestions];
}

- (void) refreshSuggestions {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
//    if (txtTeachers.selectedItem.length == 0){
//        return;
//    }
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInteger:USER_TYPE_TEACHER]];
    [query setLimit:1000];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            NSMutableArray *itemList = [[NSMutableArray alloc] init];
            for (int i=0;i<array.count;i++){
                PFUser *user = [array objectAtIndex:i];
                if (![self isMyTeacher:user]){
                    user = [user fetchIfNeeded];
                    [itemList addObject:user[PARSE_USER_FULLNAME]];
                }
            }
            txtTeachers.itemList = itemList;
            txtTeachers.delegate = self;
            txtTeachers.selected = NO;
            txtTeachers.selectedRow = -1;
            txtTeachers.selectedItem = @"";
            txtTeachers.text = @"";
        }
    }];
}

- (BOOL) isMyTeacher:(PFUser *) user{
    if (myTeacherList.count == 0){
        return NO;
    }
    for (int i=0;i<myTeacherList.count;i++){
        PFUser *teacher = [myTeacherList objectAtIndex:i];
        if ([teacher.objectId isEqualToString:user.objectId]){
            return YES;
        }
    }
    return NO;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == tableview){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellTeacher"];
        PFUser *teacher = (PFUser *)[dataArray objectAtIndex:indexPath.row];
        teacher = [teacher fetchIfNeeded];
        UILabel *lblName = (UILabel *)[cell viewWithTag:1];
        UIButton *btnLeave = (UIButton *)[cell viewWithTag:2];
        [btnLeave addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        lblName.text = teacher[PARSE_USER_FULLNAME];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellSearch"]; // cellSearch
        PFUser *teacher = (PFUser *)[dataArray objectAtIndex:indexPath.row];
        teacher = [teacher fetchIfNeeded];
        UILabel *lblName = (UILabel *)[cell viewWithTag:3];
        UIButton *btnJoin = (UIButton *)[cell viewWithTag:4];
        [btnJoin addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        lblName.text = teacher[PARSE_USER_FULLNAME];
        return cell;
    }
}

- (void)checkButtonTapped:(id)sender
{
    NSInteger tag = [sender tag];
    NSDictionary *data = [NSDictionary new];
    if (tag == 2){ // Remove Class
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableview];
        NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:buttonPosition];
        if (indexPath != nil)
        {
            PFUser *teacher = [dataArray objectAtIndex:indexPath.row];
            data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  teacher.objectId, @"fromId",
                                  @"", @"parentId",
                                  @"", @"teacherId",
                                  me.objectId, @"studentId",
                                  @NO, @"isConnected",
                                  nil];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [PFCloud callFunctionInBackground:@"setConnection" withParameters:data block:^(id object, NSError *err) {
                [SVProgressHUD dismiss];
                if (err) {
                    [Util showAlertTitle:self title:@"Error" message:[err localizedDescription] finish:nil];
                } else {
                    [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                        if (tag == 2){
                            [self refreshItems];
                        }
                    }];
                }
            }];
        }
    } else { // Join Class
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableviewSearch];
        NSIndexPath *indexPath = [tableviewSearch indexPathForRowAtPoint:buttonPosition];
        if (indexPath != nil)
        {
            PFUser *teacher = [dataArray objectAtIndex:indexPath.row];
            teacher = [teacher fetchIfNeeded];
            data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  teacher.objectId, @"fromId",
                                  @"", @"parentId",
                                  @"", @"teacherId",
                                  me.objectId, @"studentId",
                                  @YES, @"isConnected",
                                  nil];
            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
            [query whereKey:PARSE_NOTIFICATION_FROM_USER equalTo:me];
            [query whereKey:PARSE_NOTIFICATION_TO_USER equalTo:teacher];
            [query whereKey:PARSE_NOTIFICATION_TYPE equalTo:[NSNumber numberWithInteger:NOTIFICATION_JOIN_CLASS]];
//            [query whereKey:PARSE_NOTIFICATION_STATE equalTo:[NSNumber numberWithInteger:NOTIFICATION_STATE_PENDING]];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                if (error){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                } else if (objects.count > 0){
                    [SVProgressHUD dismiss];
                    for (int i=0;i<objects.count;i++){
                        PFObject *obj = [objects objectAtIndex:i];
                        int type = [obj[PARSE_NOTIFICATION_STATE] intValue];
                        if (type == NOTIFICATION_STATE_PENDING){
                            [Util showAlertTitle:self title:@"Warning" message:@"You have already sent request to this teacher."];
                            return;
                        } else if (type == NOTIFICATION_STATE_ACCEPT){
                            [Util showAlertTitle:self title:@"Warning" message:@"You have already sent request to this teacher."];
                            return;
                        }
                    }
                    PFObject *notif = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
                    notif[PARSE_NOTIFICATION_FROM_USER] = me;
                    notif[PARSE_NOTIFICATION_TO_USER] = teacher;
                    notif[PARSE_NOTIFICATION_STATE] = [NSNumber numberWithInteger:NOTIFICATION_STATE_PENDING];
                    notif[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInteger:NOTIFICATION_JOIN_CLASS];
                    [notif saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                        [SVProgressHUD dismiss];
                        if (succeed && !error){
                            [Util sendPushNotification:teacher.username message:[NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FULLNAME], @"sent a join class request."] type:NOTIFICATION_JOIN_CLASS state:NOTIFICATION_STATE_PENDING fromUser:me toUser:teacher];
                            [Util showAlertTitle:self title:@"Success" message:@"Request Sent" finish:^(void){
                                [self onJoinClass:nil];
                            }];
                        }
                    }];
                } else {
                    PFObject *notif = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
                    notif[PARSE_NOTIFICATION_FROM_USER] = me;
                    notif[PARSE_NOTIFICATION_TO_USER] = teacher;
                    notif[PARSE_NOTIFICATION_STATE] = [NSNumber numberWithInteger:NOTIFICATION_STATE_PENDING];
                    notif[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInteger:NOTIFICATION_JOIN_CLASS];
                    [notif saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                        [SVProgressHUD dismiss];
                        if (succeed && !error){
                            [Util sendPushNotification:teacher.username message:[NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FULLNAME], @"sent a join class request."] type:NOTIFICATION_JOIN_CLASS state:NOTIFICATION_STATE_PENDING fromUser:me toUser:teacher];
                            [Util showAlertTitle:self title:@"Success" message:@"Request Sent" finish:^(void){
                                [self onJoinClass:nil];
                            }];
                        }
                    }];
                }
            }];
        }
    }
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchTeacher endEditing:YES];
    searchTeacher.text = [Util trim:searchTeacher.text];
    NSString *string = searchTeacher.text;
    if (string.length == 0){
        return;
    }
}

- (void) refreshSeachTeachersData {
    if (!txtTeachers.hasText){
        return;
    }
    NSString *string = txtTeachers.selectedItem;
    if (string.length == 0){
        return;
    }
    // should omit the requested teachers
    PFQuery *querys = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
    [querys whereKey:PARSE_NOTIFICATION_FROM_USER equalTo:me];
    [querys whereKey:PARSE_NOTIFICATION_TYPE equalTo:[NSNumber numberWithInteger:NOTIFICATION_JOIN_CLASS]];
    [querys whereKey:PARSE_NOTIFICATION_STATE equalTo:[NSNumber numberWithInteger:NOTIFICATION_STATE_PENDING]];
    [querys includeKey:PARSE_NOTIFICATION_TO_USER];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [querys findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            NSMutableArray *sentUsers = [[NSMutableArray alloc] init];
            for (PFObject *obj in objects){
                [sentUsers addObject:obj[PARSE_NOTIFICATION_TO_USER]];
            }
            PFQuery *query = [PFUser query];
            [query whereKey:PARSE_USER_FULLNAME matchesRegex:string modifiers:@"i"];
            [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:USER_TYPE_TEACHER]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                [SVProgressHUD dismiss];
                dataArray = [NSMutableArray new];
                for (PFUser *obj in objects){
                    if (![self isContains:obj :sentUsers]){
                        [dataArray addObject:obj];
                    }
                }
                [tableviewSearch reloadData];
                if (dataArray.count == 0){
                    [Util showAlertTitle:self title:@"Error" message:@"No teachers found"];
                }
            }];
        }
    }];
}

- (BOOL) isContains:(PFUser *) user :(NSMutableArray *) array {
    for (PFUser *item in array){
        if ([user.objectId isEqualToString:item.objectId]){
            return YES;
        }
    }
    return NO;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == txtTeachers){
        [self refreshSeachTeachersData];
    }
}

@end
