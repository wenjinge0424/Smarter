//
//  AcceptParentViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//
#import "CircleImageView.h"
#import "AcceptParentViewController.h"

@interface AcceptParentViewController ()
{
    IBOutlet CircleImageView *imgAvatar;
    IBOutlet UILabel *lblQuestion;
    
    PFUser *me;
    PFUser *parent;
    PFObject *notification;
}
@end

@implementation AcceptParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setBorderView:imgAvatar color:[UIColor whiteColor] width:1.0];
    
    me = [PFUser currentUser];
    [self refreshItem];
}

- (void) refreshItem {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_NOTIFICATION];
    [query whereKey:PARSE_NOTIFICATION_TO_USER equalTo:me];
    [query whereKey:PARSE_NOTIFICATION_TYPE equalTo:[NSNumber numberWithInt:NOTIFICATION_PARENT_SYNC]];
    [query whereKey:PARSE_NOTIFICATION_STATE equalTo:[NSNumber numberWithInt:NOTIFICATION_STATE_PENDING]];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *obj, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^(void){
                [self onback:nil];
            }];
        } else {
            notification = obj;
            PFUser *user = (PFUser *)obj[PARSE_NOTIFICATION_FROM_USER];
            user = [user fetchIfNeeded];
            parent = user;
            if (user[PARSE_USER_AVATAR]){
                [Util setImage:imgAvatar imgFile:(PFFile *)user[PARSE_USER_AVATAR]];
            }
            NSString *message = [NSString stringWithFormat:@"Is %@(%@) your parent/guardian?", user[PARSE_USER_FULLNAME], user.username];
            lblQuestion.text = message;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAccept:(id)sender {
    if (!notification){
        return;
    }
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          me.objectId, @"fromId",
                          parent.objectId, @"parentId",
                          @"", @"teacherId",
                          @"", @"studentId",
                          @YES, @"isConnected",
                          nil];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [PFCloud callFunctionInBackground:@"setConnection" withParameters:data block:^(id object, NSError *err) {
        [SVProgressHUD dismiss];
        if (err) {
            [Util showAlertTitle:self title:@"Error" message:[err localizedDescription] finish:nil];
        } else {
            [Util sendPushNotification:parent.username message:[NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FULLNAME], @"accepted your sync request"] type:NOTIFICATION_ACCEPTED state:NOTIFICATION_STATE_PENDING fromUser:me toUser:parent];
            
            notification[PARSE_NOTIFICATION_STATE] = [NSNumber numberWithInt:NOTIFICATION_STATE_ACCEPT];
            [notification saveInBackground];
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                [self onback:nil];
            }];
        }
    }];
}

- (IBAction)onDecline:(id)sender {
    if (notification){
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
            return;
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [notification deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (error){
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^(void){
                    [self onback:nil];
                }];
            } else {
                [Util sendPushNotification:parent.username message:[NSString stringWithFormat:@"%@ %@", me[PARSE_USER_FULLNAME], @"declined your sync request."] type:NOTIFICATION_DECLINED state:NOTIFICATION_STATE_REJECT fromUser:me toUser:parent];
                
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                    [self onback:nil];
                }];
            }
        }];
    }
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

@end
