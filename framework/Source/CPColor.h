#import <Foundation/Foundation.h>

@interface CPColor : NSObject <NSCopying, NSCoding> {
    CGColorRef cgColor;
}

@property (nonatomic, readonly, assign) CGColorRef cgColor;

+(CPColor *)clearColor; 
+(CPColor *)whiteColor; 
+(CPColor *)blackColor; 
+(CPColor *)redColor;
+(CPColor *)blueColor;

+(CPColor *)colorWithCGColor:(CGColorRef)newCGColor;

-(id)initWithCGColor:(CGColorRef)cgColor;

@end
