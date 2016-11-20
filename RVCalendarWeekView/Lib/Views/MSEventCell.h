//
//  MSEventCell.h
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSEvent.h"

@class MSEvent;

@interface MSEventCell : UICollectionViewCell

@property (nonatomic, strong) MSEvent *event; // Actual event backing this cell.
@property (nonatomic, strong) MSEvent *displayedEvent; // Event driving the display of cell. This is different if event spans multiple days and is thus broken up into multiple Displayed Events.

@end