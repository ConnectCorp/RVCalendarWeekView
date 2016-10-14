//
//  AKEvent.h
//  Example
//
//  Created by ak on 18.01.2016.
//  Copyright © 2016 Eric Horacek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DateTools/DTTimePeriod.h>

#define MSEventDefaultReuseIdentifierPostfix @"default"

@interface MSEvent : DTTimePeriod

@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSString  *location;

@property (nonatomic, strong) NSString *reuseIdentifierPostfix;

+(instancetype)make:(NSDate*)start title:(NSString*)title subtitle:(NSString*)subtitle;
+(instancetype)make:(NSDate*)start end:(NSDate*)end title:(NSString*)title subtitle:(NSString*)subtitle;

+(instancetype)make:(NSDate*)start duration:(int)minutes title:(NSString*)title subtitle:(NSString*)subtitle;

- (NSDate *)day;

@end