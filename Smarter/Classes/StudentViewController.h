//
//  StudentViewController.h
//  Smarter
//
//  Created by gao on 8/7/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SuperViewController.h"

@interface StudentViewController : SuperViewController
+ (StudentViewController *)getInstance;
- (void) pushViewController:(UIViewController *) viewController;
- (void) pushViewController:(UIViewController *)viewController animation:(BOOL) animate;
- (void) presentViewController:(UIViewController *) viewController;

@end
