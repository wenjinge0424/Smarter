//
//  TeacherViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "TeacherViewController.h"
#import "OptionViewController.h"
#import "TeacherSettingsViewController.h"
#import "GuideDetailViewController.h"
#import "SearchGuideViewController.h"
#import "IQDropDownTextField.h"
#import "AssignmentsViewController.h"

@interface TeacherViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableview;
    IBOutlet UITableView *tableviewAssignments;
    
    NSMutableArray *dataArray;
    NSMutableArray *assignArray;
}
@end

@implementation TeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerView:tableview];
    [Util setCornerView:tableviewAssignments];
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
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_GUIDES];
    [query whereKey:PARSE_GUIDES_TEACHER_LIST containsAllObjectsInArray:[[NSArray alloc] initWithObjects:[PFUser currentUser], nil]];
    [query addDescendingOrder:PARSE_FIELD_CREATED_AT];
    [query setLimit:1000];
    [query includeKey:PARSE_GUIDES_TEACHER_LIST];
    [query includeKey:PARSE_GUIDES_OWNER];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [SVProgressHUD dismiss];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) array;
            [tableview reloadData];
            
            PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_ASSIGNMENT];
            [query1 whereKey:PARSE_ASSIGN_OWNER equalTo:[PFUser currentUser]];
            [query1 includeKey:PARSE_ASSIGN_OWNER];
            [query1 addDescendingOrder:PARSE_ASSIGN_NUMBER];
            [query1 findObjectsInBackgroundWithBlock:^(NSArray *array1, NSError *err){
                [SVProgressHUD dismiss];
                if (error){
                    [Util showAlertTitle:self title:@"Error" message:[err localizedDescription]];
                } else {
                    assignArray = [[NSMutableArray alloc] init];
                    PFObject *new = [PFObject objectWithClassName:PARSE_TABLE_ASSIGNMENT];
                    int counter = 1;
                    for (int i=0;i<array1.count;i++){
                        PFObject *assignment = [array1 objectAtIndex:i];
                        NSString *numberId = assignment[PARSE_ASSIGN_NUMBER];
                        
                        if (i == 0){
                            new[PARSE_ASSIGN_NUMBER] = assignment[PARSE_ASSIGN_NUMBER];
                            new[PARSE_ASSIGN_TITLE] = assignment[PARSE_ASSIGN_TITLE];
                            new[PARSE_ASSIGN_COUNT] = [NSNumber numberWithInt:counter];
                            if (![assignArray containsObject:new])
                                [assignArray addObject:new];
                        } else {
                            PFObject *assignmentPre = [array1 objectAtIndex:(i-1)];
                            NSString *numberId1 = assignmentPre[PARSE_ASSIGN_NUMBER];
                            if ([numberId1 isEqualToString:numberId]){
                                counter++;
                                if (i == array.count - 1){
                                    new[PARSE_ASSIGN_COUNT] = [NSNumber numberWithInt:counter];
                                    if (![assignArray containsObject:new])
                                        [assignArray addObject:new];
                                }
                            } else {
                                new[PARSE_GUIDES_COUNT] = [NSNumber numberWithInt:counter];
                                if (![assignArray containsObject:new])
                                    [assignArray addObject:new];
                                new = [PFObject objectWithClassName:PARSE_TABLE_ASSIGNMENT];
                                new[PARSE_ASSIGN_NUMBER] = numberId;
                                counter = 1;
                                new[PARSE_ASSIGN_TITLE] = assignment[PARSE_ASSIGN_TITLE];
                                new[PARSE_ASSIGN_COUNT] = [NSNumber numberWithInt:counter];
                            }
                        }
                    }
                    [tableviewAssignments reloadData];
                }
            }];
        }
    }];
}

- (IBAction)onAdd:(id)sender {
    OptionViewController *vc = (OptionViewController *)[Util getUIViewControllerFromStoryBoard:@"OptionViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSettings:(id)sender {
    TeacherSettingsViewController *vc = (TeacherSettingsViewController *)[Util getUIViewControllerFromStoryBoard:@"TeacherSettingsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onShop:(id)sender {
    SearchGuideViewController *vc = (SearchGuideViewController *)[Util getUIViewControllerFromStoryBoard:@"SearchGuideViewController"];
    [self.navigationController pushViewController:vc animated:YES];
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
    if (tableView == tableview)
        return dataArray.count;
    else
        return assignArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (tableView == tableview){
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellGuide"];
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        PFObject *obj = [dataArray objectAtIndex:indexPath.row];
        label.text = [NSString stringWithFormat:@"%@", obj[PARSE_GUIDES_TITLE]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellAssign"];
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        PFObject *obj = [assignArray objectAtIndex:indexPath.row];
        label.text = [NSString stringWithFormat:@"%@(%ld)", obj[PARSE_ASSIGN_TITLE], [obj[PARSE_ASSIGN_COUNT] integerValue]];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == tableview){
        GuideDetailViewController *vc = (GuideDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"GuideDetailViewController"];
        vc.guide = [dataArray objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        AssignmentsViewController *vc = (AssignmentsViewController *)[Util getUIViewControllerFromStoryBoard:@"AssignmentsViewController"];
        PFObject *obj = [assignArray objectAtIndex:indexPath.row];
        vc.assignment = obj;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
