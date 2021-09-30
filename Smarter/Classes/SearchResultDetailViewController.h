//
//  SearchResultDetailViewController.h
//  Smarter
//
//  Created by gao on 9/18/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SuperViewController.h"

@interface SearchResultDetailViewController : SuperViewController
@property (nonatomic) NSInteger subject;
@property (nonatomic) NSInteger grade;
@property (nonatomic, strong) PFUser *owner;
@end
