//
//  MainAPI.m
//  TiltApp
//
//  Created by Evan on 12/9/15.
//  Copyright © 2015 none. All rights reserved.
//

#import "MainAPI.h"

#import "AFNetworking.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define FOURSQUARE_SEARCH_URL @"https://api.foursquare.com/v2/venues/search"
#define FOURSQUARE_HOURS_URL @"https://api.foursquare.com/v2/venues/VENUE_ID/hours"
#define FOURSQUARE_TIPS_URL @"https://api.foursquare.com/v2/venues/VENUE_ID/tips"
#define FOURSQUARE_TIP_URL @"https://api.foursquare.com/v2/tips/TIP_ID"
#define FOURSQUARE_PHOTOS_URL @"https://api.foursquare.com/v2/venues/VENUE_ID/photos"

#define CLIENT_ID @"LX1MFFF3JHNHDCPBXDTFWG4HXDYR4FHNLKRG3Y0R1A11E2H5"
#define CLIENT_SECRET @"HPFZPMINUCN2YM1BXOJPIQ3GR3A3LUVZVJRZPYSLE2BF2DZR"
#define VERSION @"20140806"

@interface MainAPI () {
    
}

-(NSString *)addAccessCrediantals:(NSString *)str;
-(NSDictionary *)formatHoursData:(NSDictionary *)dictonary;

-(void)getHours:(NSString *)str block:(void (^)(NSDictionary *, NSError *))block;
-(void)getWifiInfo:(NSString *)str block:(void (^)(NSArray *, NSError *))block;
-(void)getImageFromURL:(NSString *)urlStr block:(void (^)(UIImage *, NSError *))block;

@end

@implementation MainAPI

-(id)init {
    
    if (self = [super init]) {
        
    }
    
    return self;
}

-(NSString *)addAccessCrediantals:(NSString *)str {
    
    NSMutableString *tempStr = [NSMutableString stringWithString:str];
    
    [tempStr appendFormat:@"%@%@%@", @"?", @"client_id=", CLIENT_ID];
    [tempStr appendFormat:@"%@%@%@", @"&", @"client_secret=", CLIENT_SECRET];
    [tempStr appendFormat:@"%@%@%@", @"&", @"v=", VERSION];
    
    return tempStr;
}

-(NSDictionary *)formatHoursData:(NSDictionary *)dictonary {
    
    NSArray *timeframes = [[[dictonary valueForKey:@"response"]valueForKey:@"hours"]valueForKey:@"timeframes"];
    if (!timeframes) {
        timeframes = [[[dictonary valueForKey:@"response"]valueForKey:@"popular"]valueForKey:@"timeframes"];
    }
    
    NSDictionary *hours = @{
                                @"open": @"",
                                @"close": @"",
                                @"isOpen": [NSNumber numberWithBool:false]
                                };
    
    NSDictionary *open;
    
    for (NSDictionary *item in timeframes) {
        if ([item valueForKey:@"includesToday"]) {
            open = [[item valueForKey:@"open"]objectAtIndex:0];
        }
    }
    
    if (!open) {
        return hours;
    }
    
    int start = [[open valueForKey:@"start"]intValue];
    int end = [[open valueForKey:@"end"]intValue];
    
    NSMutableString *openStr = [[NSMutableString alloc]initWithString:@""];
    NSMutableString *closeStr = [[NSMutableString alloc]initWithString:@""];
    
    if (start < 1200) {
        openStr = [NSMutableString stringWithFormat:@"%d%@", start, @"am"];
    }
    else {
        openStr = [NSMutableString stringWithFormat:@"%d%@", start - 1200, @"pm"];
    }
    
    if (end < 1200) {
        closeStr = [NSMutableString stringWithFormat:@"%d%@", end, @"am"];
    }
    else {
        closeStr = [NSMutableString stringWithFormat:@"%d%@", end - 1200, @"pm"];
    }
    
    if (start != 0) {
        [openStr insertString:@":" atIndex:openStr.length - 4];
        
    }
    if (end != 0) {
        [closeStr insertString:@":" atIndex:closeStr.length - 4];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HH:mm"];
    NSArray *currentTimeArr = [[df stringFromDate:[NSDate date]]componentsSeparatedByString:@":"];
    int currentTimeInt = ([[currentTimeArr objectAtIndex:0]intValue] * 100) + [[currentTimeArr objectAtIndex:1]intValue];
    
    BOOL isOpen = false;
    
    if (currentTimeInt >= start && currentTimeInt < end) {
        isOpen = true;
    }
    
    hours = @{
              @"open": openStr,
              @"close": closeStr,
              @"isOpen": @(isOpen)
              };
    
    return hours;
}


-(void)getHours:(NSString *)str block:(void (^)(NSDictionary *, NSError *))block {

    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", FOURSQUARE_HOURS_URL];
    urlString = (NSMutableString *)[urlString stringByReplacingOccurrencesOfString:@"VENUE_ID" withString:str];
    [urlString appendFormat:@"%@%@%@", @"?", @"client_id=", CLIENT_ID];
    [urlString appendFormat:@"%@%@%@", @"&", @"client_secret=", CLIENT_SECRET];
    [urlString appendFormat:@"%@%@%@", @"&", @"v=", VERSION];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^ (NSData *data, NSURLResponse *res, NSError *err) {
        
        if (err) {
            block(nil, err);
            return;
        }
        
        NSError *jsonErr = nil;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonErr];
        
        if (jsonErr) {
            block(nil, jsonErr);
            return;
        }
        
        NSDictionary *formmatedJSONDictionary = [self formatHoursData:jsonDictionary];
        
        block(formmatedJSONDictionary, jsonErr);
        
    };
    
    NSURLSessionTask *dataTask = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
    
}

-(void)getWifiInfo:(NSString *)str block:(void (^)(NSArray *, NSError *))block {
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", FOURSQUARE_TIPS_URL];
    urlString = (NSMutableString *)[urlString stringByReplacingOccurrencesOfString:@"VENUE_ID" withString:str];
    urlString = (NSMutableString *)[self addAccessCrediantals:urlString];
    [urlString appendString:@"&limit=500"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^ (NSData *data, NSURLResponse *res, NSError *err) {
        
        if (err) {
            block(nil, err);
            return;
        }
        
        NSError *jsonErr = nil;
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonErr];
        
        if (jsonErr) {
            block(nil, jsonErr);
            return;
        }
        
        NSArray *itemsArray = [[[jsonArr valueForKey:@"response"]valueForKey:@"tips"]valueForKey:@"items"];
        NSMutableArray *toArray = [[NSMutableArray alloc]init];
        
        for (NSDictionary *item in itemsArray) {
            
            NSString *text = [[item valueForKey:@"text"]lowercaseString];
            NSString *created = [item valueForKey:@"createdAt"];
            
            NSDictionary *tempDictionary = @{
                                             @"text": text,
                                             @"created": created
                                             };
            
            if ([text containsString:@"wifi"]) {
                [toArray addObject:tempDictionary];
            }
            else if ([text containsString:@"password"]) {
                [toArray addObject:tempDictionary];
            }
            else if ([text containsString:@"outlet"]) {
                [toArray addObject:tempDictionary];
            }
            else if ([text containsString:@"outlets"]) {
                [toArray addObject:tempDictionary];
            }
            
        }
        
        block(toArray, nil);
        
    };
    
    NSURLSessionTask *dataTask = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
    
}

-(void)getImageFromURL:(NSString *)urlStr block:(void (^)(UIImage *, NSError *))block {
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^ (NSData *data, NSURLResponse *res, NSError *err) {
      
        if (err) {
            block(nil, err);
            return;
        }
        
        UIImage *image = [UIImage imageWithData:data];
        
        block(image, nil);
        
    };
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:completionHandler];
    [dataTask resume];
    
}

-(void)getCoffeeShops:(float)lat lng:(float)lng radius:(float)radius {
    
    NSError *err = [NSError errorWithDomain:@"something" code:5 userInfo:nil];
    err = nil;
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", FOURSQUARE_SEARCH_URL];
    urlString = (NSMutableString *)[self addAccessCrediantals:urlString];
    [urlString appendFormat:@"%@%@%@%@%@", @"&", @"ll=", [NSString stringWithFormat:@"%f", lat], @",", [NSString stringWithFormat:@"%f", lng]];
    [urlString appendFormat:@"%@%@%@", @"&", @"query=", @"coffee"];
    [urlString appendFormat:@"%@%@", @"&", @"limit=50"];
    [urlString appendFormat:@"%@%@%f", @"&", @"radius=", radius];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    
    void (^coffeeBlock)(NSData *, NSURLResponse *, NSError *) = ^ (NSData *data, NSURLResponse *res, NSError *err) {
        
        if (err) {
            [self.delegate mainAPIDidThrowError:err];
            return;
        }
        
        NSError *jsonErr = nil;
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonErr];
        
        if (jsonErr) {
            [self.delegate mainAPIDidThrowError:jsonErr];
            return;
        }
        
        NSArray *tempArr = [[jsonArr valueForKey:@"response"]valueForKey:@"venues"];
        
        [self.delegate mainAPIWillGetCoffeeShopsWithCount:(int)tempArr.count];
        
        for (NSDictionary *item in tempArr) {
            
            NSMutableDictionary *toItem = [[NSMutableDictionary alloc]initWithDictionary:item];
            
            void (^wifiBlock)(NSArray *, NSError *) = ^ (NSArray *arr, NSError *err) {
                
                if (err) {
                    [self.delegate mainAPIDidThrowError:err];
                    return;
                }
                
                [toItem setValue:arr forKey:@"tips"];
                
                [self.delegate mainAPIDidGetCoffeeShop:toItem];
                
            };
            
            void (^hoursBLock)(NSDictionary *, NSError *) = ^ (NSDictionary *dictionary, NSError *err) {
                
                if (err) {
                    [self.delegate mainAPIDidThrowError:err];
                    return;
                }
                
                [toItem setValue:dictionary forKey:@"hours"];
                
                [self getWifiInfo:[item valueForKey:@"id"] block:wifiBlock];
                
            };
            
            [self getHours:[item valueForKey:@"id"] block:hoursBLock];
            
        }
        
    };
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:coffeeBlock];
    [dataTask resume];
    
}

-(void)getImageFromId:(NSString *)idStr block:(void (^)(UIImage *, NSError *))block {
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", FOURSQUARE_PHOTOS_URL];
    urlString = (NSMutableString *)[urlString stringByReplacingOccurrencesOfString:@"VENUE_ID" withString:idStr];
    urlString = (NSMutableString *)[self addAccessCrediantals:urlString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    
    void (^completionBlock)(NSData *, NSURLResponse *, NSError *) = ^ (NSData *data, NSURLResponse *res, NSError *err) {
      
        if (err) {
            block(nil, err);
            return;
        }
        
        NSError *jsonErr = nil;
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonErr];
        
        NSArray *items = [[[jsonArr valueForKey:@"response"]valueForKey:@"photos"]valueForKey:@"items"];
        
        if (!items.count) {
            block(nil, nil);
            return;
        }
        
        NSDictionary *item = [items objectAtIndex:0];
        
        int DEVICE_WIDTH = [UIScreen mainScreen].bounds.size.width;
        
        NSString *size = [NSString stringWithFormat:@"%dx%d", DEVICE_WIDTH, DEVICE_WIDTH];
        
        NSString *prefix = [item valueForKey:@"prefix"];
        NSString *suffix = [item valueForKey:@"suffix"];
        
        NSString *url = [[prefix stringByAppendingString:size]stringByAppendingString:suffix];
        
        [self getImageFromURL:url block:^(UIImage *img, NSError *err) {
            block(img, err);
        }];
        
    };
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:completionBlock];
    [dataTask resume];
    
}

@end
