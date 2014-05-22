//
//  DataViewController.h
//  PageStarter
//
//  Created by Curtis Howell on 2/28/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"
#import <CoreLocation/CoreLocation.h>

@interface DataViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) UIPageControl *pageControl;
@property (weak, nonatomic) UIImageView *pageControlNearby;
@property (strong, nonatomic) Station *station;
@property (strong, nonatomic) IBOutlet UILabel *stationName;
@property (strong, nonatomic) NSArray *stations;

@end
