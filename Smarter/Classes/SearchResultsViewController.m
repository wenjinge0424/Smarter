//
//  SearchResultsViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "PayModel.h"
#import "StripeRest.h"
#import "MyPaymentViewController.h"
#import "SearchResultDetailViewController.h"

@interface SearchResultsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
    
    NSMutableArray *dataArray;
    NSInteger selecteIndex;
    IBOutlet UILabel *lblResult;
    
}
@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setCornerView:tableview];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(PaySuccess:) name:NOTIFICATION_PAY_SUCCESS_EVENT object:nil];
    
    [self refreshItems];
}

- (void) refreshItems {
    selecteIndex = -1;
    PFQuery *ownerQuery = [PFUser query];
    [ownerQuery whereKey:PARSE_USER_FULLNAME matchesRegex:self.name modifiers:@"i"];
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_GUIDES];
    [query includeKey:PARSE_GUIDES_OWNER];
    
    if (self.name.length != 0){
        [query whereKey:PARSE_GUIDES_OWNER matchesQuery:ownerQuery];
    }
    if (self.subject != -1){
        [query whereKey:PARSE_GUIDES_SUBJECT equalTo:[NSNumber numberWithInteger:self.subject]];
    }
    if (self.grade != 0){
        [query whereKey:PARSE_GUIDES_GRADE_LEVEL equalTo:[NSNumber numberWithInteger:self.grade]];
    }
    [query whereKey:PARSE_GUIDES_TEACHER_LIST notEqualTo:[PFUser currentUser]];
    [query orderByAscending:PARSE_GUIDES_OWNER];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = [[NSMutableArray alloc] init];
            PFObject *new = [PFObject objectWithClassName:PARSE_TABLE_GUIDES];
            int counter = 1;
            for (int i=0;i<array.count;i++){
                PFObject *guide = [array objectAtIndex:i];
                PFUser *user = guide[PARSE_GUIDES_OWNER];
                
                if (i == 0){
                    new[PARSE_GUIDES_OWNER] = user;
                    new[PARSE_GUIDES_PRICE] = guide[PARSE_GUIDES_PRICE];
                    new[PARSE_GUIDES_COUNT] = [NSNumber numberWithInt:counter];
                    if (![dataArray containsObject:new])
                        [dataArray addObject:new];
                } else {
                    PFObject *guidePre = [array objectAtIndex:(i-1)];
                    PFUser *user1 = guidePre[PARSE_GUIDES_OWNER];
                    if ([user.objectId isEqualToString:user1.objectId]){
                        new[PARSE_GUIDES_PRICE] = [NSNumber numberWithDouble:([new[PARSE_GUIDES_PRICE] doubleValue] + [guide[PARSE_GUIDES_PRICE] doubleValue])];
                        counter++;
                        if (i == array.count - 1){
                            new[PARSE_GUIDES_COUNT] = [NSNumber numberWithInt:counter];
                            if (![dataArray containsObject:new])
                                [dataArray addObject:new];
                        }
                    } else {
                        new[PARSE_GUIDES_COUNT] = [NSNumber numberWithInt:counter];
                        if (![dataArray containsObject:new])
                            [dataArray addObject:new];
                        new = [PFObject objectWithClassName:PARSE_TABLE_GUIDES];
                        new[PARSE_GUIDES_OWNER] = user;
                        counter = 1;
                        new[PARSE_GUIDES_PRICE] = guide[PARSE_GUIDES_PRICE];
                        new[PARSE_GUIDES_COUNT] = [NSNumber numberWithInt:counter];
                    }
                }
            }
            
            [tableview reloadData];
            if (dataArray.count == 0){
                tableview.hidden = YES;
                lblResult.text = @"No result";
            } else {
                tableview.hidden = NO;
                lblResult.text = @"Search Results";
            }
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
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    UILabel *price = (UILabel *)[cell viewWithTag:2];
    UILabel *count = (UILabel *)[cell viewWithTag:3];
    PFObject *object = [dataArray objectAtIndex:indexPath.row];
    PFUser *owner = object[PARSE_GUIDES_OWNER];
    label.text = [NSString stringWithFormat:@"%ld. %@", indexPath.row + 1, owner[PARSE_USER_FULLNAME]];
    price.text = [NSString stringWithFormat:@"$%.2f", [object[PARSE_GUIDES_PRICE] doubleValue]];
    count.text = [NSString stringWithFormat:@"view guide list(%ld)", [object[PARSE_GUIDES_COUNT] integerValue]];
    if ([object[PARSE_GUIDES_PRICE] doubleValue] == 0){
        price.text = @"FREE";
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *object = [dataArray objectAtIndex:indexPath.row];
    PFUser *owner = object[PARSE_GUIDES_OWNER];
    SearchResultDetailViewController *vc = (SearchResultDetailViewController *)[Util getUIViewControllerFromStoryBoard:@"SearchResultDetailViewController"];
    vc.owner = owner;
    vc.grade = self.grade;
    vc.subject = self.subject;
    [self.navigationController pushViewController:vc animated:YES];
//    PFObject *obj = [dataArray objectAtIndex:indexPath.row];
//    PFUser *owner = obj[PARSE_GUIDES_OWNER];
//    double price = [obj[PARSE_GUIDES_PRICE] doubleValue];
//    int amount = (int) price * 100;
//    if (amount == 0){
//        selecteIndex = indexPath.row;
//        [self PaySuccess:nil];
//    }
//    [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
//    [owner fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (error) {
//            [SVProgressHUD dismiss];
//            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription] finish:^(void) {
//            }];
//        } else {
//            // check stripe account
//            [StripeRest getAccount:owner[PARSE_USER_ACCOUNT_ID] completionBlock:^(id data, NSError *error) {
//                [SVProgressHUD dismiss];
//                if (error) {
//                    NSString *confirmStr = @"This user requires a connected ‘Stripe’ account";
//                    [Util showAlertTitle:self title:@"" message:confirmStr finish:^(void){
//                        
//                    }];
//                } else {
//                    selecteIndex = indexPath.row;
//                    MyPaymentViewController *vc = (MyPaymentViewController *)[Util getUIViewControllerFromStoryBoard:@"MyPaymentViewController"];
//                    PayModel *payModel = [[PayModel alloc] init];
//                    payModel.amount = [NSString stringWithFormat:@"%d", amount];
//                    payModel.accountId = owner[PARSE_USER_ACCOUNT_ID];
//                    vc.payModel = payModel;
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
//            }];
//        }
//    }];
}

- (void) PaySuccess:(NSNotification *) notif {
    if (selecteIndex != -1){
        PFObject *obj = [dataArray objectAtIndex:selecteIndex];
        int price = (int)[obj[PARSE_GUIDES_PRICE] doubleValue];
        NSMutableArray *array = obj[PARSE_GUIDES_TEACHER_LIST];
        if (!array){
            array = [[NSMutableArray alloc] init];
        }
        [array addObject:[PFUser currentUser]];
        obj[PARSE_GUIDES_TEACHER_LIST] = array;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *error){
            [SVProgressHUD dismiss];
            if (succeed && !error){
                PFObject *objHistory = [PFObject objectWithClassName:PARSE_TABLE_PAYMENT_HISTORY];
                objHistory[PARSE_PAYMENT_AMOUNT] = [NSNumber numberWithInt:price];
                objHistory[PARSE_PAYMENT_TO_USER] = obj[PARSE_GUIDES_OWNER];
                objHistory[PARSE_PAYMENT_FROM_USER] = [PFUser currentUser];
                [objHistory saveInBackground];
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^(void){
                    [self refreshItems];
                }];
            } else {
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            }
        }];
    }
}

@end
