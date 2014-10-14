/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ComGuidolimTiclusteredmapkitView.h"

@implementation ComGuidolimTiclusteredmapkitView

- (void)createMapView {
    if (mapView == nil) {
        mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mapView.delegate = self;
        
        [self addSubview:mapView];
    }
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds {
    NSLog(@"[VIEW LIFECYCLE EVENT] frameSizeChanged");
    if (mapView == nil) {
        [self createMapView];
    }
    [TiUtils setView:mapView positionRect:bounds];
}

@end
