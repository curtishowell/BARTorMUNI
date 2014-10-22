//
//  RootViewController.m
//  PageStarter
//
//  Created by Curtis Howell on 2/28/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import "RootViewController.h"
#import "ModelController.h"
#import "DataViewController.h"
#import "AppDelegate.h"

#define ARROW_ANIMATION_DURATION 0.5

@interface RootViewController ()

@property (readonly, strong, nonatomic) ModelController *modelController;
@property (weak, nonatomic) IBOutlet UIView *pageControlContainer;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *pageControlNearby;
@property (weak, nonatomic) IBOutlet UIImageView *directionArrow;
@property (nonatomic) BOOL inbound;
@property (weak, nonatomic) IBOutlet UIButton *inboundButton;
@property (weak, nonatomic) IBOutlet UIButton *outboundButton;
@property (strong, nonatomic) UIView *arrowView;

@end

@implementation RootViewController

@synthesize modelController = _modelController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    DataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageViewController.dataSource = self.modelController;
    
    [self addChildViewController:self.pageViewController];
    //    [self.view addSubview:self.pageViewController.view];
    [self.view insertSubview:self.pageViewController.view belowSubview:self.pageControlContainer];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;
    
    [self.pageViewController didMoveToParentViewController:self];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    self.inbound = YES;
    
    [super viewDidLoad];
    
    CGFloat arrowWidth = 50.0;
    CGFloat arrowHeight = 5;
    CGFloat pointyWidth = 10.0;
    CGFloat pointyHeight = 5.0;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat outsideMargin = 20.0;
    CGFloat topMargin = 110.0;
    
    //line
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(outsideMargin, topMargin)];
    [linePath addLineToPoint:CGPointMake(screenWidth - outsideMargin, topMargin)];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = [linePath CGPath];
    lineLayer.strokeColor = [[UIColor whiteColor] CGColor];
    lineLayer.lineWidth = 2.0;
    lineLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:lineLayer];
    
    //direction indicator
    if(!self.arrowView) {
        self.arrowView = [[UIView alloc] initWithFrame:CGRectMake(outsideMargin, topMargin, pointyWidth, arrowHeight + pointyHeight)];
    }
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(0.0, 0.0)];
    [arrowPath addLineToPoint:CGPointMake(0.0, arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(arrowWidth / 2 - pointyWidth / 2, arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(arrowWidth / 2, arrowHeight + pointyHeight)];
    [arrowPath addLineToPoint:CGPointMake(arrowWidth / 2 + pointyWidth / 2, arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(arrowWidth, arrowHeight)];
    [arrowPath addLineToPoint:CGPointMake(arrowWidth, 0.0)];
    [arrowPath closePath];
    
    
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.path = [arrowPath CGPath];
    arrowLayer.strokeColor = [[UIColor whiteColor] CGColor];
    arrowLayer.lineWidth = 2.0;
    arrowLayer.fillColor = [[UIColor whiteColor] CGColor];
    //    [self.view.layer addSublayer:arrowLayer];
    [self.arrowView.layer addSublayer:arrowLayer];
    [self.view addSubview:self.arrowView];
    
    [self setupArrow];
    
}

- (void)setInbound:(BOOL)inbound {
    _inbound = inbound;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.inbound = inbound;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"directionChanged"
                                                        object:nil];
}


- (void)setupArrow
{
    if(self.inbound){
        [self inboundPressed:nil];
    } else {
        [self outboundPressed:nil];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ModelController *)modelController
{
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ModelController alloc] init];
        _modelController.pageControl = self.pageControl;
        _modelController.pageControlNearby = self.pageControlNearby;
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods

/*
 - (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
 {
 
 }
 */

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

- (IBAction)inboundPressed:(id)sender {
    
    CGFloat arrowWidth = 50.0;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat outsideMargin = 20.0;

    [self moveArrow:screenWidth - outsideMargin - arrowWidth];

}

- (IBAction)outboundPressed:(id)sender {
    
    CGFloat outsideMargin = 20.0;
    
    [self moveArrow:outsideMargin];

}

- (void)moveArrow:(CGFloat)xPosition {
    self.inbound = !self.inbound;
    
    CGFloat arrowWidth = 50.0;
    CGFloat arrowHeight = 5;
    CGFloat pointyHeight = 5.0;
    CGFloat topMargin = 110.0;
    
    [UIView animateWithDuration:ARROW_ANIMATION_DURATION
                     animations:^{
                         self.arrowView.frame = CGRectMake(xPosition, topMargin, arrowWidth, arrowHeight + pointyHeight);
                     }];
}

@end
