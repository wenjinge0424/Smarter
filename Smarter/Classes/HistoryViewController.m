//
//  HistoryViewController.m
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "HistoryViewController.h"
#import "MultiLineGraphView.h"
#import "Constants.h"

@interface HistoryViewController ()<UITableViewDelegate, UITableViewDataSource, MultiLineGraphViewDelegate, MultiLineGraphViewDataSource>
{
    IBOutlet UIButton *btnGraph;
    IBOutlet UIButton *btnLogs;
    
    IBOutlet UIView *viewGraph;
    IBOutlet UIView *viewLogs;
    IBOutlet UITableView *tableview;
    NSMutableArray *dataArray;
    
    NSMutableArray *array_art;
    NSMutableArray *array_computer;
    NSMutableArray *array_english;
    NSMutableArray *array_foreign;
    NSMutableArray *array_health;
    NSMutableArray *array_home;
    NSMutableArray *array_life;
    NSMutableArray *array_maths;
    NSMutableArray *array_music;
    NSMutableArray *array_physics;
    NSMutableArray *array_science;
    NSMutableArray *array_social;
    NSMutableArray *array_special;
    NSMutableArray *array_others;
}
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setCornerView:viewGraph];
    [Util setCornerView:viewLogs];
    
    viewGraph.userInteractionEnabled = NO;
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
    PFQuery *query = [PFQuery queryWithClassName:PARSE_TABLE_STUDY_LOGS];
    [query whereKey:PARSE_STUDY_OWNER equalTo:self.user];
    [query orderByDescending:PARSE_FIELD_CREATED_AT];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            if (objects.count > 0){
                [self initDataArray:(NSMutableArray *) objects];
            } else {
                [Util showAlertTitle:self title:@"" message:@"No study logs to show."];
            }
        }
    }];
}

- (void) initDataArray:(NSMutableArray *)array {
    NSString *Number = @"";
    int count = 0;
    int correctCount = 0;
    dataArray = [[NSMutableArray alloc] init];
    for (int index = 0;index<array.count;index++){
        PFObject *log = [array objectAtIndex:index];
        NSString *studyNumber = log[PARSE_STUDY_STUDY_NUMBER];
        if (![Number isEqualToString:studyNumber]){
            Number = studyNumber;
            count = 1;
            log[PARSE_STUDY_COUNT] = [NSNumber numberWithInt:count];
            if ([log[PARSE_STUDY_IS_CORRECT] boolValue]){
                correctCount = 1;
                log[PARSE_STUDY_CORRECT_COUNT] = [NSNumber numberWithInt:1];
            } else {
                correctCount = 0;
                log[PARSE_STUDY_CORRECT_COUNT] = [NSNumber numberWithInt:0];
            }
            [dataArray addObject:log];
        } else {
            count++;
            PFObject *last = [dataArray lastObject];
            last[PARSE_STUDY_COUNT] = [NSNumber numberWithInt:count];
            if ([log[PARSE_STUDY_IS_CORRECT] boolValue]){
                correctCount ++;
            }
            last[PARSE_STUDY_CORRECT_COUNT] = [NSNumber numberWithInt:correctCount];
            [dataArray removeLastObject];
            [dataArray addObject:last];
        }
    }
    
    [tableview reloadData];
    [self initGraphElements];
    // init graph elements
}

- (void) initGraphElements {
    array_art = [[NSMutableArray alloc] init];
    array_computer = [[NSMutableArray alloc] init];
    array_english = [[NSMutableArray alloc] init];
    array_foreign = [[NSMutableArray alloc] init];
    array_health = [[NSMutableArray alloc] init];
    array_home = [[NSMutableArray alloc] init];
    array_life = [[NSMutableArray alloc] init];
    array_maths = [[NSMutableArray alloc] init];
    array_music = [[NSMutableArray alloc] init];
    array_physics = [[NSMutableArray alloc] init];
    array_science = [[NSMutableArray alloc] init];
    array_social = [[NSMutableArray alloc] init];
    array_special = [[NSMutableArray alloc] init];
    array_others = [[NSMutableArray alloc] init];
    for (int i = 0;i<dataArray.count;i++){
        PFObject *object = [dataArray objectAtIndex:i];
        PFObject *quest = object[PARSE_STUDY_QUESTION];
        quest = [quest fetchIfNeeded];
        NSInteger subject = [quest[PARSE_QUESTION_SUBJECT] integerValue];
        if (subject == 0){
            [array_art addObject:object];
        } else if (subject == 1){
            [array_computer addObject:object];
        } else if (subject == 2){
            [array_english addObject:object];
        } else if (subject == 3){
            [array_foreign addObject:object];
        } else if (subject == 4){
            [array_health addObject:object];
        } else if (subject == 5){
            [array_home addObject:object];
        } else if (subject == 6){
            [array_life addObject:object];
        } else if (subject == 7){
            [array_maths addObject:object];
        } else if (subject == 8){
            [array_music addObject:object];
        } else if (subject == 9){
            [array_physics addObject:object];
        } else if (subject == 10){
            [array_science addObject:object];
        } else if (subject == 11){
            [array_social addObject:object];
        } else if (subject == 12){
            [array_special addObject:object];
        } else if (subject == 13){
            [array_others addObject:object];
        }
    }
    
    [self drawGraph];
}

- (void) drawGraph {
    // load test Graph View
    float header_height = 0;
    MultiLineGraphView *graph = [[MultiLineGraphView alloc] initWithFrame:CGRectMake(0, header_height, WIDTH(viewGraph), HEIGHT(viewGraph) - 0)];
    
    [graph setDelegate:self];
    [graph setDataSource:self];
    
    [graph setShowLegend:TRUE];
    [graph setLegendViewType:LegendTypeHorizontal];
    
    [graph setDrawGridY:TRUE];
    [graph setDrawGridX:FALSE];
    
    [graph setGridLineColor:[UIColor lightGrayColor]];
    [graph setGridLineWidth:0.3];
    
    [graph setTextFontSize:12];
    [graph setTextColor:[UIColor blackColor]];
    [graph setTextFont:[UIFont systemFontOfSize:graph.textFontSize]];
    
    [graph setMarkerColor:[UIColor orangeColor]];
    [graph setMarkerTextColor:[UIColor whiteColor]];
    [graph setMarkerWidth:0.4];
    [graph setShowMarker:TRUE];
    //    [graph showCustomMarkerView:TRUE];
    graph.showCustomMarkerView = YES;
    
    [graph drawGraph];
    [viewGraph addSubview:graph];
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
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellLog"];
    UILabel *lblDate = (UILabel *)[cell viewWithTag:1];
    UILabel *lblDescription = (UILabel *)[cell viewWithTag:2];
    PFObject *object = [dataArray objectAtIndex:indexPath.row];
    lblDate.text = [Util getParseDate:object.createdAt];
    PFObject *question = object[PARSE_STUDY_QUESTION];
    question = [question fetchIfNeeded];
    NSInteger subj = [question[PARSE_QUESTION_SUBJECT] integerValue];
    lblDescription.text = [NSString stringWithFormat:@"%@: %ld/%ld", [ARRAY_SUBJECT objectAtIndex:subj], [object[PARSE_STUDY_CORRECT_COUNT] integerValue], [object[PARSE_STUDY_COUNT] integerValue]];
    return cell;
}

#pragma mark MultiLineGraphViewDataSource
- (NSInteger)numberOfLinesToBePlotted{
    return 14;
}

- (LineDrawingType)typeOfLineToBeDrawnWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return LineDefault;
            break;
        case 1:
            return LineDefault;
            break;
        case 2:
            return LineDefault;
            break;
        case 3:
            return LineDefault;
            break;
        case 4:
            return LineDefault;
            break;
        case 5:
            return LineDefault;
            break;
        case 6:
            return LineDefault;
            break;
        case 7:
            return LineDefault;
            break;
        case 8:
            return LineDefault;
            break;
        case 9:
            return LineDefault;
            break;
        case 10:
            return LineDefault;
            break;
        case 11:
            return LineDefault;
            break;
        case 12:
            return LineDefault;
            break;
        case 13:
            return LineDefault;
            break;
        default:
            break;
    }
    return LineDefault;
}

- (UIColor *)colorForTheLineWithLineNumber:(NSInteger)lineNumber{
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    
    aRedValue = lineNumber * 70 % 255;
    aGreenValue = lineNumber * 170 % 255;
    aBlueValue = lineNumber * 230 % 255;
    
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    return randColor;
}

- (CGFloat)widthForTheLineWithLineNumber:(NSInteger)lineNumber{
    return 1;
}

- (NSString *)nameForTheLineWithLineNumber:(NSInteger)lineNumber{
    return [ARRAY_SUBJECT objectAtIndex:lineNumber];
}

- (BOOL)shouldFillGraphWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return false;
            break;
        case 1:
            return true;
            break;
        case 2:
            return false;
            break;
        case 3:
            return false;
            break;
        case 4:
            return true;
            break;
        case 5:
            return true;
            break;
        case 6:
            return true;
            break;
        case 7:
            return true;
            break;
        case 8:
            return true;
            break;
        case 9:
            return true;
            break;
        case 10:
            return true;
            break;
        case 11:
            return true;
            break;
        case 12:
            return true;
            break;
        case 13:
            return true;
            break;
        default:
            break;
    }
    return false;
}

- (BOOL)shouldDrawPointsWithLineNumber:(NSInteger)lineNumber{
    switch (lineNumber) {
        case 0:
            return true;
            break;
        case 1:
            return false;
            break;
        case 2:
            return false;
            break;
        case 3:
            return false;
            break;
        case 4:
            return false;
            break;
        case 5:
            return false;
            break;
        case 6:
            return false;
            break;
        case 7:
            return false;
            break;
        case 8:
            return false;
            break;
        case 9:
            return false;
            break;
        case 10:
            return false;
            break;
        case 11:
            return false;
            break;
        case 12:
            return false;
            break;
        case 13:
            return false;
            break;
        default:
            break;
    }
    return false;
}

- (NSMutableArray *)dataForYAxisWithLineNumber:(NSInteger)lineNumber {
    switch (lineNumber) {
        case 0: // Y axis values for first graph
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_art.count; i++) {
                PFObject *object = [array_art objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_art.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            
            return array;
        }
            break;
        case 1:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_computer.count; i++) {
                PFObject *object = [array_computer objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_computer.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 2:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_english.count; i++) {
                PFObject *object = [array_english objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_english.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 3:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_foreign.count; i++) {
                PFObject *object = [array_foreign objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_foreign.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 4:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_health.count; i++) {
                PFObject *object = [array_health objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_health.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 5:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_home.count; i++) {
                PFObject *object = [array_home objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_home.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 6:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_life.count; i++) {
                PFObject *object = [array_life objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_life.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 7:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_maths.count; i++) {
                PFObject *object = [array_maths objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_maths.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 8:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_music.count; i++) {
                PFObject *object = [array_music objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_music.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 9:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_physics.count; i++) {
                PFObject *object = [array_physics objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_physics.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 10:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_science.count; i++) {
                PFObject *object = [array_science objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_science.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 11:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_social.count; i++) {
                PFObject *object = [array_social objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_social.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 12:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_special.count; i++) {
                PFObject *object = [array_special objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_special.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        case 13:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i = 0; i < array_others.count; i++) {
                PFObject *object = [array_others objectAtIndex:i];
                int corrects = [object[PARSE_STUDY_CORRECT_COUNT] intValue];
                int sum = [object[PARSE_STUDY_COUNT] intValue];
                long val = (long) 50 * corrects / sum;
                [array addObject:[NSNumber numberWithLong:val]];
            }
            if (array_others.count == 0){
                [array addObject:[NSNumber numberWithLong:0]];
            }
            return array;
        }
            break;
        default:
            break;
    }
    return [[NSMutableArray alloc] init];
}

- (NSMutableArray *)dataForXAxisWithLineNumber:(NSInteger)lineNumber {
    switch (lineNumber) {
//        case 0: // x asix values for first graph
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 1:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 2:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 3:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 4:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 5:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 6:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 7:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 8:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 9:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 10:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 11:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 12:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
//        case 13:
//        {
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//            for (int i =0; i <= dataArray.count; i++) {
//                [array addObject:[NSString stringWithFormat:@"%d", i]];
//            }
//            return array;
//        }
//            break;
        default:
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i =0; i <= dataArray.count; i++) {
                [array addObject:[NSString stringWithFormat:@"%d", i]];
            }
            return array;
        }
            break;
    }
    return [[NSMutableArray alloc] init];
}

- (UIView *)customViewForLineChartTouchWithXValue:(id)xValue andYValue:(id)yValue{
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view.layer setCornerRadius:4.0F];
    [view.layer setBorderWidth:1.0F];
    [view.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setShadowRadius:2.0F];
    [view.layer setShadowOpacity:0.3F];
    
    CGFloat y = 0;
    CGFloat width = 0;
    for (int i = 0; i < 3 ; i++) {
        UILabel *label = [[UILabel alloc] init];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:[NSString stringWithFormat:@"Line Data:y = %@ x = %@", yValue, xValue]];
        [label setFrame:CGRectMake(0, y, 200, 30)];
        [view addSubview:label];
        
        width = WIDTH(label);
        y = BOTTOM(label);
    }
    
    [view setFrame:CGRectMake(0, 0, width, y)];
    return view;
}

#pragma mark MultiLineGraphViewDelegate
- (void)didTapWithValuesAtX:(NSString *)xValue valuesAtY:(NSString *)yValue{
    NSLog(@"Line Chart: Value-X:%@, Value-Y:%@",xValue, yValue);
}
@end
