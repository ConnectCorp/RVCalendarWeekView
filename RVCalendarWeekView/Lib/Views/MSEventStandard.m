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
    return [self.class make:start duration:60 title:title subtitle:subtitle];
}

+(instancetype)make:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle{
    MSEventStandard* event = [self.class new];
    event.StartDate = start;
    event.EndDate   = end;
    event.title     = title;
    event.location  = subtitle;
    event.reuseIdentifierPostfix = MSEventDefaultReuseIdentifierPostfix;
    return event;
}

+(instancetype)make:(NSDate*)start duration:(int)minutes title:(NSString*)title subtitle:(NSString*)subtitle{
    MSEventStandard* event  = [self.class new];
    event.StartDate = start;
    event.EndDate   = [start addMinutes:minutes];
    event.title     = title;
    event.location  = subtitle;
    event.reuseIdentifierPostfix = MSEventDefaultReuseIdentifierPostfix;
    return event;
}

@end
