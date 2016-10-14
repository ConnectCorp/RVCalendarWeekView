//
//  MSEventStandard.h
//  RVCalendarWeekView
//
//  Created by Kyle Fleming on 10/14/16.
//  Copyright © 2016 Kyle Fleming. All rights reserved.
//

#import "MSEvent.h"

@interface MSEventStandard : MSEvent

@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSString  *location;

+(instancetype)make:(NSDate*)start title:(NSString*)title subtitle:(NSString*)subtitle;
+(instancetype)make:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle;

+(instancetype)make:(NSDate*)start duration:(int)minutes title:(NSString*)title subtitle:(NSString*)subtitle;

-(instancetype)initWithStart:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle;

@end
