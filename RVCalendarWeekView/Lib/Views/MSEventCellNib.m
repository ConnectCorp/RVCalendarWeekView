//
//  MSEventCellNib.m
//  RVCalendarWeekView
//
//  Created by Kyle Fleming on 10/14/16.
//  Copyright © 2016 Kyle Fleming. All rights reserved.
//

#import "MSEventCellNib.h"

@interface MSEventCellNib ()

@property (nonatomic) BOOL loaded;

@end

@implementation MSEventCellNib

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.loaded) {
        self.loaded = YES;
        
        if (!self.bundle) {
            self.bundle = [NSBundle mainBundle];
        }
        
        UIView *view = [self.bundle loadNibNamed:self.nibName owner:self options:nil][0];
        [self addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [view.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [view.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        
        [self didLoadNib];
    }
}

- (void)didLoadNib
{
}

@end
