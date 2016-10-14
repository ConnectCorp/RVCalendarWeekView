//
//  MSEventStandard.m
//  RVCalendarWeekView
//
//  Created by Kyle Fleming on 10/14/16.
//  Copyright © 2016 Kyle Fleming. All rights reserved.
//

#import "MSEventStandard.h"
#import "NSDate+Easy.h"

@implementation MSEventStandard

+(instancetype)make:(NSDate*)start title:(NSString*)title subtitle:(NSString*)subtitle{
    return [self make:start duration:60 title:title subtitle:subtitle];
}

+(instancetype)make:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle{
    return [[self alloc] initWithStart:start end:end title:title subtitle:subtitle];
}

+(instancetype)make:(NSDate*)start duration:(int)minutes title:(NSString*)title subtitle:(NSString*)subtitle{
    return [self make:start end:[start addMinutes:minutes] title:title subtitle:subtitle];
}

-(instancetype)initWithStart:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle{
    self = [super initWithStart:start end:end];
    if (self) {
        self.title     = title;
        self.location  = subtitle;
    }
    return self;
}

@end
