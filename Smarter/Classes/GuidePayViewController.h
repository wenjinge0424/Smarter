//
//  GuidePayViewController.h
//  Smarter
//
//  Created by gao on 9/19/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SuperViewController.h"

@interface GuidePayViewController : SuperViewController
@property (strong, nonatomic) PFObject *guide;
- (void) hidePayButton;
@end
