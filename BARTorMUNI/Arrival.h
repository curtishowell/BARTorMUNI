//
//  Arrival.h
//  BARTorMUNI
//
//  Created by Curtis Howell on 4/21/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import <Foundation/Foundation.h>

enum StationType : NSUInteger {
    StationTypeBART = 1,
    StationTypeMUNI = 2,
};

@interface Arrival : NSObject

@property (nonatomic) enum StationType stationType;
@property (nonatomic) NSNumber *minutesUntilArrival;

@end
