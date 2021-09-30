//
//  ParentHistoryViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ParentHistoryViewController.h"

@interface ParentHistoryViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIButton *btnGraph;
    IBOutlet UIButton *btnLogs;
    
    IBOutlet UIView *viewGraph;
    IBOutlet UIView *viewLogs;
    IBOutlet UITableView *tableview;
}
@end

@implementation ParentHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    viewGraph.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onGraph:(id)sender {
    [btnGraph setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnLogs setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    viewGraph.hidden = NO;
    viewLogs.hidden = YES;
}

- (IBAction)onLogs:(id)sender {
    [btnGraph setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnLogs setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    viewGraph.hidden = YES;
    viewLogs.hidden = NO;
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
    return 6;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellLog"];
    return cell;
}

@end
