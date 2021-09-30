//
//  SearchGuideViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SearchGuideViewController.h"
#import "TeacherSettingsViewController.h"
#import "SearchResultsViewController.h"
#import "IQDropDownTextField.h"

@interface SearchGuideViewController ()
{
    IBOutlet UITextField *txtName;
    IBOutlet IQDropDownTextField *txtSubject;
    IBOutlet UITextField *txtGrade;
    
}
@end

@implementation SearchGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtSubject.itemList = ARRAY_SUBJECT;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    txtName.text = @"";
    [txtSubject setSelectedRow:-1];
    [txtSubject setSelectedItem:@""];
    txtSubject.itemList = ARRAY_SUBJECT;
    txtSubject.text = @"";
    txtGrade.text = @"";
}

- (IBAction)onSettings:(id)sender {
    TeacherSettingsViewController *vc = (TeacherSettingsViewController *)[Util getUIViewControllerFromStoryBoard:@"TeacherSettingsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onResults:(id)sender {
    txtName.text = [Util trim:txtName.text];
    txtGrade.text = [Util trim:txtGrade.text];
    if (txtName.text.length == 0 && txtGrade.text.length == 0 && txtSubject.selectedRow == -1){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter your teacher name, subject or grade level."];
        return;
    }
    SearchResultsViewController *vc = (SearchResultsViewController *) [Util getUIViewControllerFromStoryBoard:@"SearchResultsViewController"];
    vc.name = txtName.text;
    vc.grade = [txtGrade.text integerValue];
    vc.subject = [txtSubject selectedRow];
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
