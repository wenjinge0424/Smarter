//
//  ParentReportViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ParentReportViewController.h"
#import "ParentHistoryViewController.h"
#import "AddQuestionViewController.h"
#import "ParentSyncChildViewController.h"
#import "StudentHistoryViewController.h"
#import "ParentViewController.h"
#import "IQDropDownTextField.h"
#import "GuideViewController.h"
#import "ParentSearchGuidesViewController.h"

@interface ParentReportViewController ()<UITableViewDelegate, UITableViewDataSource, IQDropDownTextFieldDelegate>
{
    IBOutlet UITableView *tableview;
    
    PFUser *me;
    NSMutableArray *userList;
    NSMutableArray *nameList;
    IBOutlet UILabel *lblReports;
    IBOutlet IQDropDownTextField *txtStudent;
}
@end

@implementation ParentReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:tableview];
    me = [PFUser currentUser];
    userList = [[NSMutableArray alloc] init];
    nameList = [[NSMutableArray alloc] init];
    txtStudent.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshItems];
}

- (void) refreshItems {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [me fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        userList = (NSMutableArray *) me[PARSE_USER_STUDENT_LIST];
        nameList = [[NSMutableArray alloc] init];
        [tableview reloadData];
        
        for (int i=0;i<userList.count;i++){
            PFUser *user = [userList objectAtIndex:i];
            user = [user fetchIfNeeded];
            [nameList addObject:user[PARSE_USER_FULLNAME]];
        }
        txtStudent.itemList = nameList;
        
        if (userList.count>0){
            lblReports.text = @"Reports";
            tableview.hidden = NO;
        } else {
            lblReports.text = @"No child connected yet";
            tableview.hidden = YES;
        }
        [SVProgressHUD dismiss];
    }];
}


- (IBAction)onAdd:(id)sender {
    AddQuestionViewController *vc = (AddQuestionViewController *)[Util getUIViewControllerFromStoryBoard:@"AddQuestionViewController"];
    [[ParentViewController getInstance] pushViewController:vc];
}

- (IBAction)onAddChild:(id)sender {
    ParentSyncChildViewController *vc = (ParentSyncChildViewController *)[Util getUIViewControllerFromStoryBoard:@"ParentSyncChildViewController"];
    [[ParentViewController getInstance] pushViewController:vc];
}

- (IBAction)onGuide:(id)sender {
    if (userList.count == 0){
        [Util showAlertTitle:self title:@"Sorry" message:@"No student connected."];
        return;
    }
    [Util showAlertTitle:self title:@"Warning" message:@"You need to choose your student." finish:^{
        [txtStudent becomeFirstResponder];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellReport"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    PFUser *user = [userList objectAtIndex:indexPath.row];
    user = [user fetchIfNeeded];
    lblName.text = user[PARSE_USER_FULLNAME];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StudentHistoryViewController *vc = (StudentHistoryViewController *)[Util getUIViewControllerFromStoryBoard:@"StudentHistoryViewController"];
    vc.student = [userList objectAtIndex:indexPath.row];
    [[ParentViewController getInstance] pushViewController:vc];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField == txtStudent && txtStudent.selectedRow != -1){
        ParentSearchGuidesViewController *vc = (ParentSearchGuidesViewController *)[Util getUIViewControllerFromStoryBoard:@"ParentSearchGuidesViewController"];
        vc.student = [userList objectAtIndex:txtStudent.selectedRow];
        [[ParentViewController getInstance] pushViewController:vc];
    }
}

@end
