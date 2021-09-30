//
//  CircleImageView.m
//
//  Created by star on 12/2/15.
//  Copyright (c) 2015 UWP. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)init {
    self = [super init];
    if (self) {
        [self setUISettings];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUISettings];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUISettings];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setUISettings];
}

- (void)setUISettings {
    
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:)){
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end
