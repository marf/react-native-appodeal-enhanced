#import "RNAppodeal.h"

#if __has_include(<React/RCTUtils.h>)
#import <React/RCTUtils.h>
#else
#import "RCTUtils.h"
#endif

const int INTERSTITIAL        = 1;
const int BANNER              = 4;
const int BANNER_BOTTOM       = 8;
const int BANNER_TOP          = 16;
const int REWARDED_VIDEO      = 128;
const int NON_SKIPPABLE_VIDEO = 256;

NSMutableDictionary *customRules;
BOOL isRewardedFinished;
BOOL isNonSkippableFinished;
BOOL isBannerPrecache;
BOOL isInterstitialPrecache;

static NSString *const kEventBannerLoaded = @"onBannerLoaded";
static NSString *const kEventBannerFailedToLoad = @"onBannerFailedToLoad";
static NSString *const kEventBannerShown = @"onBannerShown";
static NSString *const kEventBannerClicked = @"onBannerClicked";

static NSString *const kEventInterstitialLoaded = @"onInterstitialLoaded";
static NSString *const kEventInterstitialFailedToLoad = @"onInterstitialFailedToLoad";
static NSString *const kEventInterstitialShown = @"onInterstitialShown";
static NSString *const kEventInterstitialFailedShown = @"onInterstitialFailedShown";
static NSString *const kEventInterstitialClosed = @"onInterstitialClosed";
static NSString *const kEventInterstitialClicked = @"onInterstitialClicked";
static NSString *const kEventInterstitialExpired = @"onInterstitialExpired";

//static NSString *const kEventRewardedVideoLoaded = @"onRewardedVideoLoaded";
static NSString *const kEventRewardedVideoDidLoadAdIsPrecache = @"onRewardedVideoDidLoadAdIsPrecache";
static NSString *const kEventRewardedVideoFailedToLoad = @"onRewardedVideoFailedToLoad";
//static NNString *const kEventRewardedVideoDidFailToPresent = @"onRewardedVideoDidFailToPresent";
static NSString *const kEventRewardedVideoDidFailToPresentWithError = @"onRewardedVideoDidFailToPresentWithError";
static NSString *const kEventRewardedVideoShown = @"onRewardedVideoShown";
static NSString *const kEventRewardedVideoClosed = @"onRewardedVideoClosed";
static NSString *const kEventRewardedVideoFinished = @"onRewardedVideoFinished";
static NSString *const kEventRewardedVideoDidPresent = @"onRewardedVideoPresented";
static NSString *const kEventRewardedVideoDidClick = @"onRewardedVideoClicked";
static NSString *const kEventRewardedVideoDidExpired = @"onRewardedVideoExpired";

static NSString *const kEventNonSkippableVideoLoaded = @"onNonSkippableVideoLoaded";
static NSString *const kEventNonSkippableVideoDidLoadAdIsPrecache = @"onNonSkippableVideoDidLoadAdIsPrecache";
static NSString *const kEventNonSkippableVideoFailedToLoad = @"onNonSkippableVideoFailedToLoad";
static NSString *const kEventNonSkippableVideoShown = @"onNonSkippableVideoShown";
//static NSString *const kEventNonSkippableVideoClosed = @"onNonSkippableVideoClosed";
static NSString *const kEventNonSkippableVideoFullyWatched = @"onNonSkippableVideoWasFullyWatched";
static NSString *const kEventNonSkippableVideoFinished = @"onNonSkippableVideoFinished";
static NSString *const kEventNonSkippableVideoExpired = @"onNonSkippableVideoExpired";
static NSString *const kEventNonSkippableVideoDidFailToPresentWithError = @"onNonSkippableVideoDidFailToPresentWithError";

#pragma mark Convert types, styles and logs
AppodealAdType nativeAdTypesForType(int adTypes) {
    int nativeAdTypes = 0;
    if ((adTypes & INTERSTITIAL) > 0) {
        nativeAdTypes |= AppodealAdTypeInterstitial;
    }
    if ((adTypes & BANNER) > 0 ||
        (adTypes & BANNER_TOP) > 0 ||
        (adTypes & BANNER_BOTTOM) > 0) {
        nativeAdTypes |= AppodealAdTypeBanner;
    }
    if ((adTypes & REWARDED_VIDEO) > 0) {
        nativeAdTypes |= AppodealAdTypeRewardedVideo;
    }
    if ((adTypes & NON_SKIPPABLE_VIDEO) >0) {
        nativeAdTypes |= AppodealAdTypeNonSkippableVideo;
    }
    return nativeAdTypes;
}

AppodealShowStyle nativeShowStyleForType(int adTypes) {
    if ((adTypes & INTERSTITIAL) > 0) {
        return AppodealShowStyleInterstitial;
    }
    if ((adTypes & BANNER_TOP) > 0) {
        return AppodealShowStyleBannerTop;
    }
    if ((adTypes & BANNER_BOTTOM) > 0) {
        return AppodealShowStyleBannerBottom;
    }
    if ((adTypes & REWARDED_VIDEO) > 0) {
        return AppodealShowStyleRewardedVideo;
    }
    if ((adTypes & NON_SKIPPABLE_VIDEO) > 0) {
        return AppodealShowStyleNonSkippableVideo;
    }
    return 0;
}
#pragma mark implementation of plugin

@implementation RNAppodeal

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
    return @[
             kEventBannerLoaded,
             kEventBannerFailedToLoad,
             kEventBannerShown,
             kEventBannerClicked,
             kEventInterstitialLoaded,
             kEventInterstitialFailedToLoad,
             kEventInterstitialShown,
             kEventInterstitialFailedShown,
             kEventInterstitialClosed,
             kEventInterstitialClicked,
             kEventInterstitialExpired,
             //kEventRewardedVideoLoaded,
             kEventRewardedVideoDidPresent,
             kEventRewardedVideoDidLoadAdIsPrecache,
             kEventRewardedVideoFailedToLoad,
             kEventRewardedVideoDidExpired,
             //kEventRewardedVideoDidFailToPresent,
             kEventRewardedVideoDidFailToPresentWithError,
             kEventRewardedVideoShown,
             kEventRewardedVideoClosed,
             kEventRewardedVideoFinished,
             kEventRewardedVideoDidClick,
             kEventNonSkippableVideoLoaded,
             kEventNonSkippableVideoDidLoadAdIsPrecache,
             kEventNonSkippableVideoFailedToLoad,
             kEventNonSkippableVideoDidFailToPresentWithError,
             kEventNonSkippableVideoShown,
             //kEventNonSkippableVideoClosed,
             kEventNonSkippableVideoFullyWatched,
             kEventNonSkippableVideoExpired,
             kEventNonSkippableVideoFinished ];
}

#pragma mark exported methods

RCT_EXPORT_METHOD(initialize:(NSString *)appKey types:(int)adType
                  result:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        customRules = [[NSMutableDictionary alloc] init];
        [Appodeal initializeWithApiKey:appKey types:nativeAdTypesForType(adType) hasConsent:true];
        
        //[Appodeal setLogLevel:APDLogLevelVerbose];
        
        [Appodeal setRewardedVideoDelegate:self];
        //[Appodeal setNonSkippableVideoDelegate:self];
        [Appodeal setBannerDelegate:self];
        [Appodeal setInterstitialDelegate:self];
        
        callback(@[@YES]);
    });
}

RCT_EXPORT_METHOD(showToast:(NSString *)message) {
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [toast show];
    int duration = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

RCT_EXPORT_METHOD(show:(int)showType placement:(NSString*)placement result:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([placement  isEqual: @""]) {
            [Appodeal showAd:nativeShowStyleForType(showType)  rootViewController:[[UIApplication sharedApplication] keyWindow].rootViewController];
            callback(@[@YES]);
        } else {
            
            [Appodeal showAd:nativeShowStyleForType(showType) forPlacement:placement rootViewController:[[UIApplication sharedApplication] keyWindow].rootViewController];
            callback(@[@YES]);
            
            /*if([Appodeal canShow:(showType) forPlacement:placement])
             {
             [Appodeal showAd:nativeShowStyleForType(showType) forPlacement:placement rootViewController:[[UIApplication sharedApplication] keyWindow].rootViewController];
             callback(@[@YES]);
             }
             else
             {
             callback(@[@NO]);
             }*/
        }
    });
}

RCT_EXPORT_METHOD(isLoaded:(int)showType result:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Appodeal REACT: isLoaded");
        if([Appodeal isReadyForShowWithStyle:nativeShowStyleForType(showType)])
        callback(@[@YES]);
        else
        callback(@[@NO]);
    });
}

RCT_EXPORT_METHOD(cache:(int)adType) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal cacheAd:nativeAdTypesForType(adType)];
    });
}

RCT_EXPORT_METHOD(hide:(int)adType) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal hideBanner];
    });
}

RCT_EXPORT_METHOD(setAutoCache:(int)adType autoc:(BOOL)autocache) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal setAutocache:autocache types:nativeAdTypesForType(adType)];
    });
}

RCT_EXPORT_METHOD(isPrecache:(int)adType calls:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([Appodeal isAutocacheEnabled:nativeAdTypesForType(adType)])
        callback(@[@YES]);
        else
        callback(@[@NO]);
    });
}


#pragma mark Banner settings

RCT_EXPORT_METHOD(setSmartBanners:(BOOL)val) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal setSmartBannersEnabled:val];
    });
}

RCT_EXPORT_METHOD(setBannerBackground:(BOOL)val) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal setBannerBackgroundVisible:val];
    });
}

RCT_EXPORT_METHOD(setBannerAnimation:(BOOL)val) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal setBannerAnimationEnabled:val];
    });
}

RCT_EXPORT_METHOD(setTabletBanners:(BOOL)val) { }

#pragma mark Advanced features


RCT_EXPORT_METHOD(setTesting:(BOOL)testingEnabled) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal setTestingEnabled:testingEnabled];
    });
}

RCT_EXPORT_METHOD(setLogLevel:(NSString *)logLevel) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([logLevel isEqualToString:@"none"])
        [Appodeal setLogLevel:APDLogLevelOff];
        if([logLevel isEqualToString:@"debug"])
        [Appodeal setLogLevel:APDLogLevelDebug];
        if([logLevel isEqualToString:@"verbose"])
        [Appodeal setLogLevel:APDLogLevelVerbose];
        
    });
}

RCT_EXPORT_METHOD(setChildDirectedTreatment:(BOOL)enabled) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal setChildDirectedTreatment:enabled];
    });
}

RCT_EXPORT_METHOD(setOnLoadedTriggerBoth:(int)adType enabled:(BOOL)val) { }

RCT_EXPORT_METHOD(disableNetwork:(NSString *)name) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal disableNetworkForAdType:AppodealAdTypeBanner name:name];
        [Appodeal disableNetworkForAdType:AppodealAdTypeNativeAd name:name];
        [Appodeal disableNetworkForAdType:AppodealAdTypeNonSkippableVideo name:name];
        [Appodeal disableNetworkForAdType:AppodealAdTypeRewardedVideo name:name];
        [Appodeal disableNetworkForAdType:AppodealAdTypeInterstitial name:name];
    });
}

RCT_EXPORT_METHOD(disableNetworkType:(NSString *)name types:(int)adType) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ((adType & BANNER) > 0 ||
            (adType & BANNER_TOP) > 0 ||
            (adType & BANNER_BOTTOM) > 0) {
            [Appodeal disableNetworkForAdType:AppodealAdTypeBanner name:name];
        }
        [Appodeal disableNetworkForAdType:nativeAdTypesForType(adType) name:name];
    });
}

RCT_EXPORT_METHOD(disableLocationPermissionCheck) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal setLocationTracking:NO];
    });
}

RCT_EXPORT_METHOD(disableWriteExternalStoragePermissionCheck) { }

RCT_EXPORT_METHOD(requestAndroidMPermissions) { }

RCT_EXPORT_METHOD(muteVideosIfCallsMuted) { }

RCT_EXPORT_METHOD(showTestScreen) { }

RCT_EXPORT_METHOD(getVersion:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(@[[Appodeal getVersion]]);
    });
}

RCT_EXPORT_METHOD(isAutocacheEnabled:(int)types callback:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([Appodeal isAutocacheEnabled:nativeAdTypesForType(types)]) {
            callback(@[@YES]);
        }
        else
        callback(@[@NO]);
    });
}

RCT_EXPORT_METHOD(isInitialized:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([Appodeal isInitalizedForAdType:(INTERSTITIAL)])
        callback(@[@YES]);
        else
        callback(@[@NO]);
    });
}

#pragma mark Placement features

RCT_EXPORT_METHOD(getRewardParameters:(NSString *) placementName result:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSObject <APDReward> * reward = [Appodeal rewardForPlacement: placementName];
        if (reward) {
            NSString *rewardCurrency = reward.currencyName;
            NSUInteger rewardAmount = reward.amount;
            callback(@[ @(rewardAmount), rewardCurrency ]);
        }
        else
        callback(@[@0,@""]);
    });
}

RCT_EXPORT_METHOD(canShow:(int)showType placement:(NSString *) placementName result:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([Appodeal canShow:(showType) forPlacement:placementName])
        callback(@[@YES]);
        else
        callback(@[@NO]);
    });
}

#pragma mark User Data

RCT_EXPORT_METHOD(setUserId:(NSString *)userId) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal setUserId:userId];
    });
}

RCT_EXPORT_METHOD(setAge:(int)age) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Appodeal setUserAge:age];
    });
}

RCT_EXPORT_METHOD(trackInAppPurchase:(double)amount currencyCode:(NSString *)currency) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[APDSdk sharedSdk] trackInAppPurchase:[NSNumber numberWithDouble:amount] currency: currency];
    });
}

RCT_EXPORT_METHOD(setGender:(NSString *)AppodealUserGender) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([AppodealUserGender isEqualToString:@"other"])
        [Appodeal setUserGender:AppodealUserGenderOther];
        if([AppodealUserGender isEqualToString:@"male"])
        [Appodeal setUserGender:AppodealUserGenderMale];
        if([AppodealUserGender isEqualToString:@"female"])
        [Appodeal setUserGender:AppodealUserGenderFemale];
    });
}

#pragma mark Events
#pragma mark - banner events
- (void)bannerDidShow {
    //[self sendEventWithName:@"onBannerShown" body:nil];
}

- (void)bannerDidLoadAdIsPrecache:(BOOL)precache {
    [self sendEventWithName:kEventBannerLoaded body:@{@"isPrecache":[NSNumber numberWithBool:precache]}];
}

- (void)bannerDidClick {
    [self sendEventWithName:kEventBannerClicked body:nil];
}

- (void)bannerDidFailToLoadAd; {
    [self sendEventWithName:kEventBannerFailedToLoad body:nil];
}

#pragma mark - Interstitial events
- (void)interstitialDidLoadAdIsPrecache:(BOOL)precache {
    [self sendEventWithName:kEventInterstitialLoaded body:@{@"isPrecache":[NSNumber numberWithBool:precache]}];
}

- (void)interstitialDidFailToLoadAd {
    [self sendEventWithName:kEventInterstitialFailedToLoad body:nil];
}

- (void)interstitialDidFailToPresent {
    [self sendEventWithName:kEventInterstitialFailedShown body:nil];
}

- (void)interstitialWillPresent {
    [self sendEventWithName:kEventInterstitialShown body:nil];
}

- (void)interstitialDidDismiss {
    [self sendEventWithName:kEventInterstitialClosed body:nil];
}

- (void)interstitialDidClick {
    [self sendEventWithName:kEventInterstitialClicked body:nil];
}

- (void)interstitialDidExpired {
    [self sendEventWithName:kEventInterstitialExpired body:nil];
}

#pragma mark - NonSkippable video events
/*- (void)nonSkippableVideoDidLoadAd {
 [self sendEventWithName:kEventNonSkippableVideoLoaded body:nil];
 }*/


- (void)nonSkippableVideoDidFailToLoadAd {
 [self sendEventWithName:kEventNonSkippableVideoFailedToLoad body:nil];
 }

- (void)nonSkippableVideoDidLoadAdIsPrecache:(BOOL)precache {
    [self sendEventWithName:kEventNonSkippableVideoDidLoadAdIsPrecache body:@{@"isPrecache":[NSNumber numberWithBool:precache]}];
}

- (void)nonSkippableVideoDidFailToPresentWithError:(nonnull NSError *)error{
    [self sendEventWithName:kEventNonSkippableVideoDidFailToPresentWithError body:@{@"error":error}];
}

- (void)nonSkippableVideoDidPresent {
    [self sendEventWithName:kEventNonSkippableVideoShown body:nil];
}

/*- (void)nonSkippableVideoWillDismiss {
    [self sendEventWithName:kEventNonSkippableVideoClosed body:nil];
}*/

- (void)nonSkippableVideoWillDismissAndWasFullyWatched:(BOOL)wasFullyWatched {
    [self sendEventWithName:kEventNonSkippableVideoFullyWatched body:nil];
}

- (void)nonSkippableVideoDidFinish {
    [self sendEventWithName:kEventNonSkippableVideoFinished body:nil];
}

- (void)nonSkippableVideoDidExpired {
    [self sendEventWithName:kEventNonSkippableVideoExpired body:nil];
}


#pragma mark - Rewarded video events
/*- (void)rewardedVideoDidLoadAd {
 [self sendEventWithName:kEventRewardedVideoLoaded body:nil];
 }*/

- (void)rewardedVideoDidLoadAdIsPrecache {
    [self sendEventWithName:kEventRewardedVideoDidLoadAdIsPrecache body:nil];
}

- (void)rewardedVideoDidFailToLoadAd {
    [self sendEventWithName:kEventRewardedVideoFailedToLoad body:nil];
}

/*- (void)rewardedVideoDidFailToPresent {
 [self sendEventWithName:kEventRewardedVideoDidFailToPresent body:nil];
 }*/
- (void)rewardedVideoDidPresent {
    [self sendEventWithName:kEventRewardedVideoDidPresent body:nil];
}

- (void)rewardedVideoDidFailToPresentWithError:(nonnull NSError *)error; {
    NSLog(@"RewaredVideo error log %@", error);
    [self sendEventWithName:kEventRewardedVideoDidFailToPresentWithError body:@{@"error":error}];
}

- (void)rewardedVideoWillDismissAndWasFullyWatched:(BOOL)wasFullyWatched {
    [self sendEventWithName:kEventRewardedVideoShown body:@{@"wasFullyWatched":[NSNumber numberWithBool:wasFullyWatched]}];
}

- (void)rewardedVideoDidFinish:(float)rewardAmount name:(NSString *)rewardName {
    if (rewardName == nil) {
        [self sendEventWithName:kEventRewardedVideoFinished body:@{@"amount":[NSNumber numberWithFloat:rewardAmount],@"name":@"nil"}];
    } else {
        [self sendEventWithName:kEventRewardedVideoFinished body:@{@"amount":[NSNumber numberWithFloat:rewardAmount],@"name":rewardName}];
    }
}

- (void)rewardedVideoDidClick {
    [self sendEventWithName:kEventRewardedVideoDidClick body:nil];
}

- (void)rewardedVideoDidExpired {
    [self sendEventWithName:kEventRewardedVideoDidExpired body:nil];
}
@end
