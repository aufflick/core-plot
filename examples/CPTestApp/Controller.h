

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface Controller : NSArrayController <CPPlotDataSource> {
    IBOutlet NSView *hostView;
    CPXYGraph *graph;
}

-(IBAction)reloadDataSourcePlot:(id)sender;
-(NSUInteger)numberOfRecords;
-(NSDecimalNumber *)decimalNumberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;

@end
