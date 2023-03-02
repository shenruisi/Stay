//
//  FCStore.m
//  FastClip-iOS
//
//  Created by ris on 2022/4/18.
//

#import "FCStore.h"
#include <openssl/bio.h>
#include <openssl/cms.h>
#include <openssl/err.h>
#include <openssl/pem.h>
#include <openssl/ssl.h>
#include <openssl/crypto.h>
#include <openssl/rand.h>
#import "RMAppReceipt.h"
#import "SharedStorageManager.h"

NSString * const _Nonnull FCProductIdentifierMonthly = @"Stay_Pro_Monthly";
NSString * const _Nonnull FCProductIdentifierYearly = @"Stay_Pro_Yearly";
NSString * const _Nonnull FCProductIdentifierLifetime = @"Stay_Pro_Lifetime";

NSNotificationName const _Nonnull FCStoreRefreshReceiptNotification = @"app.fastclip.notification.FCStoreRefreshReceiptNotification";

@implementation FCProduct

- (NSString *)description{
    return [NSString stringWithFormat:@"title: %@,description: %@, price: %@",self.localizedTitle,self.localizedDescription,self.localizedPrice];
}
@end

@implementation FCPlan

static FCPlan *noneInstance = nil;
+ (FCPlan *)None{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        noneInstance = [[FCPlan alloc] init];
    });
    
    return noneInstance;
}

@end

@interface FCStore()<
 SKProductsRequestDelegate,
 SKPaymentTransactionObserver,
 SKRequestDelegate
>

@property (nonatomic, strong) SKProductsRequest *request;
@property (nonatomic, copy) void(^productsRequestCompletion)(NSDictionary<NSString *,FCProduct *> *productDic);
@property (nonatomic, strong) NSArray<NSString *> *productIdentifiers;
@property (nonatomic, strong) NSMutableDictionary<SKPayment *, void(^)(FCPaymentState state)> *paymentOnChangedDic;
@property (nonatomic, copy) void(^restoreOnChanged)(FCPaymentState state);
@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, strong) SKReceiptRefreshRequest *receiptRefreshRequest;
@end

@implementation FCStore

static FCStore *instance = nil;
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FCStore alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    if (self = [super init]){
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"product_ids"
                                             withExtension:@"plist"];
        NSDictionary *productIdentifierDic = [NSDictionary dictionaryWithContentsOfURL:url][@"products"];
        self.productIdentifiers = productIdentifierDic.allValues;
    }
    
    return self;
}

- (void)test{
    [self productsRequestOnCompletion:^(NSDictionary<NSString *,FCProduct *> * _Nonnull productDic) {
        FCProduct *monthlyProduct = productDic[@"monthly"];
        [self pay:monthlyProduct onChanged:^(FCPaymentState state) {
            
        }];
    }];
}

- (FCPlan *)getPlan:(BOOL)refresh{
#ifdef DEBUG
//    [SharedStorageManager shared].userDefaultsExRO.pro = NO;
//    return FCPlan.None;
//    [SharedStorageManager shared].userDefaultsExRO.pro = YES;
//    return [[FCPlan alloc] init];
#endif
    RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
    FCPlan *plan = FCPlan.None;
    if (receipt && [receipt.bundleIdentifier isEqualToString:@"com.dajiu.stay.pro"]){
        NSDate *currentDate = [NSDate date];
        
        NSArray *sortedPurchases = [receipt.inAppPurchases sortedArrayUsingComparator:
                                    ^NSComparisonResult(RMAppReceiptIAP *receiptIAP1, RMAppReceiptIAP *receiptIAP2) {
            return [receiptIAP2.subscriptionExpirationDate compare:receiptIAP1.subscriptionExpirationDate];
        }];
        
        BOOL needRefresh = NO;
        for (RMAppReceiptIAP *receiptIAP in sortedPurchases){
            if ([receiptIAP.productIdentifier isEqualToString:FCProductIdentifierLifetime] ||
                [receiptIAP isActiveAutoRenewableSubscriptionForDate:currentDate]){
                if ([self _coverPlan:plan productIdentifier:receiptIAP.productIdentifier]){
                    plan = [[FCPlan alloc] init];
                    plan.productIdentifier = receiptIAP.productIdentifier;
                    plan.localizedTitle = [self _getPlanLocalizedTitle:receiptIAP.productIdentifier];
                    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd"];
                    plan.expirationDate = [dateFormat stringFromDate:receiptIAP.subscriptionExpirationDate];
                    plan.upgradeProductIdentifiers = [self _getUpgradeProductIdentifiers:receiptIAP.productIdentifier];
                    plan.valid = YES;
                }
            }
            else{
                if (![receiptIAP.productIdentifier isEqualToString:FCProductIdentifierLifetime]
                    && ![receiptIAP isActiveAutoRenewableSubscriptionForDate:currentDate]){
                    needRefresh = YES;
                }
            }
        }
        if (refresh && (needRefresh || sortedPurchases.count == 0)){
            [self refreshReceipt];
        }
    }
    
    [SharedStorageManager shared].userDefaultsExRO.pro = plan != FCPlan.None;
    return plan;
}

- (BOOL)subscribed:(NSString *)productIdentifier{
    RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
    if (receipt && [receipt.bundleIdentifier isEqualToString:@"com.dajiu.stay.pro"]){
        NSDate *currentDate = [NSDate date];
        
        NSArray *sortedPurchases = [receipt.inAppPurchases sortedArrayUsingComparator:
                                    ^NSComparisonResult(RMAppReceiptIAP *receiptIAP1, RMAppReceiptIAP *receiptIAP2) {
            return [receiptIAP2.subscriptionExpirationDate compare:receiptIAP1.subscriptionExpirationDate];
        }];
        
        for (RMAppReceiptIAP *receiptIAP in sortedPurchases){
            if ([receiptIAP.productIdentifier isEqualToString:productIdentifier]
                && ([productIdentifier isEqualToString:FCProductIdentifierLifetime])){ //lifetime
                return YES;
            }
            else if ([receiptIAP.productIdentifier isEqualToString:productIdentifier]
                     && ![productIdentifier isEqualToString:FCProductIdentifierLifetime]
                     && [receiptIAP isActiveAutoRenewableSubscriptionForDate:currentDate]){ //subscribe
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)_coverPlan:(FCPlan *)plan productIdentifier:(NSString *)productIdentifier{
    if (!plan || FCPlan.None == plan) return YES;
    if ([self _orderOfProductIdentifier:productIdentifier] > [self _orderOfProductIdentifier:plan.productIdentifier]){
        return YES;
    }
    return NO;
}

- (NSArray *)_getUpgradeProductIdentifiers:(NSString *)productIdentifier{
    if ([productIdentifier isEqualToString:FCProductIdentifierMonthly]){
        return @[FCProductIdentifierYearly,FCProductIdentifierLifetime];
    }
    else if ([productIdentifier isEqualToString:FCProductIdentifierYearly]){
        return @[FCProductIdentifierLifetime];
    }
    else return nil;
}

- (NSString *)_getPlanLocalizedTitle:(NSString *)productIdentifier{
    if ([productIdentifier isEqualToString:FCProductIdentifierMonthly]){
        return NSLocalizedString(@"MonthlySubscription", @"");
    }
    else if ([productIdentifier isEqualToString:FCProductIdentifierYearly]){
        return NSLocalizedString(@"YearlySubscription", @"");
    }
    else if ([productIdentifier isEqualToString:FCProductIdentifierLifetime]){
        return NSLocalizedString(@"LifetimeSubscription", @"");
    }
    
    return nil;
}

- (NSInteger)_orderOfProductIdentifier:(NSString *)productIdentifier{
    if ([productIdentifier isEqualToString:FCProductIdentifierMonthly]) return 1;
    else if ([productIdentifier isEqualToString:FCProductIdentifierYearly]) return 2;
    else if ([productIdentifier isEqualToString:FCProductIdentifierLifetime]) return 3;
    else return  0;
}

- (void)productsRequestOnCompletion:(void (^)(NSDictionary<NSString *,FCProduct *> *))completion{
    self.productsRequestCompletion = completion;
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
        initWithProductIdentifiers:[NSSet setWithArray:self.productIdentifiers]];

    // Keep a strong reference to the request.
    self.request = productsRequest;
    productsRequest.delegate = self;
    [productsRequest start];
}

- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product{
    self.paymentOnChangedDic[payment] = ^(FCPaymentState state){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"app.stay.notification.SYSubscibeChangeNotification"
                                                            object:nil];
    };
    return YES;
}

- (void)productsRequest:(SKProductsRequest *)request
didReceiveResponse:(SKProductsResponse *)response
{
    for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
        // Handle any invalid product identifiers.
        NSLog(@"%@",invalidIdentifier);
    }
    
    NSMutableDictionary<NSString *,FCProduct *> *productDic = [[NSMutableDictionary alloc] init];
    
    NSArray<SKProduct *> *products = response.products;
    for (SKProduct *product in products){
        NSString *key = nil;
        NSString *introductoryOffer = nil;
        if ([product.productIdentifier isEqualToString:@"Stay_Pro_Monthly"]){
            key = @"monthly";
            introductoryOffer = NSLocalizedString(@"OneWeekFreeTrial", @"");
        }
        else if ([product.productIdentifier isEqualToString:@"Stay_Pro_Yearly"]){
            key = @"yearly";
            introductoryOffer = NSLocalizedString(@"OneMonthFreeTrial", @"");
        }
        else if ([product.productIdentifier isEqualToString:@"Stay_Pro_Lifetime"]){
            key = @"lifetime";
            introductoryOffer = NSLocalizedString(@"OneTimePayment", @"");
        }
        
        if (key.length > 0){
            FCProduct *fcProduct = [[FCProduct alloc] init];
            fcProduct.localizedTitle = product.localizedTitle;
            fcProduct.localizedDescription = product.localizedDescription;
            fcProduct.productIdentifier = product.productIdentifier;
            fcProduct.introductoryOffer = introductoryOffer;
            fcProduct.price = product.price;
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterCurrencyStyle;
            formatter.locale = product.priceLocale;
            fcProduct.localizedPrice = [formatter stringFromNumber:product.price];
            fcProduct.skProduct = product;
            [productDic setObject:fcProduct forKey:key];
        }
    }
    
    if (self.productsRequestCompletion){
        self.productsRequestCompletion(productDic);
    }
}

- (void)pay:(FCProduct *)fcProduct onChanged:(void(^)(FCPaymentState state))onChanged{
    SKProduct *product = fcProduct.skProduct;
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    self.paymentOnChangedDic[payment] = [onChanged copy];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreOnChanged:(void(^)(FCPaymentState state))onChanged{
    self.restoreOnChanged = onChanged;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            // Call the appropriate custom method for the transaction state.
            case SKPaymentTransactionStatePurchasing:
                self.paymentOnChangedDic[transaction.payment](FCPaymentStateInProgress);
                break;
            case SKPaymentTransactionStateDeferred:
                self.paymentOnChangedDic[transaction.payment](FCPaymentStateInProgress);
                break;
            case SKPaymentTransactionStateFailed:{
                if (self.paymentOnChangedDic[transaction.payment]){
                    self.paymentOnChangedDic[transaction.payment](FCPaymentStateFailed);
                    self.paymentOnChangedDic[transaction.payment] = nil;
                }
            }
                break;
            case SKPaymentTransactionStatePurchased:{
                BOOL verified = [self verifyTransaction:transaction];
                if (self.paymentOnChangedDic[transaction.payment]){
                    self.paymentOnChangedDic[transaction.payment](verified ? FCPaymentStatePurchased : FCPaymentStateFailed);
                    self.paymentOnChangedDic[transaction.payment] = nil;
                }
            }
                
                break;
            case SKPaymentTransactionStateRestored:{
                BOOL verified = [self verifyTransaction:transaction];
                if (self.paymentOnChangedDic[transaction.payment]){
                    self.paymentOnChangedDic[transaction.payment](verified ? FCPaymentStateRestored : FCPaymentStateFailed);
                    self.paymentOnChangedDic[transaction.payment] = nil;
                }
                else if (self.restoreOnChanged){
                    self.restoreOnChanged(verified ? FCPaymentStateRestored : FCPaymentStateFailed);
                }
            }
                
                break;
            default:
                // For debugging
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    [self refreshReceipt];
    if (self.restoreOnChanged){
        self.restoreOnChanged(FCPaymentStateRestored);
        self.restoreOnChanged = nil;
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    if (self.restoreOnChanged){
        self.restoreOnChanged(FCPaymentStateFailed);
        self.restoreOnChanged = nil;
    }
}

- (BOOL)verifyTransaction:(SKPaymentTransaction*)transaction{
    RMAppReceipt *receipt = [RMAppReceipt bundleReceipt];
    if ([self verifyReceipt:receipt]) return YES;
    
    SKPayment *payment = transaction.payment;
    BOOL transactionVerified = [receipt containsInAppPurchaseOfProductIdentifier:payment.productIdentifier];
    if (transactionVerified) return YES;
    [self refreshReceipt];
    return NO;
}

- (BOOL)verifyReceipt:(RMAppReceipt *)receipt{
    if (!receipt) return NO;
    if (![receipt.bundleIdentifier isEqualToString:self.bundleIdentifier]) return NO;
    if (![receipt verifyReceiptHash]) return NO;
    
    return YES;
}

- (void)refreshReceipt{
    self.receiptRefreshRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:@{}];
    self.receiptRefreshRequest.delegate = self;
    [self.receiptRefreshRequest start];
}

- (void)requestDidFinish:(SKRequest *)request{
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]){
        [[NSNotificationCenter defaultCenter] postNotificationName:FCStoreRefreshReceiptNotification
                                                            object:nil
                                                          userInfo:@{
            @"succeed":@(YES)
        }];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]){
        [[NSNotificationCenter defaultCenter] postNotificationName:FCStoreRefreshReceiptNotification
                                                            object:nil
                                                          userInfo:@{
            @"succeed":@(NO)
        }];
    }
}



- (NSString*)bundleIdentifier
{
    if (!_bundleIdentifier)
    {
        return [NSBundle mainBundle].bundleIdentifier;
    }
    return _bundleIdentifier;
}


- (NSMutableDictionary<SKPayment *,void (^)(FCPaymentState)> *)paymentOnChangedDic{
    if (nil == _paymentOnChangedDic){
        _paymentOnChangedDic = [[NSMutableDictionary alloc] init];
    }
    
    return _paymentOnChangedDic;
}




@end
