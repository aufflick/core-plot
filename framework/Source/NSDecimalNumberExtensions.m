#import "NSDecimalNumberExtensions.h"

@implementation NSDecimalNumber(CPTExtensions)

/**	@brief Returns the approximate value of the receiver as a CGFloat.
 *	@return The approximate value of the receiver as a CGFloat.
 **/
-(CGFloat)floatValue 
{
    return (CGFloat)[self doubleValue];
}

/**	@brief Returns the value of the receiver as an NSDecimalNumber.
 *	@return The value of the receiver as an NSDecimalNumber.
 **/
-(NSDecimalNumber *)decimalNumber
{
    return [[self copy] autorelease];
}

@end
