//
//  ModelController.h
//  PageStarter
//
//  Created by Curtis Howell on 2/28/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@property (weak, nonatomic) UIPageControl *pageControl;
@property (weak, nonatomic) UIImageView *pageControlNearby;

@end
