//
//  SearchResultDetailViewController.m
//  Smarter
//
//  Created by gao on 9/18/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SearchResultDetailViewController.h"
#import "GuidePayViewController.h"

@interface SearchResultDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    IBOutlet UILabel *lblUsername;
}
@property (weak, nonatomic) IBOutlet UILabel *lbl_subject;
@property (weak, nonatomic) IBOutlet UILabel *lbl_gradDetail;
@end

@implementation SearchResultDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setCornerView:tableview];
    lblUsername.text = self.owner[PARSE_USER_FULLNAME];
    
    if (self.subject != -1){
        self.lbl_subject.text = [ARRAY_SUBJECT objectAtIndex:(int)self.subject];
    }else{
        self.lbl_subject.text = [ARRAY_SUBJECT objectAtIndex:0];
    }
    NSString *gradeStr = @"1";
    if (self.grade != 0){
        gradeStr = [NSString stringWithFormat:@"%ld", (int)self.grade];
    }
    if ([gradeStr hasSuffix:@"1"]){
        gradeStr = [NSString stringWithFormat:@"%@%@ Grade", gradeStr, @"st"];
    } else if ([gradeStr hasSuffix:@"2"]){
        gradeStr = [NSString stringWithFormat:@"%@%@ Grade", gradeStr, @"nd"];
    } else if ([gradeStr hasSuffix:@"3"]){
        gradeStr = [NSString stringWithFormat:@"%@%@ Grade", gradeStr, @"rd"];
    } else {
        gradeStr = [NSString stringWithFormat:@"%@%@ Grade", gradeStr, @"th"];
    }
    self.lbl_gradDetail.text = gradeStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshItems];
}

- (void) refreshItems {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_GUIDES];
    [query includeKey:PARSE_GUIDES_OWNER];
    
    if (self.subject != -1){
        [query whereKey:PARSE_GUIDES_SUBJECT equalTo:[NSNumber numberWithInteger:self.subject]];
    }
    if (self.grade != 0){
        [query whereKey:PARSE_GUIDES_GRADE_LEVEL equalTo:[NSNumber numberWithInteger:self.grade]];
    }
    [query whereKey:PARSE_GUIDES_TEACHER_LIST notEqualTo:[PFUser currentUser]];
    [query whereKey:PARSE_GUIDES_OWNER equalTo:self.owner];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray *)array;
            [tableview reloadData];
        }
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellGuide"];
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    UILabel *lblPrice = (UILabel *)[cell viewWithTag:2];
    PFObject *guide = [dataArray objectAtIndex:indexPath.row];
    lblName.text = guide[PARSE_GUIDES_TITLE];
    lblPrice.text = [NSString stringWithFormat:@"$%.2f", [guide[PARSE_GUIDES_PRICE] doubleValue]];
    if ([guide[PARSE_GUIDES_PRICE] doubleValue] == 0){
        lblPrice.text = @"FREE";
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GuidePayViewController *vc = (GuidePayViewController *)[Util getUIViewControllerFromStoryBoard:@"GuidePayViewController"];
    vc.guide = [dataArray objectAtIndex:indexPath.row];
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

@end
