//
//  StudyResultViewController.h
//  Smarter
//
//  Created by gao on 9/1/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SuperViewController.h"

@interface StudyResultViewController : SuperViewController
@property (strong, nonatomic) PFObject *object;
@property (strong, nonatomic) NSString *timeStamp;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger count;
@property (nonatomic) BOOL isCorrect;
@property (nonatomic) BOOL isSkip;
@property (strong, nonatomic) NSMutableArray *dataArray;
@end
