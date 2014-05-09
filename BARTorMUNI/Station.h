//
//  Station.h
//  PageStarter
//
//  Created by Curtis Howell on 2/28/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Station : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *stationIndex;
@property (strong, nonatomic) NSString *BARTkey;
@property (strong, nonatomic) NSString *MUNIoutbound;
@property (strong, nonatomic) NSString *MUNIinbound;

@end
