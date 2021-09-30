//
//  PayModel.h
//  Eye On
//
//  Created by developer on 04/05/17.
//  Copyright © 2017 Vitaly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface AssignShowModel : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *assignment_number;
@property (strong, nonatomic) PFUser *owner;
@property (strong, nonatomic) NSMutableArray *assignmentList;
@end
