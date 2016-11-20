//
//  MSAllDayGridline.m
//
//  Created by Rahul Arora on 11/19/16.

#import "MSAllDayEventsGridline.h"
#import "UIColor+HexString.h"

@implementation MSAllDayEventsGridline

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"1BB7B8"];
    }
    return self;
}

@end
