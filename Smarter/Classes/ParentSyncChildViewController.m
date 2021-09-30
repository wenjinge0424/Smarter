//
//  ParentSyncChildViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ParentSyncChildViewController.h"
#import "IQDropDownTextField.h"

@interface ParentSyncChildViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableview;
    IBOutlet IQDropDownTextField *txtEmail;
 
    NSMutableArray *dataArray;
    PFUser *me;
    
    IBOutlet UILabel *lblResult;
    NSMutableArray *itemList;
}
@end

@implementation ParentSyncChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(syncAccepted:) name:NOTIFICATION_SYNC_ACCEPTED object:nil];
    [Util setCornerView:tableview];
    me = [PFUser currentUser];
    
    if (![Util isConnectableInternet]){
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInteger:USER_TYPE_STUDENT]];
    itemList = [[NSMutableArray alloc] init];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSObject *object){
        [SVProgressHUD dismiss];
        if (array.count > 0){
            for (int i=0;i<array.count;i++){
                PFUser *user = [array objectAtIndex:i];
                [itemList addObject:user.username];
            }
            txtEmail.itemList = itemList;
        }
    }];
}

- (void) syncAccepted:(NSNotification *) notif {
    [self.view endEditing:YES];
    [self refreshItems];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshItems];
}

- (void) refreshItems {
    txtEmail.text = @"";
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [SVProgressHUD dismiss];
        dataArray = (NSMutableArray *) me[PARSE_USER_STUDENT_LIST];
        [tableview reloadData];
        
        if (dataArray.count == 0){
            lblResult.text = @"No Child Synced";
            tableview.hidden = YES;
        } else {
            lblResult.text = @"Synced Children";
            tableview.hidden = NO;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAdd:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    if (![self isValid]){
        return;
    }
    
    NSString *email = txtEmail.selectedItem;
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:PARSE_USER_NAME equalTo:email];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        txtEmail.text = @"";
        txtEmail.selectedItem = @"";
        txtEmail.selectedRow = -1;
        [txtEmail setSelectedRow:-1];
        [txtEmail setSelectedItem:@""];
        [txtEmail setSelected:NO];
        txtEmail.itemList = [NSMutableArray new];
        txtEmail.itemList = itemList;
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            if (array.count == 0){
                [SVProgressHUD dismiss];
                [Util showAlertTitle:self title:@"Warning" message:@"No user found"];
            } else {
                PFUser *toUser = [array objectAtIndex:0];
                PFUser * listParent = toUser[PARSE_USER_PARENT];
                if(listParent){
                    [SVProgressHUD dismiss];
                    [Util showAlertTitle:self title:@"Error" message:@"This child is already connected with other parent."];
                    return;
                }
                PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
                [query whereKey:PARSE_NOTIFICATION_TO_USER equalTo:toUser];
                [query whereKey:PARSE_NOTIFICATION_TYPE equalTo:[NSNumber numberWithInteger:NOTIFICATION_PARENT_SYNC]];
                [query whereKey:PARSE_NOTIFICATION_STATE equalTo:[NSNumber numberWithInteger:NOTIFICATION_STATE_PENDING]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *arrays, NSError *errs){
                    if (errs){
                        [SVProgressHUD dismiss];
                        [Util showAlertTitle:self title:@"Error" message:[errs localizedDescription]];
                    } else if (arrays.count > 0){
                         [SVProgressHUD dismiss];
                        [Util showAlertTitle:self title:@"Error" message:@"This child is already connected with other parent."];
                        return;
                    }else{
                        // send request
                        PFObject *notif = [PFObject objectWithClassName:PARSE_TABLE_NOTIFICATION];
                        notif[PARSE_NOTIFICATION_FROM_USER] = [PFUser currentUser];
                        notif[PARSE_NOTIFICATION_TO_USER] = toUser;
                        notif[PARSE_NOTIFICATION_STATE] = [NSNumber numberWithInteger:NOTIFICATION_STATE_PENDING];
                        notif[PARSE_NOTIFICATION_TYPE] = [NSNumber numberWithInteger:NOTIFICATION_PARENT_SYNC];
                        [notif saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
                            [SVProgressHUD dismiss];
                            if (succeed && !error){
                                [Util sendPushNotification:email message:[NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FULLNAME], @"sent you sync request"] type:NOTIFICATION_PARENT_SYNC state:NOTIFICATION_STATE_PENDING fromUser:me toUser:toUser];
                                [Util showAlertTitle:self title:@"Success" message:@"Request Sent" finish:^(void){
                                    [self refreshItems];
                                }];
                            }
                        }];
                    }
                }];
            }
        }
    }];
}

- (BOOL) isValid {
    NSString *email = txtEmail.selectedItem;
    if (email.length == 0 || !txtEmail.hasText){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter email address." finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return NO;
    }
    if (![email isEmail]){
        [Util showAlertTitle:self title:@"Error" message:@"Please check your email and try again." finish:^(void){
            [txtEmail becomeFirstResponder];
        }];
        return NO;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellChildren"];
    PFObject *data = [dataArray objectAtIndex:indexPath.row];
    PFUser *user = [dataArray objectAtIndex:indexPath.row];
    user = [user fetchIfNeeded];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UIButton *btnRemove = (UIButton *)[cell viewWithTag:2];
    [btnRemove addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    lblName.text = user[PARSE_USER_FULLNAME];
    return cell;
}

- (void)checkButtonTapped:(id)sender
{
    NSDictionary *data = [NSDictionary new];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:tableview];
    NSIndexPath *indexPath = [tableview indexPathForRowAtPoint:buttonPosition];
    PFUser *child = [dataArray objectAtIndex:indexPath.row];
    data = [NSDictionary dictionaryWithObjectsAndKeys:
            me.objectId, @"fromId",
            @"", @"parentId",
            @"", @"teacherId",
            child.objectId, @"studentId",
            @NO, @"isConnected",
            nil];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [PFCloud callFunctionInBackground:@"setConnection" withParameters:data block:^(id object, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            [Util showAlertTitle:self title:@"Error" message:[err localizedDescription] finish:nil];
        } else {
            [Util sendPushNotification:child.username message:[NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FULLNAME], @"removed you"] type:NOTIFICATION_REMOVE state:NOTIFICATION_STATE_PENDING fromUser:me toUser:child];
            
            PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
            [query whereKey:PARSE_NOTIFICATION_FROM_USER equalTo:[PFUser currentUser]];
            [query whereKey:PARSE_NOTIFICATION_TO_USER equalTo:child];
            [query whereKey:PARSE_NOTIFICATION_STATE equalTo:[NSNumber numberWithInteger:NOTIFICATION_STATE_ACCEPT]];
            [query whereKey:PARSE_NOTIFICATION_TYPE equalTo:[NSNumber numberWithInteger:NOTIFICATION_PARENT_SYNC]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                if (!error){
                    for (int i=0;i<array.count;i++){
                        PFObject *obj = [array objectAtIndex:i];
                        [obj deleteInBackground];
                    }
                }
            }];
            
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                [self refreshItems];
            }];
        }
    }];
}

@end
