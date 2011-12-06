#import "CPTPlotDocument.h"
#import "NSString+ParseCSV.h"

@implementation CPTPlotDocument

//#define USE_NSDECIMAL

-(id)init
{
	self = [super init];
	if ( self ) {
		dataPoints = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[graph release];
	[dataPoints release];
	[super dealloc];
}

-(NSString *)windowNibName
{
	return @"CPTPlotDocument";
}

-(void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
	// Create graph from theme
	graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
	[graph applyTheme:theme];
	graphView.hostedGraph = graph;

	graph.paddingLeft	= 0.0;
	graph.paddingTop	= 0.0;
	graph.paddingRight	= 0.0;
	graph.paddingBottom = 0.0;

	graph.plotAreaFrame.paddingLeft	  = 55.0;
	graph.plotAreaFrame.paddingTop	  = 40.0;
	graph.plotAreaFrame.paddingRight  = 40.0;
	graph.plotAreaFrame.paddingBottom = 35.0;

	graph.plotAreaFrame.plotArea.fill = graph.plotAreaFrame.fill;
	graph.plotAreaFrame.fill		  = nil;

	graph.plotAreaFrame.borderLineStyle = nil;
	graph.plotAreaFrame.cornerRadius	= 0.0;

	// Setup plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis)
													length:CPTDecimalFromDouble(ceil( (maximumValueForXAxis - minimumValueForXAxis) / majorIntervalLengthForX ) * majorIntervalLengthForX)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis)
													length:CPTDecimalFromDouble(ceil( (maximumValueForYAxis - minimumValueForYAxis) / majorIntervalLengthForY ) * majorIntervalLengthForY)];

	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;

	CPTXYAxis *x = axisSet.xAxis;
	x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(minimumValueForYAxis);
	x.minorTicksPerInterval		  = 9;
	x.majorIntervalLength		  = CPTDecimalFromDouble(majorIntervalLengthForX);
	x.labelOffset				  = 5.0;

	CPTXYAxis *y = axisSet.yAxis;
	y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(minimumValueForXAxis);
	y.minorTicksPerInterval		  = 9;
	y.majorIntervalLength		  = CPTDecimalFromDouble(majorIntervalLengthForY);
	y.labelOffset				  = 5.0;

	// Create the main plot for the delimited data
	CPTScatterPlot *dataSourceLinePlot = [[(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
	dataSourceLinePlot.identifier = @"Data Source Plot";

	CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
	lineStyle.lineWidth				 = 1.0;
	lineStyle.lineColor				 = [CPTColor whiteColor];
	dataSourceLinePlot.dataLineStyle = lineStyle;

	dataSourceLinePlot.dataSource = self;
	[graph addPlot:dataSourceLinePlot];

	[graph reloadData];
}

#pragma mark -
#pragma mark Data loading methods

-(NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	// Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

	// You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

	// For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

	if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

-(BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	if ( [typeName isEqualToString:@"CSVDocument"] ) {
		minimumValueForXAxis = MAXFLOAT;
		maximumValueForXAxis = -MAXFLOAT;

		minimumValueForYAxis = MAXFLOAT;
		maximumValueForYAxis = -MAXFLOAT;

		NSString *fileContents = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		// Parse CSV
		NSUInteger length	 = [fileContents length];
		NSUInteger lineStart = 0, lineEnd = 0, contentsEnd = 0;
		NSRange currentRange;

		// Read headers from the first line of the file
		[fileContents getParagraphStart:&lineStart end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
//		currentRange = NSMakeRange(lineStart, contentsEnd - lineStart);
//		NSArray *columnHeaders = [[fileContents substringWithRange:currentRange] arrayByParsingCSVLine];
//		NSLog([columnHeaders objectAtIndex:0]);

		while ( lineEnd < length ) {
			[fileContents getParagraphStart:&lineStart end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
			currentRange = NSMakeRange(lineStart, contentsEnd - lineStart);
			NSArray *columnValues = [[fileContents substringWithRange:currentRange] arrayByParsingCSVLine];

			double xValue = [[columnValues objectAtIndex:0] doubleValue];
			double yValue = [[columnValues objectAtIndex:1] doubleValue];
			if ( xValue < minimumValueForXAxis ) {
				minimumValueForXAxis = xValue;
			}
			if ( xValue > maximumValueForXAxis ) {
				maximumValueForXAxis = xValue;
			}
			if ( yValue < minimumValueForYAxis ) {
				minimumValueForYAxis = yValue;
			}
			if ( yValue > maximumValueForYAxis ) {
				maximumValueForYAxis = yValue;
			}

#ifdef USE_NSDECIMAL
			[dataPoints addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSDecimalNumber decimalNumberWithString:[columnValues objectAtIndex:0]], @"x", [NSDecimalNumber decimalNumberWithString:[columnValues objectAtIndex:1]], @"y", nil]];
#else
			[dataPoints addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:xValue], @"x", [NSNumber numberWithDouble:yValue], @"y", nil]];
#endif
			// Create a dictionary of the items, keyed to the header titles
//			NSDictionary *keyedImportedItems = [[NSDictionary alloc] initWithObjects:columnValues forKeys:columnHeaders];
			// Process this
		}

		majorIntervalLengthForX = (maximumValueForXAxis - minimumValueForXAxis) / 5.0;
		if ( majorIntervalLengthForX > 0.0 ) {
			majorIntervalLengthForX = pow( 10.0, ceil( log10(majorIntervalLengthForX) ) );
		}

		majorIntervalLengthForY = (maximumValueForYAxis - minimumValueForYAxis) / 10.0;
		if ( majorIntervalLengthForY > 0.0 ) {
			majorIntervalLengthForY = pow( 10.0, ceil( log10(majorIntervalLengthForY) ) );
		}

		minimumValueForXAxis = floor(minimumValueForXAxis / majorIntervalLengthForX) * majorIntervalLengthForX;
		minimumValueForYAxis = floor(minimumValueForYAxis / majorIntervalLengthForY) * majorIntervalLengthForY;

		[fileContents release];
	}

	if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return YES;
}

#pragma mark -
#pragma mark PDF / image export

-(IBAction)exportToPDF:(id)sender;
{
	NSSavePanel *pdfSavingDialog = [NSSavePanel savePanel];
	[pdfSavingDialog setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];

	if ( [pdfSavingDialog runModal] == NSOKButton ) {
		NSData *dataForPDF = [graph dataForPDFRepresentationOfLayer];
		[dataForPDF writeToURL:[pdfSavingDialog URL] atomically:NO];
	}
}

-(IBAction)exportToPNG:(id)sender;
{
	NSSavePanel *pngSavingDialog = [NSSavePanel savePanel];
	[pngSavingDialog setAllowedFileTypes:[NSArray arrayWithObject:@"png"]];

	if ( [pngSavingDialog runModal] == NSOKButton ) {
		NSImage *image			  = [graph imageOfLayer];
		NSData *tiffData		  = [image TIFFRepresentation];
		NSBitmapImageRep *tiffRep = [NSBitmapImageRep imageRepWithData:tiffData];
		NSData *pngData			  = [tiffRep representationUsingType:NSPNGFileType properties:nil];
		[pngData writeToURL:[pngSavingDialog URL] atomically:NO];
	}
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	return [dataPoints count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
	NSNumber *num = [[dataPoints objectAtIndex:index] valueForKey:key];

	return num;
}

@end
