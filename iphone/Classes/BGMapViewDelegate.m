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
#import "TiBase.h"
#import "TiButtonUtil.h"
#import "TiViewProxy.h"

#define LEFT_BUTTON  1
#define RIGHT_BUTTON 2

@implementation BGMapViewDelegate

#pragma mark - Custom methods
- (void)setAnnotationProperties:(MKAnnotationView *)annotationView dictionaty:(NSDictionary *)dictionary {
    annotationView.canShowCallout = [TiUtils boolValue:[dictionary objectForKey:@"canShowCallout"] def:YES];
    annotationView.draggable = [TiUtils boolValue:[dictionary objectForKey:@"draggable"]];
    
    if ([dictionary objectForKey:@"centerOffset"]) {
        CGPoint centerOffset = [TiUtils pointValue:[dictionary objectForKey:@"centerOffset"]];
        annotationView.centerOffset = centerOffset;
    }
    
    UIView *left = [self leftViewAccessoryForAnnotation:dictionary];
    UIView *right = [self rightViewAccessoryForAnnotation:dictionary];
    if (left != nil) {
        annotationView.leftCalloutAccessoryView = left;
    }
    
    if (right!=nil) {
        annotationView.rightCalloutAccessoryView = right;
    }
}

- (UIView*)leftViewAccessoryForAnnotation:(NSDictionary *)dict {
    TiViewProxy* viewProxy = [dict objectForKey:@"leftView"];
    if (viewProxy!=nil && [viewProxy isKindOfClass:[TiViewProxy class]]) {
        return [viewProxy view];
    } else {
        id button = [dict objectForKey:@"leftButton"];
        if (button!=nil) {
            return [self makeButton:button tag:LEFT_BUTTON annotation:dict];
        }
    }
    return nil;
}

- (UIView*)rightViewAccessoryForAnnotation:(NSDictionary *)dict  {
    TiViewProxy* viewProxy = [dict objectForKey:@"rightView"];
    if (viewProxy!=nil && [viewProxy isKindOfClass:[TiViewProxy class]]) {
        return [viewProxy view];
    } else {
        id button = [dict objectForKey:@"rightButton"];
        if (button!=nil) {
            return [self makeButton:button tag:RIGHT_BUTTON annotation:dict];
        }
    }
    return nil;
}

-(UIView*)makeButton:(id)button tag:(int)buttonTag annotation:(NSDictionary *)dict {
    UIView *button_view = nil;
    if ([button isKindOfClass:[NSNumber class]]) {
        // this is button type constant
        int type = [TiUtils intValue:button];
        button_view = [TiButtonUtil buttonWithType:type];
    } else {
        UIImage *image = [TiUtils image:[dict objectForKey:(buttonTag == LEFT_BUTTON?@"leftButton":@"rightButton")] proxy:self.mapViewProxy];
        if (image!=nil) {
            CGSize size = [image size];
            UIButton *bview = [UIButton buttonWithType:UIButtonTypeCustom];
            [TiUtils setView:bview positionRect:CGRectMake(0,0,size.width,size.height)];
            bview.backgroundColor = [UIColor clearColor];
            [bview setImage:image forState:UIControlStateNormal];
            button_view = bview;
        }
    }
    if (button_view!=nil) {
        button_view.tag = buttonTag;
    }
    return button_view;
}

#pragma mark - MapView Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *clusterAnnotation = (KPAnnotation *)annotation;
        
        if ([clusterAnnotation isCluster]) {
            MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster-pin"];
            
            if (pinView == nil) {
                pinView = [[MKPinAnnotationView alloc] initWithAnnotation:clusterAnnotation reuseIdentifier:@"cluster-pin"];
            }
            
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.canShowCallout = YES;
            
            return pinView;
        } else {
            BGAnnotation *bgAnnonation = [[clusterAnnotation.annotations allObjects] objectAtIndex:0];
            clusterAnnotation.title = bgAnnonation.title;
            clusterAnnotation.subtitle = bgAnnonation.subtitle;
            
            if ([bgAnnonation.userInfo objectForKey:@"customView"]) {
                MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"customview-pin"];
                if (annotationView == nil) {
                    annotationView = [[MKAnnotationView alloc] initWithAnnotation:bgAnnonation reuseIdentifier:@"customview-pin"];
                }
                
                TiViewProxy *viewProxy = (TiViewProxy*)[bgAnnonation.userInfo objectForKey:@"customView"];
                UIView *customView = (UIView*)[viewProxy view];
                [customView setFrame:CGRectMake(0, 0, customView.frame.size.width, customView.frame.size.height)];
                
                annotationView.frame = customView.frame;
                [annotationView addSubview:customView];
                
                [self setAnnotationProperties:annotationView dictionaty:bgAnnonation.userInfo];
                
                return annotationView;
            
            } else if ([bgAnnonation.userInfo objectForKey:@"image"]) {
                //Image
                MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"image-pin"];
                if (annotationView == nil) {
                    annotationView = [[MKAnnotationView alloc] initWithAnnotation:bgAnnonation reuseIdentifier:@"image-pin"];
                }
                
                UIImage *image = [TiUtils image:[bgAnnonation.userInfo objectForKey:@"image"] proxy:self.mapViewProxy];
                annotationView.image = image;
                
                [self setAnnotationProperties:annotationView dictionaty:bgAnnonation.userInfo];

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

                [self setAnnotationProperties:pinView dictionaty:bgAnnonation.userInfo];
                
                return pinView;
            }
        }
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)aview calloutAccessoryControlTapped:(UIControl *)control {
    if ([aview.annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *annotation = (KPAnnotation *)aview.annotation;
        
        if (!annotation.isCluster) {
            MKPinAnnotationView *pinview = (MKPinAnnotationView*)aview;
            NSString * clickSource = @"unknown";
            
            if (aview.leftCalloutAccessoryView == control) {
                clickSource = @"leftButton";
            } else if (aview.rightCalloutAccessoryView == control) {
                clickSource = @"rightButton";
            }
            [self fireClickEvent:pinview source:clickSource];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.clusteringController refresh:YES];
}

#pragma mark Click handler
- (void)fireClickEvent:(MKAnnotationView *)pinview source:(NSString *)source{
    BGAnnotation *annotation = (BGAnnotation *)pinview.annotation;
    
    BOOL parentWants = [self.mapViewProxy _hasListeners:@"click"];
    if(!parentWants) {
        return;
    }
    
    NSNumber *indexNumber = [NSNumber numberWithInteger:pinview.tag];
    id clicksource = source ? source : (id)[NSNull null];
    
    NSDictionary * event = [NSDictionary dictionaryWithObjectsAndKeys:
                            clicksource,@"clicksource",
                            self.mapViewProxy,@"map",
                            indexNumber,@"index",
                            nil];
    
    if (parentWants){
        [self.mapViewProxy fireEvent:@"click" withObject:event];
    }

}

@end
