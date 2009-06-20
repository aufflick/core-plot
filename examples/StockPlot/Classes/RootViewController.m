//
//  RootViewController.m
//  StockPlot
//
//  Created by Jonathan Saggau on 6/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RootViewController.h"
#import "APYahooDataPuller.h"

@interface RootViewController ()

@property(nonatomic, retain)APYahooDataPullerGraph *graph;

@end


@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    stocks = [[NSMutableArray alloc] initWithCapacity:4];
    symbols = [[NSMutableArray alloc] initWithCapacity:4];
    [self addSymbol:@"AAPL"];
    [self addSymbol:@"GOOG"];
    [self addSymbol:@"YHOO"];
    [self addSymbol:@"MSFT"];
    [self addSymbol:@"^DJI"];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationItem] setTitle:@"Stocks"];
    //the graph will set itself as delegate of the dataPuller when we push it, so we need to reset this.
    for (APYahooDataPuller *dp in stocks) {
        [dp setDelegate:self];
    }
}


- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
    [stocks release]; stocks = nil;
    [symbols release]; symbols = nil;
    [graph release]; graph = nil;
}


#pragma mark Table view methods

-(void)inspectStock:(APYahooDataPuller *)aStock
{
    if(nil == graph)
    {
        APYahooDataPullerGraph *aGraph = [[APYahooDataPullerGraph alloc] initWithNibName:@"APYahooDataPullerGraph" bundle:nil];
        self.graph = aGraph;
        [aGraph release];
    }
    [self.graph setDataPuller:aStock];
    [self.navigationController pushViewController:self.graph animated:YES];
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    APYahooDataPuller *dp = [stocks objectAtIndex:indexPath.row];
    [self inspectStock:dp];
    // Navigation logic may go here -- for example, create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController animated:YES];
    // [anotherViewController release];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [symbols count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UITableViewCellStyleSubtitle";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSUInteger row = indexPath.row;
    APYahooDataPuller *dp = [stocks objectAtIndex:row];
    
	[[cell textLabel] setText:[dp symbol]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    NSString *startString = @"(NA)";
    if([dp startDate])
        startString = [df stringFromDate:[dp startDate]];
    
    NSString *endString = @"(NA)";
    if ([dp endDate]) {
        endString = [df stringFromDate:[dp endDate]];
    }
    [df release];
    
    NSString *overallLow = @"(NA)";
    if (![[NSDecimalNumber notANumber] isEqual:[dp overallLow]]) {
        overallLow = [NSString stringWithFormat:@"%@", [dp overallLow]];
    }
    
    NSString *overallHigh = @"(NA)";
    if (![[NSDecimalNumber notANumber] isEqual:[dp overallHigh]]) {
        overallHigh = [NSString stringWithFormat:@"%@", [dp overallHigh]];
    }
    
    [[cell detailTextLabel] setText: [NSString stringWithFormat:@"%@ - %@; Low:%@ High:%@", startString, endString, overallLow, overallHigh]];
    return cell;
}


#pragma mark -
#pragma mark accessors

@synthesize graph;

- (NSMutableArray *)stocks
{
    //NSLog(@"in -symbols, returned symbols = %@", symbols);
    
    return stocks; 
}

- (NSMutableArray *)symbols
{
    //NSLog(@"in -symbols, returned symbols = %@", symbols);
    
    return symbols; 
}

-(void)dataPullerDidFinishFetch:(APYahooDataPuller *)dp;
{
    //NSLog(@"dataPullerDidFinishFetch:%@", dp);
    [self.tableView reloadData];
}

- (void)addSymbol:(NSString *)aSymbol
{
    [[self symbols] addObject:aSymbol];
    NSTimeInterval secondsAgo = -timeIntervalForNumberOfWeeks(14.0f); //12 weeks ago
    NSDate *start = [NSDate dateWithTimeIntervalSinceNow:secondsAgo]; 
    NSDate *end = [NSDate date];
    
    APYahooDataPuller *dp = [[APYahooDataPuller alloc] initWithTargetSymbol:aSymbol targetStartDate:start targetEndDate:end];
    [[self stocks] addObject:dp];
    [dp setDelegate:self];
    [dp release];
    [[self tableView] reloadData]; //TODO: should reload whole thing
}

- (void)dealloc
{
    [symbols release];
    for (APYahooDataPuller *dp in stocks) {
        if (dp.delegate == self) {
            dp.delegate = nil;
        }
    }
    [stocks release];
    
    symbols = nil;
    stocks = nil;
    
    [super dealloc];
}


/*
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 */


/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

/*
 // Override to support row selection in the table view.
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
 // Navigation logic may go here -- for example, create and push another view controller.
 // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
 // [self.navigationController pushViewController:anotherViewController animated:YES];
 // [anotherViewController release];
 }
 */


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

@end

