/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiUIView.h"
#import <MapKit/MapKit.h>
#import "BGMapViewDelegate.h"

@interface ComGuidolimTiclusteredmapkitView : TiUIView {
    MKMapView *mapView;
    MKCoordinateRegion region;
    BOOL regionFits;
    BOOL animate;
    BGMapViewDelegate *mapViewDelegate;
}

- (void)setAnnotations:(id)args;

@end
