//
//  GuideViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "GuideViewController.h"
#import "IQDropDownTextField.h"
#import "StudentAssignmentsResultsViewController.h"
#import "GuideDetailViewController.h"
#import "GuidePayViewController.h"
#import "SearchResultsViewController.h"

@interface GuideViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIButton *btnSearch;
    
    IBOutlet UIButton *btnGuides;
    IBOutlet UIView *viewGuides;
    IBOutlet UITableView *tableviewGuids;
    IBOutlet UIView *viewSearch;
    IBOutlet UITextField *txtName;
    IBOutlet IQDropDownTextField *txtSubject;
    IBOutlet UITextField *txtGradeLevel;
    IBOutlet UITextField *txtAssign;
    IBOutlet UITextField *txtNameAssign;
    
    NSMutableArray *dataArray;
    
    // search params
    NSString *strName;
    NSInteger valSubj;
    NSInteger valGrade;
    IBOutlet UILabel *lblNoResult;
    IBOutlet UIView *viewSearchGuides;
    IBOutlet UIView *viewButtons;
    IBOutlet UIView *viewSearchAssignments;
}
@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:viewGuides];
    txtSubject.itemList = ARRAY_SUBJECT;
    
    if (!self.teacher){
        self.teacher = [PFUser currentUser];
    }
    [self onSearch:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    txtNameAssign.text = @"";
    txtAssign.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshItems {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    txtName.text = [Util trim:txtName.text];
    valSubj = txtSubject.selectedRow;
    valGrade = [txtGradeLevel.text integerValue];
    strName = txtName.text;
    
    PFQuery *ownerQuery = [PFUser query];
    [ownerQuery whereKey:PARSE_USER_FULLNAME matchesRegex:strName modifiers:@"i"];
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_GUIDES];
    [query whereKey:PARSE_GUIDES_TEACHER_LIST containsAllObjectsInArray:[[NSArray alloc] initWithObjects:self.teacher, nil]];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [query includeKey:PARSE_GUIDES_OWNER];
    [query includeKey:PARSE_GUIDES_TEACHER_LIST];
    if (strName.length != 0){
        [query whereKey:PARSE_GUIDES_OWNER matchesQuery:ownerQuery];
    }
    if (valSubj != -1){
        [query whereKey:PARSE_GUIDES_SUBJECT equalTo:[NSNumber numberWithInteger:valSubj]];
    }
    if (valGrade != 0){
        [query whereKey:PARSE_GUIDES_GRADE_LEVEL equalTo:[NSNumber numberWithInteger:valGrade]];
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error) {
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *)array;
            [tableviewGuids reloadData];
            if (dataArray.count == 0){
                lblNoResult.hidden = NO;
            } else {
                lblNoResult.hidden = YES;
            }
        }
    }];
}

- (IBAction)onSearch:(id)sender {
    [self.view endEditing:YES];
    [btnSearch setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnGuides setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    viewGuides.hidden = YES;
    viewSearch.hidden = NO;
    
//    txtSubject.itemList = ARRAY_SUBJECT;
//    txtSubject.selected = NO;
//    [txtSubject setSelectedRow:-1];
//    [txtSubject setSelectedItem:@""];
//    txtSubject.text = @"";
//    txtName.text = @"";
//    txtGradeLevel.text = @"";
//    txtNameAssign.text = @"";
//    txtAssign = @"";
}
- (IBAction)onGuides:(id)sender {
    [self.view endEditing:YES];
    [btnGuides setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnSearch setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    viewGuides.hidden = NO;
    viewSearch.hidden = YES;
    
    [self refreshItems];
}

- (IBAction)onback:(id)sender {
    if (!viewGuides.isHidden){
        [btnGuides setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btnSearch setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        viewGuides.hidden = YES;
        viewSearch.hidden = NO;
        
        txtSubject.itemList = ARRAY_SUBJECT;
        txtSubject.selected = NO;
        [txtSubject setSelectedRow:-1];
        [txtSubject setSelectedItem:@""];
        txtSubject.text = @"";
        txtName.text = @"";
        txtGradeLevel.text = @"";
        
        return;
    }
    if (!viewSearchAssignments.isHidden){
        viewButtons.hidden = NO;
        viewSearchGuides.hidden = YES;
        viewSearchAssignments.hidden = YES;
        return;
    }
    if (!viewSearchGuides.isHidden){
        viewButtons.hidden = NO;
        viewSearchGuides.hidden = YES;
        viewSearchAssignments.hidden = YES;
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onResult:(id)sender {
    /*txtName.text = [Util trim:txtName.text];
    txtGradeLevel.text = [Util trim:txtGradeLevel.text];
    if (txtName.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter teacher name."];
        return;
    }
    
    [self onGuides:nil];*/
    
    txtName.text = [Util trim:txtName.text];
    txtGradeLevel.text = [Util trim:txtGradeLevel.text];
    if (txtName.text.length == 0 && txtGradeLevel.text.length == 0 && txtSubject.selectedRow == -1){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your teacher name, subject or grade level."];
        return;
    }
    
    SearchResultsViewController *vc = (SearchResultsViewController *)[Util getUIViewControllerFromStoryBoard:@"SearchResultsViewController"];
    vc.name = txtName.text;
    vc.grade = [txtGradeLevel.text integerValue];
    vc.subject = txtSubject.selectedRow;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSearchAssignments:(id)sender {
    StudentAssignmentsResultsViewController *vc = (StudentAssignmentsResultsViewController *) [Util getUIViewControllerFromStoryBoard:@"StudentAssignmentsResultsViewController"];
    txtNameAssign.text = [Util trim:txtName.text];
    txtAssign.text = [Util trim:txtAssign.text];
    vc.teacherName = txtNameAssign.text;
    vc.assignName = txtAssign.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onStudyGuides:(id)sender {
    viewButtons.hidden = YES;
    viewSearchGuides.hidden = NO;
    viewSearchAssignments.hidden = YES;
}

- (IBAction)onAssignments:(id)sender {
    viewButtons.hidden = YES;
    viewSearchGuides.hidden = YES;
    viewSearchAssignments.hidden = NO;
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

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellGuide"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
    UILabel *lblGrade = (UILabel *)[cell viewWithTag:3];
    UILabel *lblSubject = (UILabel *)[cell viewWithTag:4];
    
    PFObject *obj = [dataArray objectAtIndex:indexPath.row];
    PFUser *owner = obj[PARSE_GUIDES_OWNER];
    owner = [owner fetchIfNeeded];
    lblName.text = owner[PARSE_USER_FULLNAME];
    lblTitle.text = obj[PARSE_GUIDES_TITLE];
    NSString *grade = [NSString stringWithFormat:@"%ld", [obj[PARSE_GUIDES_GRADE_LEVEL] integerValue]];
    if ([grade hasSuffix:@"1"]){
        grade = [NSString stringWithFormat:@"%@%@ Grade", grade, @"st"];
    } else if ([grade hasSuffix:@"2"]){
        grade = [NSString stringWithFormat:@"%@%@ Grade", grade, @"nd"];
    } else if ([grade hasSuffix:@"3"]){
        grade = [NSString stringWithFormat:@"%@%@ Grade", grade, @"rd"];
    } else {
        grade = [NSString stringWithFormat:@"%@%@ Grade", grade, @"th"];
    }
    lblGrade.text = grade;
    lblSubject.text = [ARRAY_SUBJECT objectAtIndex:[obj[PARSE_GUIDES_SUBJECT] integerValue]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *guide = [dataArray objectAtIndex:indexPath.row];
//    GuidePayViewController *vc = (GuidePayViewController *)[Util getUIViewControllerFromStoryBoard:@"GuidePayViewController"];
//    vc.guide = [dataArray objectAtIndex:indexPath.row];
//    [self.navigationController pushViewController:vc animated:YES];
    
    GuideDetailViewController *vc = (GuideDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"GuideDetailViewController"];
    vc.guide = guide;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
