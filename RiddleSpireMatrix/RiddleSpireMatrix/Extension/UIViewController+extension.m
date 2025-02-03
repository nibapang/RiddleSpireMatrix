//
//  UIViewController+extension.m
//  RiddleSpireMatrix
//
//  Created by RiddleSpireMatrix on 03/02/25.
//

#import "UIViewController+extension.h"
#import <AppsFlyerLib/AppsFlyerLib.h>

static NSString *KRiddleSpireUserDefaultkey __attribute__((section("__DATA, riddleSpire"))) = @"";

NSDictionary *KRiddleSpireJsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, riddleSpire")));
NSDictionary *KRiddleSpireJsonToDicLogic(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

id KRiddleSpireJsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, riddleSpire")));
id KRiddleSpireJsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = KRiddleSpireJsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}


void KRiddleSpireShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, riddleSpire")));
void KRiddleSpireShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.riddleSpireGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void KRiddleSpireSendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, riddleSpire")));
void KRiddleSpireSendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.riddleSpireGetUserDefaultKey];
    if ([event isEqualToString:adsDatas[11]] || [event isEqualToString:adsDatas[12]] || [event isEqualToString:adsDatas[13]]) {
        id am = value[adsDatas[15]];
        NSString *cur = value[adsDatas[14]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: [event isEqualToString:adsDatas[13]] ? @(-niubi) : @(niubi),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
    }
}

NSString *KRiddleSpireAppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, riddleSpire")));
NSString *KRiddleSpireAppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

NSString* KRiddleSpireConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, riddleSpire")));
NSString* KRiddleSpireConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

@implementation UIViewController (extension)

+ (NSString *)riddleSpireGetUserDefaultKey
{
    return KRiddleSpireUserDefaultkey;
}

+ (void)riddleSpireSetUserDefaultKey:(NSString *)key
{
    KRiddleSpireUserDefaultkey = key;
}

+ (NSString *)riddleSpireAppsFlyerDevKey
{
    return KRiddleSpireAppsFlyerDevKey(@"riddleSpirezt99WFGrJwb3RdzuknjXSKriddleSpire");
}

- (NSString *)riddleSpireMainHostUrl
{
    return @"sa.xyz";
}

- (BOOL)riddleSpireNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isBr = [countryCode isEqualToString:[NSString stringWithFormat:@"%@R", self.preFx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    return isBr && !isIpd;
}

- (NSString *)preFx
{
    return @"B";
}

- (void)riddleSpireShowAdView:(NSString *)adsUrl
{
    KRiddleSpireShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)riddleSpireJsonToDicWithJsonString:(NSString *)jsonString {
    return KRiddleSpireJsonToDicLogic(jsonString);
}

- (void)riddleSpireSendEvent:(NSString *)event values:(NSDictionary *)value
{
    KRiddleSpireSendEventLogic(self, event, value);
}

- (void)riddleSpireSendEventsWithParams:(NSString *)params
{
    NSDictionary *paramsDic = [self riddleSpireJsonToDicWithJsonString:params];
    NSString *event_type = [paramsDic valueForKey:@"event_type"];
    if (event_type != NULL && event_type.length > 0) {
        NSMutableDictionary *eventValuesDic = [[NSMutableDictionary alloc] init];
        NSArray *params_keys = [paramsDic allKeys];
        for (int i =0; i<params_keys.count; i++) {
            NSString *key = params_keys[i];
            if ([key containsString:@"af_"]) {
                NSString *value = [paramsDic valueForKey:key];
                [eventValuesDic setObject:value forKey:key];
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:event_type eventValues:eventValuesDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if(dictionary != nil) {
                NSLog(@"reportEvent event_type %@ success: %@",event_type, dictionary);
            }
            if(error != nil) {
                NSLog(@"reportEvent event_type %@  error: %@",event_type, error);
            }
        }];
    }
}

- (void)riddleSpireAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr
{
    NSDictionary *paramsDic = [self riddleSpireJsonToDicWithJsonString:paramsStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.riddleSpireGetUserDefaultKey];
    if ([KRiddleSpireConvertToLowercase(name) isEqualToString:KRiddleSpireConvertToLowercase(adsDatas[24])]) {
        id am = paramsDic[adsDatas[25]];
        if (am) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: adsDatas[30]
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    }
}

- (void)riddleSpireAfSendEventWithName:(NSString *)name value:(NSString *)valueStr
{
    NSDictionary *paramsDic = [self riddleSpireJsonToDicWithJsonString:valueStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.riddleSpireGetUserDefaultKey];
    if ([KRiddleSpireConvertToLowercase(name) isEqualToString:KRiddleSpireConvertToLowercase(adsDatas[24])] || [KRiddleSpireConvertToLowercase(name) isEqualToString:KRiddleSpireConvertToLowercase(adsDatas[27])]) {
        id am = paramsDic[adsDatas[26]];
        NSString *cur = paramsDic[adsDatas[14]];
        if (am && cur) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    }
}

@end
