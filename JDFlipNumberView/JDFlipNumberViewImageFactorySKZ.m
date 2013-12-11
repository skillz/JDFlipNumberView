//
//  JDFlipNumberViewImageFactory.m
//  FlipNumberViewExample
//
//  Created by Markus Emrich on 05.12.12.
//  Copyright (c) 2012 markusemrich. All rights reserved.
//

#import "JDFlipNumberViewImageFactorySKZ.h"

static JDFlipNumberViewImageFactorySKZ *sharedInstance;

@interface JDFlipNumberViewImageFactorySKZ ()
@property (nonatomic, strong) NSArray *topImages;
@property (nonatomic, strong) NSArray *bottomImages;
@property (nonatomic, strong) NSString *imageBundle;
- (void)setup;
@end

@implementation JDFlipNumberViewImageFactorySKZ

+ (JDFlipNumberViewImageFactorySKZ*)sharedInstance;
{
    if (sharedInstance != nil) {
        return sharedInstance;
    }
    
    return [[self alloc] init];
}

- (id)init
{
    @synchronized(self)
    {
        if (sharedInstance != nil) {
            return sharedInstance;
        }
        
        self = [super init];
        if (self) {
            sharedInstance = self;
            self.imageBundle = @"JDFlipNumberView";
            [self setup];
        }
        return self;
    }
}

- (void)setup;
{
    // create default images
    [self generateImagesFromBundleNamed:self.imageBundle];
    
    // register for memory warnings
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

+ (id)allocWithZone:(NSZone *)zone;
{
    if (sharedInstance != nil) {
        return sharedInstance;
    }
    return [super allocWithZone:zone];
}

#pragma mark -
#pragma mark getter

- (NSArray *)topImages;
{
    @synchronized(self)
    {
        if (_topImages.count == 0) {
            [self generateImagesFromBundleNamed:self.imageBundle];
        }
        
        return _topImages;
    }
}

- (NSArray *)bottomImages;
{
    @synchronized(self)
    {
        if (_bottomImages.count == 0) {
            [self generateImagesFromBundleNamed:self.imageBundle];
        }
        
        return _bottomImages;
    }
}

- (CGSize)imageSize
{
    return ((UIImage*)self.topImages[0]).size;
}

#pragma mark -
#pragma mark image generation
- (void)generateImagesFromBundleNamed:(NSString*)bundleName;
{
    self.imageBundle = bundleName;
    // create image array
	NSMutableArray* topImages = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray* bottomImages = [NSMutableArray arrayWithCapacity:10];
	
	// create bottom and top images
    for (NSInteger j=0; j<10; j++) {
        for (int i=0; i<2; i++) {
            NSString *imageName = [NSString stringWithFormat: @"vs_timer_num_%d", j];
			UIImage *sourceImage = [UIImage imageFromResource:imageName];
            
			CGSize size		= CGSizeMake(sourceImage.size.width, sourceImage.size.height/2);
			CGFloat yPoint	= (i==0) ? 0 : -size.height;
            
            // draw half of image and create new image
			UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
			[sourceImage drawAtPoint:CGPointMake(0,yPoint)];
			UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
            
            // save image
            if (i==0) {
                [topImages addObject:image];
            } else {
                [bottomImages addObject:image];
            }
		}
	}
	
    // save images
	self.topImages    = [NSArray arrayWithArray:topImages];
	self.bottomImages = [NSArray arrayWithArray:bottomImages];
}

#pragma mark -
#pragma mark memory

// clear memory
- (void)didReceiveMemoryWarning:(NSNotification*)notification;
{
    self.topImages = @[];
    self.bottomImages = @[];
}

@end
