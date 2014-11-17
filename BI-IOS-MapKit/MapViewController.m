//
//  MapViewController.m
//  BI-IOS-MapKit
//
//  Created by Dominik Vesely on 10/11/14.
//  Copyright (c) 2014 Ackee s.r.o. All rights reserved.
//



#import "MapViewController.h"
#import <PXAPI.h>
#import "CollectionViewController.h"



@interface MapViewController ()
@property (nonatomic,strong) MKMapView* mapView;
@property (nonatomic,strong) CLLocationManager* manager;
@property (nonatomic,strong) MKPointAnnotation* annotation;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [[CLLocationManager alloc] init];
    [self.manager requestWhenInUseAuthorization];
    [self.manager requestAlwaysAuthorization];

    _manager.delegate            = self;
    _manager.distanceFilter      = kCLDistanceFilterNone;
    _manager.desiredAccuracy     = kCLLocationAccuracyBest;
    [self.manager startUpdatingLocation];
  
    _mapView = [[MKMapView alloc]
               initWithFrame:self.view.bounds
               ];
    _mapView.showsUserLocation = YES;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(search:)];
    
}

- (void) search:(id) sender {
    [PXRequest requestForSearchGeo:[NSString stringWithFormat:@"%f,%f,20km",_annotation.coordinate.latitude,_annotation.coordinate.longitude] page:1 resultsPerPage:60 photoSizes:PXPhotoModelSizeThumbnail completion:^(NSDictionary *results, NSError *error) {
        CollectionViewController * coll = [CollectionViewController new];
        coll.data = results[@"photos"];
        [self.navigationController pushViewController:coll animated:YES];

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [mapView setRegion:region animated:YES];
    
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
    } else {
        pin.annotation = annotation;
    }
    pin.animatesDrop = YES;
    pin.draggable = YES;
    pin.canShowCallout = YES;
    pin.leftCalloutAccessoryView = [UISwitch new];
    
    return pin;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"tapped");
    
    
}
//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view



- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        CLGeocoder *ceo = [[CLGeocoder alloc]init];
        CLLocation * loc = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        [ceo reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            self.title = placemark.locality;
        }];

    }
}

- (void)viewDidAppear:(BOOL)animated {
    MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
    self.annotation = annotation;
    annotation.coordinate = self.mapView.centerCoordinate;
    annotation.title = @"Moje Posuvná anotace";
    [self.mapView addAnnotation:annotation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *loc = [locations lastObject];
    
   
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
