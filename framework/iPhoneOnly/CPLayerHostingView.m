
#import "CPLayerHostingView.h"
#import "CPLayer.h"

/**	@brief A container view for displaying a CPLayer.
 **/
@implementation CPLayerHostingView

/**	@property hostedLayer
 *	@brief The CPLayer hosted inside this view.
 **/
@synthesize hostedLayer;

/**	@property collapsesLayers
 *	@brief Whether view draws all graph layers into a single layer.
 *  Collapsing layers may improve performance in some cases.
 **/
@synthesize collapsesLayers;

+(Class)layerClass
{
	return [CALayer class];
}

-(void)commonInit
{
    hostedLayer = nil;
    collapsesLayers = NO;

    self.backgroundColor = [UIColor clearColor];	
    
    // This undoes the normal coordinate space inversion that UIViews apply to their layers
    self.layer.sublayerTransform = CATransform3DMakeScale(1.0, -1.0, 1.0);	
    
    // Register for pinches
    Class pinchClass = NSClassFromString(@"UIPinchGestureRecognizer");
    if ( pinchClass ) {
        id pinchRecognizer = [[pinchClass alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        self.gestureRecognizers = [NSArray arrayWithObjects:pinchRecognizer, nil];
        [pinchRecognizer release];
    }
}

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		[self commonInit];
    }
    return self;
}

// On the iPhone, the init method is not called when loading from a XIB
-(void)awakeFromNib
{
    [self commonInit];
}

-(void)dealloc {
	[hostedLayer release];
    [super dealloc];
}

#pragma mark -
#pragma mark Touch handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Ignore pinch or other multitouch gestures
	if ([[event allTouches] count] > 1) {
		return;		
	}
	
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
	if (!collapsesLayers) {
		pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:hostedLayer];
	} else {
		pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
	}
	[hostedLayer pointingDeviceDownEvent:event atPoint:pointOfTouch];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
	if (!collapsesLayers) {
		pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:hostedLayer];
	} else {
		pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
	}
	[hostedLayer pointingDeviceDraggedEvent:event atPoint:pointOfTouch];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];
	if (!collapsesLayers) {
		pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:hostedLayer];
	} else {
		pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
	}
	[hostedLayer pointingDeviceUpEvent:event atPoint:pointOfTouch];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[hostedLayer pointingDeviceCancelledEvent:event];
}

#pragma mark -
#pragma mark Gestures

-(void)handlePinchGesture:(id)pinchRecognizer 
{
    [pinchRecognizer setScale:1.0f];
}

#pragma mark -
#pragma mark Drawing

-(void)drawRect:(CGRect)rect
{
    if ( !collapsesLayers ) return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    hostedLayer.frame = self.bounds;
    [hostedLayer layoutAndRenderInContext:context];
}

#pragma mark -
#pragma mark Accessors

-(void)setHostedLayer:(CPLayer *)newLayer
{
	if (newLayer == hostedLayer) {
		return;
	}
	
	[hostedLayer removeFromSuperlayer];
	[hostedLayer release];
	hostedLayer = [newLayer retain];
	if ( !collapsesLayers ) {
    	hostedLayer.frame = self.layer.bounds;
        [self.layer addSublayer:hostedLayer];
    }
    else {
        [self setNeedsDisplay];
    }

}

-(void)setCollapsesLayers:(BOOL)yn
{
    if ( yn != collapsesLayers ) {
        collapsesLayers = yn;
        if ( !collapsesLayers ) 
        	[self.layer addSublayer:hostedLayer];
        else {
            [hostedLayer removeFromSuperlayer];
            [self setNeedsDisplay];
        }
    }
}

-(void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    if ( !collapsesLayers ) hostedLayer.frame = self.bounds;
}

@end
