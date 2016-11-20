//
//  MSDayColumnHeader.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import "MSDayColumnHeader.h"
#define MAS_SHORTHAND
#import "Masonry.h"
#import "UIColor+HexString.h"

@interface MSDayColumnHeader ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *titleBackground;

@end

@implementation MSDayColumnHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleBackground                    = [UIView new];
        self.titleBackground.layer.cornerRadius = nearbyintf(15.0);
        [self addSubview:self.titleBackground];
        
        self.backgroundColor        = [UIColor clearColor];
        self.title                  = [UILabel new];
        self.title.backgroundColor  = [UIColor clearColor];
        [self addSubview:self.title];
        
        [self.titleBackground makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.title).with.insets(UIEdgeInsetsMake(-6.0, -12.0, -4.0, -12.0));
        }];
        
        [self.title makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (void)setDay:(NSDate *)day
{
    _day = day;
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = [self dateFormat];
    }
    self.title.text = [dateFormatter stringFromDate:day];
    [self setNeedsLayout];
}

- (void)setCurrentDay:(BOOL)currentDay
{
    _currentDay = currentDay;
    
    self.title.font                         = [self fontForCurrentDay:currentDay];
    self.title.textColor                    = [self titleColorForCurrentDay:currentDay];
    self.titleBackground.backgroundColor    = [self titleBackgroundColorForCurrentDay:currentDay];
}

- (NSString *)dateFormat
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"EEE d" : @"EEE MMMM d, YYYY";
}

- (UIFont *)fontForCurrentDay:(BOOL)isCurrentDay
{
    return isCurrentDay ? [UIFont boldSystemFontOfSize:16.0] : [UIFont systemFontOfSize:16.0];
}

- (UIColor *)titleColorForCurrentDay:(BOOL)isCurrentDay
{
    return isCurrentDay ? [UIColor whiteColor] : [UIColor blackColor];
}

- (UIColor *)titleBackgroundColorForCurrentDay:(BOOL)isCurrentDay
{
    return isCurrentDay ? [UIColor colorWithRed:42/255.0 green: 183/255.0 blue: 183/255.0 alpha: 1.0] : [UIColor clearColor];
}

@end
