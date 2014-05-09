//
//  DataViewController.h
//  PageStarter
//
//  Created by Curtis Howell on 2/28/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"

@interface DataViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
//@property (strong, nonatomic) Station *dataObject;
@property (weak, nonatomic) UIPageControl *pageControl;
@property (weak, nonatomic) UIImageView *pageControlNearby;
@property (strong, nonatomic) Station *station;

//TODO get rid of dataObject; station is alreay here

@end
