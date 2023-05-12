//
//  FCStore.h
//  FastClip-iOS
//
//  Created by ris on 2022/4/18.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

extern NSString * const _Nonnull FCProductIdentifierMonthly;
extern NSString * const _Nonnull FCProductIdentifierYearly;
extern NSString * const _Nonnull FCProductIdentifierLifetime;

extern NSNotificationName const _Nonnull FCStoreRefreshReceiptNotification;

typedef enum {
    FCPaymentStateInProgress,
    FCPaymentStateFailed,
    FCPaymentStatePurchased,
    FCPaymentStateRestored,
}FCPaymentState;

NS_ASSUME_NONNULL_BEGIN

@interface FCProduct : NSObject

@property (nonatomic, strong) NSString *productIdentifier;
@property (nonatomic, strong) NSString *localizedTitle;
@property (nonatomic, strong) NSString *localizedDescription;
@property (nonatomic, strong) NSString *localizedPrice;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (nonatomic ,strong) NSString *introductoryOffer;
@property (nonatomic, strong) SKProduct *skProduct;
@end

@interface FCPlan : NSObject

@property (nonatomic, strong) NSString *productIdentifier;
@property (nonatomic, strong) NSString *localizedTitle;
@property (nonatomic, strong) NSString *expirationDate;
@property (nonatomic, strong) NSArray<NSString *> *upgradeProductIdentifiers;
@property (nonatomic, assign) BOOL valid;

@property (nonatomic, readonly, class) FCPlan *None;

@end

@interface FCStore : NSObject

+ (instancetype)shared;
- (void)productsRequestOnCompletion:(void(^)(NSDictionary<NSString *,FCProduct *> *productDic))completion;
- (void)pay:(FCProduct *)fcProduct onChanged:(void(^)(FCPaymentState state))onChanged;
- (void)restoreOnChanged:(void(^)(FCPaymentState state))onChanged;
- (void)refreshReceipt;
- (FCPlan *)getPlan:(BOOL)refresh;
- (BOOL)subscribed:(NSString *)productIdentifier;
@property (nonatomic, assign) BOOL testingProFlag;
@end

NS_ASSUME_NONNULL_END
