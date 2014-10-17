//
//  BGMapViewDelegate.m
//  TiClusteredMapKit
//
//  Created by Bruno Guidolim on 10/14/14.
//
//

#import "BGMapViewDelegate.h"
#import "BGAnnotation.h"
#import "KPAnnotation.h"
#import "TiViewProxy.h"
#import "TiBase.h"

@implementation BGMapViewDelegate

#pragma mark - MapView Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *clusterAnnotation = (KPAnnotation *)annotation;
        
        if ([clusterAnnotation isCluster]) {
            MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
            
            if (pinView == nil) {
                pinView = [[MKPinAnnotationView alloc] initWithAnnotation:clusterAnnotation reuseIdentifier:@"cluster"];
            }
            
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.canShowCallout = YES;
            
            return pinView;
        } else {
            BGAnnotation *bgAnnonation = [[clusterAnnotation.annotations allObjects] objectAtIndex:0];
            clusterAnnotation.title = bgAnnonation.title;
            clusterAnnotation.subtitle = bgAnnonation.subtitle;
            
            if ([bgAnnonation.userInfo objectForKey:@"image"]) {
                //Image
                MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
                if (annotationView == nil) {
                    annotationView = [[MKAnnotationView alloc] initWithAnnotation:bgAnnonation reuseIdentifier:@"pin"];
                }
                
                TiProxy *proxy = [bgAnnonation.userInfo objectForKey:@"proxy"];
                UIImage *image = [TiUtils image:[bgAnnonation.userInfo objectForKey:@"image"] proxy:proxy];
                annotationView.image = image;
                
                if ([bgAnnonation.userInfo objectForKey:@"centerOffset"]) {
                    CGPoint centerOffset = [TiUtils pointValue:[bgAnnonation.userInfo objectForKey:@"centerOffset"]];
                    annotationView.centerOffset = centerOffset;
                }
                
                annotationView.canShowCallout = [TiUtils boolValue:[bgAnnonation.userInfo objectForKey:@"canShowCallout"]];
                annotationView.draggable = [TiUtils boolValue:[bgAnnonation.userInfo objectForKey:@"draggable"]];
                
                return annotationView;
                
            } else {
                //Default Pin
                MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
                if (pinView == nil) {
                    pinView = [[MKPinAnnotationView alloc] initWithAnnotation:bgAnnonation reuseIdentifier:@"pin"];
                }
            
                if ([bgAnnonation.userInfo objectForKey:@"pincolor"]) {
                    switch ([[bgAnnonation.userInfo objectForKey:@"pincolor"] integerValue]) {
                        case 0:
                            pinView.pinColor = MKPinAnnotationColorRed;
                            break;
                            
                        case 1:
                            pinView.pinColor = MKPinAnnotationColorGreen;
                            break;
                            
                        case 2:
                            pinView.pinColor = MKPinAnnotationColorPurple;
                            break;
                            
                        default:
                            break;
                    }
                } else {
                    pinView.pinColor = MKPinAnnotationColorRed;
                }

                pinView.canShowCallout = [TiUtils boolValue:[bgAnnonation.userInfo objectForKey:@"canShowCallout"]];
                pinView.draggable = [TiUtils boolValue:[bgAnnonation.userInfo objectForKey:@"draggable"]];
                
                return pinView;
            }
        }
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.clusteringController refresh:YES];
}

@end
