//
//  ModelController.m
//  PageStarter
//
//  Created by Curtis Howell on 2/28/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import "ModelController.h"

#import "DataViewController.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@interface ModelController()
@property (readonly, strong, nonatomic) NSArray *pageData;
@end

@implementation ModelController

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *stations = [self readStations];
        NSMutableArray *stationBuildup = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < [stations count]; i ++) {
            NSDictionary *station = stations[i];
            Station *s = [[Station alloc] init];
            s.stationIndex = [NSNumber numberWithInteger:i];
            s.name = [station objectForKey:@"Station_name"];
            s.BARTkey = [station objectForKey:@"BART_key"];
            s.MUNIinbound = [station objectForKey:@"MUNI_inbound"];
            s.MUNIoutbound = [station objectForKey:@"MUNI_outbound"];
            [stationBuildup addObject:s];
        }


//        NSArray *stationNames = @[@"Nearby", @"Civic Center", @"Powell", @"Montgomery", @"Embarcadero"];
//        for(int i = 0; i < [stationNames count]; i++){
//            Station *s = [[Station alloc] init];
//            s.name = stationNames[i];
//            s.stationIndex = [NSNumber numberWithInt:i];
//            [stationBuildup addObject:s];
//        }
        _pageData = stationBuildup;
    }
    return self;
}

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    dataViewController.station = self.pageData[index];
    dataViewController.pageControl = self.pageControl;
    dataViewController.pageControlNearby = self.pageControlNearby;
    
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(DataViewController *)viewController
{
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.station];
    //TODO: can just return index form dataObject instead of looking up index in array
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (NSArray *)readStations
{
    NSArray *stations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Stations" ofType:@"plist"]];
    
//    NSLog(@"%@",stations);
//    
//    for(NSDictionary *station in stations) {
//        NSLog(@"%@", station);
//    }
    
    return stations;
}

@end
