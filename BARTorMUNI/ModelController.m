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
@property (readonly, strong, nonatomic) NSArray *stations;
@end

@implementation ModelController

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *stations = [self readStations];
        NSMutableArray *stationBuildup = [[NSMutableArray alloc] init];
        
        //add nearby station
        Station *nearbyStation = [[Station alloc] init];
        nearbyStation.stationIndex = [NSNumber numberWithInt:0];
        nearbyStation.isNearbyStation = YES;
        nearbyStation.name = @"Locating";
        [stationBuildup addObject:nearbyStation];
        
        for(int i = 0; i < [stations count]; i ++) {
            NSDictionary *station = stations[i];
            Station *s = [[Station alloc] init];
            s.stationIndex = [NSNumber numberWithInteger:i + 1];
            s.name = [station objectForKey:@"Station_name"];
            s.BARTkey = [station objectForKey:@"BART_key"];
            s.MUNIinbound = [station objectForKey:@"MUNI_inbound"];
            s.MUNIoutbound = [station objectForKey:@"MUNI_outbound"];
            s.location = [[CLLocation alloc] initWithLatitude:[[station objectForKey:@"latitude"] doubleValue]
                                                    longitude:[[station objectForKey:@"longitude"] doubleValue]];
            s.isNearbyStation = NO;
            [stationBuildup addObject:s];
        }

        _stations = stationBuildup;
    }
    return self;
}

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index
                                   storyboard:(UIStoryboard *)storyboard
{
    // Return the data view controller for the given index.
    if (([self.stations count] == 0) || (index >= [self.stations count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    dataViewController.station = self.stations[index];
    dataViewController.stations = self.stations;
    dataViewController.pageControl = self.pageControl;
    dataViewController.pageControlNearby = self.pageControlNearby;
    
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(DataViewController *)viewController
{
    return [viewController.station.stationIndex integerValue];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.stations count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index
                            storyboard:viewController.storyboard];
}

- (NSArray *)readStations
{
    NSArray *stations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]
                                                          pathForResource:@"Stations"
                                                          ofType:@"plist"]];
    
//    NSLog(@"%@",stations);
//    
//    for(NSDictionary *station in stations) {
//        NSLog(@"%@", station);
//    }
    
    return stations;
}

@end
