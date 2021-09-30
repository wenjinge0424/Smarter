//
//  ParentSearchGuidesViewController.m
//  Smarter
//
//  Created by gao on 11/29/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ParentSearchGuidesViewController.h"
#import "IQDropDownTextField.h"
#import "SearchResultsViewController.h"
#import "GuideDetailViewController.h"

@interface ParentSearchGuidesViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIButton *btnSearch;
    IBOutlet UIButton *btnGuides;
    
    IBOutlet UIView *viewGuides;
    IBOutlet UIView *viewSearch;
    IBOutlet UITableView *tableviewGuids;
    IBOutlet UILabel *lblNoResult;
    IBOutlet UIView *viewSearchGuides;
    IBOutlet UITextField *txtName;
    IBOutlet IQDropDownTextField *txtSubject;
    IBOutlet UITextField *txtGradeLevele;
    
    NSMutableArray *dataArray;
}
@end

@implementation ParentSearchGuidesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dataArray = [[NSMutableArray alloc] init];
    [Util setCornerView:viewGuides];
    txtSubject.itemList = ARRAY_SUBJECT;
    
    [self onSearch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    txtSubject.itemList = ARRAY_SUBJECT;
    txtSubject.selected = NO;
    [txtSubject setSelectedRow:-1];
    [txtSubject setSelectedItem:@""];
    txtSubject.text = @"";
    txtName.text = @"";
    txtGradeLevele.text = @"";
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) refreshItems {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Error" message:@"No internet connectivity detected."];
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_GUIDES];
    [query whereKey:PARSE_GUIDES_TEACHER_LIST containsAllObjectsInArray:[[NSArray alloc] initWithObjects:self.student, nil]];
    [query addDescendingOrder:PARSE_FIELD_CREATED_AT];
    [query includeKey:PARSE_GUIDES_OWNER];
    [query includeKey:PARSE_GUIDES_TEACHER_LIST];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *) array;
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
    
    
}
- (IBAction)onGuides:(id)sender {
    [self.view endEditing:YES];
    [btnGuides setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnSearch setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    viewGuides.hidden = NO;
    viewSearch.hidden = YES;
    
    [self refreshItems];
}
- (IBAction)onResult:(id)sender {
    txtName.text = [Util trim:txtName.text];
    txtGradeLevele.text = [Util trim:txtGradeLevele.text];
    if (txtName.text.length == 0 && txtGradeLevele.text.length == 0 && txtSubject.selectedRow == -1){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your teacher name, subject or grade level."];
        return;
    }
    
    SearchResultsViewController *vc = (SearchResultsViewController *)[Util getUIViewControllerFromStoryBoard:@"SearchResultsViewController"];
    vc.name = txtName.text;
    vc.grade = [txtGradeLevele.text integerValue];
    vc.subject = txtSubject.selectedRow;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellGuide"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UILabel *lblTitle = (UILabel *)[cell viewWithTag:2];
    UILabel *lblGrade = (UILabel *)[cell viewWithTag:3];
    UILabel *lblSubject = (UILabel *)[cell viewWithTag:4];
    PFObject *object = [dataArray objectAtIndex:indexPath.row];
    PFUser *owner = object[PARSE_GUIDES_OWNER];
    lblName.text = owner[PARSE_USER_FULLNAME];
    lblTitle.text = object[PARSE_GUIDES_TITLE];
    NSString *grade = [NSString stringWithFormat:@"%ld", [object[PARSE_GUIDES_GRADE_LEVEL] integerValue]];
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
    lblSubject.text = [ARRAY_SUBJECT objectAtIndex:[object[PARSE_GUIDES_SUBJECT] integerValue]];
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GuideDetailViewController *vc = (GuideDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"GuideDetailViewController"];
    vc.guide = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
