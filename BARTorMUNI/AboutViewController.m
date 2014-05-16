//
//  AboutViewController.m
//  BARTorMUNI
//
//  Created by Curtis Howell on 5/9/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openCurtisHowellTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/curtishowell"]];
}
- (IBAction)openTimWoo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/TIMOTHYRYANWOO"]];
}

//make money with ads, yay
- (void) bannerViewWillLoadAd{
    
}

-(void) bannerViewDidLoadAd{

}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    
}

- (void)bannerViewWillLoadAd:(ADBannerView *)banner {
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
