//
//  GuideDetailViewController.h
//  Smarter
//
//  Created by gao on 8/25/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface GuideDetailViewController : SuperViewController
@property (strong, nonatomic) PFObject *guide;
@end
