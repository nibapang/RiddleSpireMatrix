//
//  UIViewController+extension.h
//  RiddleSpireMatrix
//
//  Created by RiddleSpireMatrix on 03/02/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (extension)

+ (NSString *)riddleSpireGetUserDefaultKey;

+ (void)riddleSpireSetUserDefaultKey:(NSString *)key;

- (void)riddleSpireSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)riddleSpireAppsFlyerDevKey;

- (NSString *)riddleSpireMainHostUrl;

- (BOOL)riddleSpireNeedShowAdsView;

- (void)riddleSpireShowAdView:(NSString *)adsUrl;

- (void)riddleSpireSendEventsWithParams:(NSString *)params;

- (NSDictionary *)riddleSpireJsonToDicWithJsonString:(NSString *)jsonString;

- (void)riddleSpireAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)riddleSpireAfSendEventWithName:(NSString *)name value:(NSString *)valueStr;

@end

NS_ASSUME_NONNULL_END
