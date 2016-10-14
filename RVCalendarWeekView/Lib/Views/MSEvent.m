//
//  AKEvent.m
//  Example
//
//  Created by ak on 18.01.2016.
//  Copyright © 2016 Eric Horacek. All rights reserved.
//

#import "MSEvent.h"

@implementation MSEvent

- (NSDate *)day{
    return [NSCalendar.currentCalendar startOfDayForDate:self.StartDate];
}

@end