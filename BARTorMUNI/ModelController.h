//
//  ModelController.h
//  BARTorMUNI
//
//  Created by Curtis Howell on 3/23/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end
