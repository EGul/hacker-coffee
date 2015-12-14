//
//  ViewController.m
//  TiltApp
//
//  Created by Evan on 12/9/15.
//  Copyright © 2015 none. All rights reserved.
//

#import "ViewController.h"
#import "SelectView.h"
#import "SelectViewController.h"

#import "MainAPI.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Reachability.h"

#define TEMP_LAT 37.7833
#define TEMP_LNG -122.4167

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, MainAPIProtocol, SelectViewProtocol> {
    
    float DEVICE_WIDTH;
    float DEVICE_HEIGHT;
    
    NSMutableArray *dataSource;
    
    int maxCoffeeShop;
    MainAPI *mainAPI;
    
    NSMutableArray *setPoints;
    int currentSelected;
    SelectView *currentSelectView;
    
    Reachability *reach;
    
    float userLocationLat;
    float userLocationLng;
    
    CLLocationManager *locationManager;
    
    UIView *shadowView;
    UILabel *processLabel;
    
    UIView *locationView;
    UIView *refreshView;
    
    MKMapView *mainMapView;
    
}

-(float)getRadiusMeters;
-(void)getCoffeeShops;
-(void)setPoint:(NSDictionary *)dictionary;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DEVICE_WIDTH = [UIScreen mainScreen].bounds.size.width;
    DEVICE_HEIGHT = [UIScreen mainScreen].bounds.size.height;
    
    dataSource = [[NSMutableArray alloc]init];
    
    maxCoffeeShop = 0;
    
    mainAPI = [[MainAPI alloc]init];
    mainAPI.delegate = self;
    
    setPoints = [[NSMutableArray alloc]init];
    currentSelected = -1;
    currentSelectView = [[SelectView alloc]init];
    
    reach = [Reachability reachabilityWithHostName:@"https://github.com"];
    
    userLocationLat = TEMP_LAT;
    userLocationLng = TEMP_LNG;
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.topItem.title = @"Coffee";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    shadowView = [[UIView alloc]initWithFrame:self.view.frame];
    processLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, DEVICE_WIDTH, 100)];
    
    mainMapView = [[MKMapView alloc]init];
    mainMapView.frame = self.view.frame;
    
    locationView = [[UIView alloc]init];
    locationView.frame = CGRectMake(DEVICE_WIDTH - 50 - 10,
                                    DEVICE_HEIGHT - (50 * 2) - (10 * 2),
                                    50, 50);
    UILabel *locationLabel = [[UILabel alloc]init];
    locationLabel.frame = CGRectMake(0, 0,
                                    locationView.frame.size.width,
                                    locationView.frame.size.height);
    
    refreshView = [[UIView alloc]init];
    refreshView.frame = CGRectMake(DEVICE_WIDTH - 50 - 10, DEVICE_HEIGHT - 50 - 10, 50, 50);
    
    UILabel *refreshLabel = [[UILabel alloc]init];
    refreshLabel.frame = CGRectMake(0, 0,
                                   refreshView.frame.size.width,
                                    refreshView.frame.size.height);
    
    shadowView.backgroundColor = [UIColor colorWithRed:50/255.0f green:50/255.0f blue:50/255.0f alpha:0.75];
    
    processLabel.textAlignment = NSTextAlignmentCenter;
    processLabel.text = @"0 : 0";
    processLabel.font = [UIFont systemFontOfSize:25];
    processLabel.textColor = [UIColor whiteColor];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(TEMP_LAT, TEMP_LNG);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.25, 0.25);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    mainMapView.delegate = self;
    mainMapView.showsUserLocation = true;
    [mainMapView setRegion:region];
    
    locationView.layer.cornerRadius = 50 / 2;
    locationView.layer.borderWidth = 5;
    locationView.layer.borderColor = [UIColor whiteColor].CGColor;;
    locationView.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.25];
    locationLabel.textAlignment = NSTextAlignmentCenter;
    locationLabel.text = @"+";
    locationLabel.textColor = [UIColor whiteColor];
    
    refreshView.layer.cornerRadius = 50 / 2;
    refreshView.layer.borderWidth = 5;
    refreshView.layer.borderColor = [UIColor blackColor].CGColor;
    refreshView.backgroundColor = [UIColor colorWithRed:50/255.0f green:50/255.0f blue:50/255.0f alpha:0.25];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.text = @"R";
    
    [locationView addSubview:locationLabel];
    [refreshView addSubview:refreshLabel];
    [self.view addSubview:mainMapView];
    [self.view addSubview:locationView];
    [self.view addSubview:refreshView];
    
    if (reach.isReachable) {
        [self getCoffeeShops];
    }
    else {
        NSString *alertMessage = @"Turn Off Airplane Mode or\nUse Wifi to Access Data";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:false completion:nil];
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestAlwaysAuthorization];
    }
    
}

-(float)getRadiusMeters {
    
    MKMapRect mRect = mainMapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    CLLocationDistance distance = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    return distance;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *loc = [locations lastObject];
    userLocationLat = loc.coordinate.latitude;
    userLocationLng = loc.coordinate.longitude;
}

-(void)mainAPIDidThrowError:(NSError *)error {
    NSLog(@"error: %@", error);
}

-(void)mainAPIWillGetCoffeeShopsWithCount:(int)count {
    
    if (count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [shadowView removeFromSuperview];
            [processLabel removeFromSuperview];
        });
    }
    
    maxCoffeeShop = count;
    
}

-(void)mainAPIDidGetCoffeeShop:(NSDictionary *)coffeeShop {
    
    [dataSource addObject:coffeeShop];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        processLabel.text = [NSString stringWithFormat:@"%d : %d", (int)dataSource.count, maxCoffeeShop];
    });
    
    [self setPoint:coffeeShop];
    
    if (dataSource.count == maxCoffeeShop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [shadowView removeFromSuperview];
            [processLabel removeFromSuperview];
        });
    }
    
}

-(void)getCoffeeShops {
    
    [dataSource removeAllObjects];
    processLabel.text = @"0 : 0";
    
    while (setPoints.count) {
        MKPointAnnotation *pointAnnotation = [setPoints objectAtIndex:0];
        [setPoints removeObjectAtIndex:0];
        [mainMapView removeAnnotation:pointAnnotation];
    }
    
    [self.view addSubview:shadowView];
    [self.view addSubview:processLabel];
    
    float lat = mainMapView.centerCoordinate.latitude;
    float lng = mainMapView.centerCoordinate.longitude;
    float rad = [self getRadiusMeters];
    
    [mainAPI getCoffeeShops:lat lng:lng radius:rad];
    
}

-(void)setPoint:(NSDictionary *)dictionary {
    
    NSDictionary *item = [dictionary valueForKey:@"location"];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.coordinate = CLLocationCoordinate2DMake([[item valueForKey:@"lat"]floatValue], [[item valueForKey:@"lng"]floatValue]);
    point.title = [item valueForKey:@"name"];
    
    [setPoints addObject:point];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mainMapView addAnnotation:point];
    });
    
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if ([self.view.subviews containsObject:currentSelectView]) {
        [currentSelectView removeFromSuperview];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    int index = (int)[setPoints indexOfObject:view.annotation];
    
    if (index == -1) {
        return;
    }
    
    ((MKPinAnnotationView *)view).pinTintColor = [UIColor greenColor];
    
    NSDictionary *data = [dataSource objectAtIndex:[setPoints indexOfObject:view.annotation]];
    
    SelectView *tempSelectView = [[SelectView alloc]init];
    tempSelectView.frame = CGRectMake(0, DEVICE_HEIGHT, DEVICE_WIDTH, 100);
    tempSelectView.delegate = self;
    tempSelectView.dataSource = data;
    [tempSelectView generate];
    
    [self.view addSubview:tempSelectView];
    
    [UIView animateWithDuration:0.25 animations:^{
        tempSelectView.frame = CGRectMake(tempSelectView.frame.origin.x,
                                      DEVICE_HEIGHT - tempSelectView.frame.size.height,
                                      tempSelectView.frame.size.width,
                                      tempSelectView.frame.size.height);
    } completion:nil];
    
    currentSelected = (int)[setPoints indexOfObject:view.annotation];
    currentSelectView = tempSelectView;
    
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    int index = (int)[setPoints indexOfObject:view.annotation];
    
    if (index == -1) {
        return;
    }
    
    if (((NSMutableArray *)[[dataSource objectAtIndex:currentSelected]valueForKey:@"tips"]).count > 0) {
        ((MKPinAnnotationView *)view).pinTintColor = [UIColor redColor];
    }
    else {
        ((MKPinAnnotationView *)view).pinTintColor = [UIColor blackColor];
    }
    
    [currentSelectView removeFromSuperview];
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    int index = (int)[setPoints indexOfObject:annotation];
    
    if (index == -1) {
        return nil;
    }
    
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc]init];
    
    if (((NSArray *)[[dataSource objectAtIndex:index]valueForKey:@"tips"]).count > 0) {
        view.pinTintColor = [UIColor redColor];
    }
    else {
        view.pinTintColor = [UIColor blackColor];
    }
    
    return view;
}

-(void)selectViewDidSelect {
    SelectViewController *selectViewController = [[SelectViewController alloc]init];
    selectViewController.dataSource = [dataSource objectAtIndex:currentSelected];
    selectViewController.title = [[dataSource objectAtIndex:currentSelected]valueForKey:@"name"];
    [self.navigationController pushViewController:selectViewController animated:true];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    locationView.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.25];
    refreshView.backgroundColor = [UIColor colorWithRed:50/255.0f green:50/255.0f blue:50/255.0f alpha:0.25];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (CGRectContainsPoint(locationView.frame, [[touches anyObject]locationInView:self.view])) {
        locationView.backgroundColor = [UIColor whiteColor];
    }
    
    if (CGRectContainsPoint(refreshView.frame, [[touches anyObject]locationInView:self.view])) {
        refreshView.backgroundColor = [UIColor blackColor];
    }
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    locationView.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.25];
    refreshView.backgroundColor = [UIColor colorWithRed:50/255.0f green:50/255.0f blue:50/255.0f alpha:0.25];
    
    if (CGRectContainsPoint(locationView.frame, [[touches anyObject]locationInView:self.view])) {
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [mainMapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocationLat, userLocationLng)];
        }
        else {
            NSString *alertMessage = @"Please enable Location Services in your device settings";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:false completion:nil];
        }
        
    }
    
    if (CGRectContainsPoint(refreshView.frame, [[touches anyObject]locationInView:self.view])) {
        
        if (reach.isReachable) {
            [self getCoffeeShops];
        }
        else {
            NSString *alertMessage = @"Turn Off Airplane Mode or\nUse Wifi to Access Data";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:false completion:nil];
        }
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
