//
//  DataViewController.h
//  BARTorMUNI
//
//  Created by Curtis Howell on 3/23/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;

@end
