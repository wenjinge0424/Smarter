//
//  StudentQuestionViewController.h
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SuperViewController.h"

@interface StudentQuestionViewController : SuperViewController
+ (StudentQuestionViewController *)getInstance;
- (void) pushViewController:(UIViewController *)vc;

- (void) startTest:(NSDictionary *) data;
@end
