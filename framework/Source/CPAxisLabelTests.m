
#import "CPAxisLabelTests.h"
#import "CPAxisLabel.h"
#import "CPTextStyle.h"
#import "CPFill.h"
#import "CPBorderedLayer.h"
#import "CPColor.h"
#import "CPExceptions.h"

@implementation CPAxisLabelTests

-(void)testPositionRelativeToViewPointRaisesForInvalidDirection
{
    CPAxisLabel *label;
    
    @try {
        label = [[CPAxisLabel alloc] initWithText:@"CPAxisLabelTests-testPositionRelativeToViewPointRaisesForInvalidDirection" textStyle:[CPTextStyle textStyle]];
        
        STAssertThrowsSpecificNamed([label positionRelativeToViewPoint:CGPointZero forCoordinate:CPCoordinateX inDirection:INT_MAX], NSException, CPException, @"Should raise CPException for invalid direction (type CPSign)");
        
    }
    @finally {
        [label release];
    }
}

-(void)testPositionRelativeToViewPointPositionsForXCoordinate
{
    CPAxisLabel *label;
    CGFloat start = 100.0f;
    
    @try {
        label = [[CPAxisLabel alloc] initWithText:@"CPAxisLabelTests-testPositionRelativeToViewPointPositionsForXCoordinate" textStyle:[CPTextStyle textStyle]];
		CPLayer *contentLayer = label.contentLayer;
        label.offset = 20.0f;
        
        CGPoint viewPoint = CGPointMake(start, start);
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateX
                               inDirection:CPSignNone];
        
        STAssertEquals(contentLayer.position, CGPointMake(start-label.offset, start), @"Should add negative offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSMakePoint(start-label.offset, start)));
        STAssertEquals(contentLayer.anchorPoint, CGPointMake(1.0, 0.5), @"Should anchor at (1.0,0.5)");
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateX
                               inDirection:CPSignNegative];
        
        STAssertEquals(contentLayer.position, CGPointMake(start-label.offset, start), @"Should add negative offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSMakePoint(start-label.offset, start)));
        STAssertEquals(contentLayer.anchorPoint, CGPointMake(1.0, 0.5), @"Should anchor at (1.0,0.5)");
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateX
                               inDirection:CPSignPositive];
        
        STAssertEquals(contentLayer.position, CGPointMake(start+label.offset, start), @"Should add positive offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSMakePoint(start+label.offset, start)));
        STAssertEquals(contentLayer.anchorPoint, CGPointMake(0., 0.5), @"Should anchor at (0,0.5)");
    }
    @finally {
        [label release];
    }
}

-(void)testPositionRelativeToViewPointPositionsForYCoordinate
{
    CPAxisLabel *label;
    CGFloat start = 100.0f;
    
    @try {
        label = [[CPAxisLabel alloc] initWithText:@"CPAxisLabelTests-testPositionRelativeToViewPointPositionsForYCoordinate" textStyle:[CPTextStyle textStyle]];
		CPLayer *contentLayer = label.contentLayer;
		label.offset = 20.0f;
        
        CGPoint viewPoint = CGPointMake(start,start);
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateY
                               inDirection:CPSignNone];
		
        STAssertEquals(contentLayer.position, CGPointMake(start, start-label.offset), @"Should add negative offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSMakePoint(start, start-label.offset)));
        STAssertEquals(contentLayer.anchorPoint, CGPointMake(0.5, 1.0), @"Should anchor at (0.5,1.0)");
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateY
                               inDirection:CPSignNegative];
        
        STAssertEquals(contentLayer.position, CGPointMake(start, start-label.offset), @"Should add negative offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSMakePoint(start, start-label.offset)));
        STAssertEquals(contentLayer.anchorPoint, CGPointMake(0.5, 1.0), @"Should anchor at (0.5,1.0)");
        
        contentLayer.anchorPoint = CGPointZero;
        contentLayer.position = CGPointZero;
        [label positionRelativeToViewPoint:viewPoint
                             forCoordinate:CPCoordinateY
                               inDirection:CPSignPositive];
        
        STAssertEquals(contentLayer.position, CGPointMake(start, start+label.offset), @"Should add positive offset, %@ != %@", NSStringFromPoint(NSPointFromCGPoint(contentLayer.position)), NSStringFromPoint(NSMakePoint(start, start+label.offset)));
        STAssertEquals(contentLayer.anchorPoint, CGPointMake(0.5, 0.), @"Should anchor at (0.5,0)");
    }
    @finally {
        [label release];
    }
}
@end
