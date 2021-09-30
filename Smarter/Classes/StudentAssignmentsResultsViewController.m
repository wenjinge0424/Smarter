//
//  StudentAssignmentsResultsViewController.m
//  Smarter
//
//  Created by gao on 11/28/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "StudentAssignmentsResultsViewController.h"
#import "AssignShowModel.h"

@interface StudentAssignmentsResultsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    NSMutableArray *assignArray;
}
@end

@implementation StudentAssignmentsResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = [[NSMutableArray alloc] init];
    [Util setCornerView:tableview];
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
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:PARSE_USER_FULLNAME matchesRegex:self.teacherName modifiers:@"i"];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_ASSIGNMENT];
    [query includeKey:PARSE_ASSIGN_OWNER];
    [query whereKey:PARSE_ASSIGN_OWNER matchesQuery:userQuery];
    if (self.assignName.length > 0){
        [query whereKey:PARSE_ASSIGN_TITLE matchesRegex:self.assignName modifiers:@"i"];
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = [[NSMutableArray alloc] init];
            assignArray = [[NSMutableArray alloc] init];
            if (array.count > 0){
                PFObject *object = [array objectAtIndex:0];
                NSString *idNumber = object[PARSE_ASSIGN_NUMBER];
                NSString *title = object[PARSE_ASSIGN_TITLE];
                PFUser *teacher = object[PARSE_ASSIGN_OWNER];
                for (int i=0;i<array.count;i++){
                    PFObject *object = [array objectAtIndex:i];
                    NSString *idNum = object[PARSE_ASSIGN_NUMBER];
                    if ([idNum isEqualToString:idNumber]){
                        [assignArray addObject:object];
                    } else {
                        AssignShowModel *model = [[AssignShowModel alloc] init];
                        model.assignment_number = idNumber;
                        model.assignmentList = [[NSMutableArray alloc] init];
                        [model.assignmentList addObjectsFromArray:assignArray];
                        model.title = title;
                        model.owner = teacher;
                        [dataArray addObject:model];
                        idNumber = object[PARSE_ASSIGN_NUMBER];
                        title = object[PARSE_ASSIGN_TITLE];
                        teacher = object[PARSE_ASSIGN_OWNER];
                        assignArray = [[NSMutableArray alloc] init];
                        [assignArray addObject:object];
                    }
                }
                AssignShowModel *model = [[AssignShowModel alloc] init];
                model.assignment_number = idNumber;
                [model.assignmentList addObjectsFromArray:assignArray];
                model.title = title;
                model.owner = teacher;
                [dataArray addObject:model];
            }
            [tableview reloadData];
        }
    }];
    
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAssignment"];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    AssignShowModel *model = [dataArray objectAtIndex:indexPath.row];
    PFUser *teacher = model.owner;
    NSString *message = [NSString stringWithFormat:@"%@ - %@ (%ld)", teacher[PARSE_USER_FULLNAME], model.title, model.assignmentList.count];
    label.text = message;
    
    return cell;
}
@end
