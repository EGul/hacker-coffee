//
//  SelectViewController.m
//  TiltApp
//
//  Created by Evan on 12/9/15.
//  Copyright © 2015 none. All rights reserved.
//

#import "SelectViewController.h"
#import "MainAPI.h"

#import "TipsView.h"

#import "DateTools.h"

@interface SelectViewController () {
    
}

@end

@implementation SelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    float DEVICE_WIDTH = [UIScreen mainScreen].bounds.size.width;
    float DEVICE_HEIGHT = [UIScreen mainScreen].bounds.size.height;
    
    float NAV_HEIGHT = self.navigationController.navigationBar.frame.size.height;
    
    MainAPI *mainAPI = [[MainAPI alloc]init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = CGRectMake(0,
                                 ((self.view.frame.size.height / 3) / 2) - (DEVICE_WIDTH / 2),
                                 DEVICE_WIDTH, DEVICE_WIDTH);
    
    UILabel *hoursLabel = [[UILabel alloc]init];
    hoursLabel.frame = CGRectMake(0,
                                  DEVICE_HEIGHT / 3,
                                  DEVICE_WIDTH, 50);
    
    UILabel *openLabel = [[UILabel alloc]init];
    openLabel.frame = CGRectMake(0,
                                 hoursLabel.frame.origin.y + hoursLabel.frame.size.height,
                                 DEVICE_WIDTH,
                                 20);
    
    UILabel *addressLabel = [[UILabel alloc]init];
    addressLabel.frame = CGRectMake(0,
                                    openLabel.frame.origin.y + openLabel.frame.size.height,
                                    DEVICE_WIDTH,
                                    100);
    
    UIView *lineView = [[UIView alloc]init];
    lineView.frame = CGRectMake(4,
                                addressLabel.frame.origin.y + addressLabel.frame.size.height,
                                DEVICE_WIDTH - 8,
                                2);
    
    TipsView *tipsView = [[TipsView alloc]init];
    tipsView.frame = CGRectMake(0,
                                addressLabel.frame.origin.y + addressLabel.frame.size.height,
                                DEVICE_WIDTH,
                                DEVICE_HEIGHT - (addressLabel.frame.origin.y + addressLabel.frame.size.height));
    
    hoursLabel.textAlignment = NSTextAlignmentCenter;
    hoursLabel.font = [UIFont systemFontOfSize:20];
    hoursLabel.backgroundColor = [UIColor whiteColor];
    NSDictionary *hours = [self.dataSource valueForKey:@"hours"];
    hoursLabel.text = @"";
    if ([[hours valueForKey:@"isOpen"]boolValue] == true) {
        hoursLabel.text = [NSString stringWithFormat:@"%@ - %@", [hours valueForKey:@"open"], [hours valueForKey:@"close"]];
    }
    
    openLabel.font = [UIFont systemFontOfSize:20];
    openLabel.textAlignment = NSTextAlignmentCenter;
    openLabel.backgroundColor = [UIColor whiteColor];
    if ([[[self.dataSource valueForKey:@"hours"]valueForKey:@"isOpen"]boolValue] == true) {
        openLabel.text = @"Open";
        openLabel.textColor = [UIColor greenColor];
    }
    else {
        openLabel.text = @"Closed";
        openLabel.textColor = [UIColor redColor];
    }
    
    addressLabel.textAlignment = NSTextAlignmentCenter;
    addressLabel.numberOfLines = 10;
    addressLabel.text = [[[self.dataSource valueForKey:@"location"]valueForKey:@"formattedAddress"]componentsJoinedByString:@"\n"];
    addressLabel.backgroundColor = [UIColor whiteColor];
    
    lineView.backgroundColor = [UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1];
    
    tipsView.dataSource = [self.dataSource valueForKey:@"tips"];
    [tipsView generate];
    
    [self.view addSubview:imageView];
    [self.view addSubview:hoursLabel];
    [self.view addSubview:openLabel];
    [self.view addSubview:addressLabel];
    [self.view addSubview:tipsView];
    [self.view addSubview:lineView];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]init];
    activity.center = CGPointMake(DEVICE_WIDTH / 2, NAV_HEIGHT + ((DEVICE_HEIGHT / 3) / 2));
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.color = [UIColor grayColor];

    [self.view addSubview:activity];
    [activity startAnimating];
    
    [mainAPI getImageFromId:[self.dataSource valueForKey:@"id"] block:^(UIImage *img, NSError *err) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = img;
            [activity stopAnimating];
            [activity removeFromSuperview];
        });
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
