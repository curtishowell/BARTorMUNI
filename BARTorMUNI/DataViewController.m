//
//  DataViewController.m
//  PageStarter
//
//  Created by Curtis Howell on 2/28/14.
//  Copyright (c) 2014 Curtis Howell. All rights reserved.
//

#import "DataViewController.h"
#import "AFNetworking.h"
#import "Arrival.h"
#import "AppDelegate.h"

@interface DataViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *arrivals;
@property (strong, nonatomic) NSMutableArray *nextArrivals;
@property (nonatomic) BOOL visible;

//XML parser
@property(nonatomic, strong) NSMutableDictionary *currentDictionary;   // current section being parsed
@property(nonatomic, strong) NSMutableDictionary *xmlWeather;          // completed parsed xml response

@property(nonatomic, strong) NSString *BARTelementName;
@property(nonatomic, strong) NSString *MUNIelementName;

@property(nonatomic, strong) NSMutableString *BARToutstring;
@property(nonatomic, strong) NSMutableString *MUNIoutstring;

@property(nonatomic, strong) NSXMLParser *BARTparser;
@property(nonatomic, strong) NSXMLParser *MUNIparser;

@property(nonatomic) BOOL BARTisParsing;
@property(nonatomic) BOOL MUNIisParsing;

@end

@implementation DataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(directionChanged:)
                                                 name:@"directionChanged" object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = self.station.name;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.visible = YES;
    [super viewDidAppear:animated];
    [self updatePageControl];
    
    [self fetchNewData];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.visible = NO;
}


- (void)directionChanged:(NSNotificationCenter *)center {
    if(self.visible){
        [self fetchNewData];
    }
}

- (void)updatePageControl
{
    self.pageControl.currentPage = [self.station.stationIndex integerValue];
    if([self.station.stationIndex integerValue] == 0) {
        [self.pageControlNearby setHidden:NO];
    } else if (!self.pageControlNearby.hidden) {
        [self.pageControlNearby setHidden:YES];
    }
}

#pragma mark - table view
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = nil;
    Arrival *arrival = self.arrivals[indexPath.row];
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"firstStop"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"additionalStops"];
    }
    
    NSString *minuteLabel = @" minutes";
    if([arrival.minutesUntilArrival intValue] < 2) {
        minuteLabel = @" minute";
    }
    
    UILabel *label;

    //BART or MUNI
    label = (UILabel *)[cell viewWithTag:1];
    if(arrival.stationType == StationTypeBART){
        label.text = @"BART";
    } else if(arrival.stationType == StationTypeMUNI){
        label.text = @"MUNI";
    }
    [label sizeToFit];
    
    //# of minutes
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%@", [arrival.minutesUntilArrival stringValue]];
//    [label sizeToFit];
    
    //minute or minutes
    label = (UILabel *)[cell viewWithTag:3];
    label.text = minuteLabel;
//    [label sizeToFit];

    
    

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrivals count];
}

#pragma mark - fetch data

- (void)fetchNewData {
    
    self.nextArrivals = [NSMutableArray array];
    
    BOOL inbound = [(AppDelegate *)([[UIApplication sharedApplication] delegate]) inbound];
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    BOOL inbound = appDelegate.inbound;
    
//    BOOL inbounda = [(AppDelegate *)[[UIApplication sharedApplication] delegate] inbound];
    
    [self fetchBARTData:inbound];
    [self fetchMUNIdata:inbound];
}

- (void)fetchBARTData:(BOOL)inbound {
    
    self.BARTisParsing = YES;
    
    NSString *inboundIdentifier = inbound ? @"n" : @"s";
    NSString *URLString = [NSString stringWithFormat:@"http://api.bart.gov/api/etd.aspx?key=MW9S-E7SL-26DU-VV8V&cmd=etd&orig=%@&dir=%@", self.station.BARTkey, inboundIdentifier];
    
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // set the responseSerializer
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSXMLParser *XMLParser = (NSXMLParser *)responseObject;
        self.BARTparser = XMLParser;
        [XMLParser setShouldProcessNamespaces:YES];
        
        XMLParser.delegate = self;
        [XMLParser parse];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving BART arrivals"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }];
    
    [operation start];
}

- (void)fetchMUNIdata:(BOOL)inbound {
    
    self.MUNIisParsing = YES;

    NSString *stopCode = inbound ? self.station.MUNIinbound : self.station.MUNIoutbound;
    
    NSString *URLString = [NSString stringWithFormat:@"http://services.my511.org/Transit2.0/GetNextDeparturesByStopCode.aspx?token=20e036b6-089b-4b2f-bed7-303d1466d7e8&stopcode=%@", stopCode];
    
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // set the responseSerializer
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSXMLParser *XMLParser = (NSXMLParser *)responseObject;
        self.MUNIparser = XMLParser;
        [XMLParser setShouldProcessNamespaces:YES];
        
        XMLParser.delegate = self;
        [XMLParser parse];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving BART arrivals"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }];
    
    [operation start];
}

//- (void)parserDidStartDocument:(NSXMLParser *)parser
//{
//    if(parser == self.BARTparser) {
//        self.xmlWeather = [NSMutableDictionary dictionary];
//    } else if (parser == self.MUNIparser) {
//        
//    }
//}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if(parser == self.BARTparser) {

        self.BARTelementName = qName;
        
//        if([qName isEqualToString:@"station"] ||
//           [qName isEqualToString:@"etd"] ||
//           [qName isEqualToString:@"estimate"]) {
//            self.currentDictionary = [NSMutableDictionary dictionary];
//        }
        
        self.BARToutstring = [NSMutableString string];
        
    } else if (parser == self.MUNIparser) {
        self.MUNIelementName = qName;
        
        self.MUNIoutstring = [NSMutableString string];


    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{

    
    if(parser == self.BARTparser) {
        if (!self.BARTelementName)
            return;
        [self.BARToutstring appendFormat:@"%@", string];
    } else if (parser == self.MUNIparser) {
        if (!self.MUNIelementName)
            return;
        [self.MUNIoutstring appendFormat:@"%@", string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
//    // 1
//    if ([qName isEqualToString:@"current_condition"] ||
//        [qName isEqualToString:@"request"]) {
//        self.xmlWeather[qName] = @[self.currentDictionary];
//        self.currentDictionary = nil;
//    }
//    // 2
//    else if ([qName isEqualToString:@"weather"]) {
//        
//        // Initialize the list of weather items if it doesn't exist
//        NSMutableArray *array = self.xmlWeather[@"weather"] ?: [NSMutableArray array];
//        
//        // Add the current weather object
//        [array addObject:self.currentDictionary];
//        
//        // Set the new array to the "weather" key on xmlWeather dictionary
//        self.xmlWeather[@"weather"] = array;
//        
//        self.currentDictionary = nil;
//    }
//    // 3
//    else if ([qName isEqualToString:@"value"]) {
//        // Ignore value tags, they only appear in the two conditions below
//    }
//    // 4
//    else if ([qName isEqualToString:@"weatherDesc"] ||
//             [qName isEqualToString:@"weatherIconUrl"]) {
//        NSDictionary *dictionary = @{@"value": self.outstring};
//        NSArray *array = @[dictionary];
//        self.currentDictionary[qName] = array;
//    }
//    // 5
//    else if (qName) {
//        self.currentDictionary[qName] = self.outstring;
//    }
    
    if(parser == self.BARTparser) {
        if ([qName isEqualToString:@"minutes"]) {
            //        self.currentDictionary[qName] = self.outstring;
            Arrival *arrival = [[Arrival alloc] init];
            
            NSNumber *minutesUntilArrival = [self stringToInt:self.BARToutstring];
            
            arrival.minutesUntilArrival = minutesUntilArrival;
            arrival.stationType = StationTypeBART;
            
            [self.nextArrivals addObject:arrival];
        }
        
        self.BARTelementName = nil;
        
    } else if(parser == self.MUNIparser) {
        if ([qName isEqualToString:@"DepartureTime"]) {
            //        self.currentDictionary[qName] = self.outstring;
            Arrival *arrival = [[Arrival alloc] init];
            
            NSNumber *minutesUntilArrival = [self stringToInt:self.MUNIoutstring];
            
            arrival.minutesUntilArrival = minutesUntilArrival;
            arrival.stationType = StationTypeMUNI;
            
            [self.nextArrivals addObject:arrival];
        }
        
        self.MUNIelementName = nil;
    }
    
    
}


- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    if(parser == self.BARTparser) {
        self.BARTisParsing = NO;
    } else if (parser == self.MUNIparser) {
        self.MUNIisParsing = NO;
    }
    
    //both are done parsing, update the table view
    if(!self.BARTisParsing && !self.MUNIisParsing){
        
        self.arrivals = self.nextArrivals;
        
        // sort that shit!
        //    NSSortDescriptor *timeDescriptor =
        //    [[NSSortDescriptor alloc] initWithKey:@"minutesUntilArrival"
        //                                ascending:YES
        //                                 selector:@selector(localizedCompare:)];
        
        //    [self.arrivals sortUsingDescriptors:@[timeDescriptor]];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"minutesUntilArrival"
                                            ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.arrivals = [self.arrivals sortedArrayUsingDescriptors:sortDescriptors];
        
        
        [self.tableView reloadData];
    }

}

#pragma mark - Utilities
-(NSNumber *)stringToInt:(NSString *)inputString {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber *outputString = [numberFormatter numberFromString:inputString];
    return outputString;
}

@end
