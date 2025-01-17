//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSConfigInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "MERequestContext.h"
#import "EMSPushV3Internal.h"
#import "PRERequestContext.h"

@interface EMSConfigInternal ()

@property(nonatomic, strong) EMSMobileEngageV3Internal *mobileEngage;
@property(nonatomic, strong) MERequestContext *meRequestContext;
@property(nonatomic, strong) PRERequestContext *preRequestContext;
@property(nonatomic, strong) EMSPushV3Internal *pushInternal;
@property(nonatomic, strong) NSString *contactFieldValue;

@end

@implementation EMSConfigInternal

- (instancetype)initWithMeRequestContext:(MERequestContext *)meRequestContext
                       preRequestContext:(PRERequestContext *)preRequestContext
                            mobileEngage:(EMSMobileEngageV3Internal *)mobileEngage
                            pushInternal:(EMSPushV3Internal *)pushInternal {
    NSParameterAssert(meRequestContext);
    NSParameterAssert(preRequestContext);
    NSParameterAssert(mobileEngage);
    NSParameterAssert(pushInternal);

    if (self = [super init]) {
        _mobileEngage = mobileEngage;
        _meRequestContext = meRequestContext;
        _preRequestContext = preRequestContext;
        _pushInternal = pushInternal;
    }
    return self;
}

- (void)changeApplicationCode:(nullable NSString *)applicationCode
              completionBlock:(_Nullable EMSCompletionBlock)completionBlock; {
    _contactFieldValue = [self.meRequestContext contactFieldValue];

    __weak typeof(self) weakSelf = self;
    if (self.meRequestContext.applicationCode) {
        [self.mobileEngage clearContactWithCompletionBlock:^(NSError *error) {
            if (error) {
                [weakSelf callCompletionBlock:completionBlock
                                    withError:error];
            } else {
                [weakSelf callSetPushToken:applicationCode
                           completionBlock:completionBlock];
            }
        }];
    } else {
        [self callSetPushToken:applicationCode
               completionBlock:completionBlock];
    }
}

- (NSString *)applicationCode {
    return self.meRequestContext.applicationCode;
}

- (void)changeMerchantId:(nullable NSString *)merchantId {
    self.preRequestContext.merchantId = merchantId;
}

- (NSString *)merchantId {
    return self.preRequestContext.merchantId;
}

- (NSNumber *)contactFieldId {
    return self.meRequestContext.contactFieldId;
}

- (void)setContactFieldId:(NSNumber *)contactFieldId {
    NSParameterAssert(contactFieldId);
    self.meRequestContext.contactFieldId = contactFieldId;
}

- (void)setPushTokenWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    if (self.pushInternal.deviceToken) {
        [self.pushInternal setPushToken:self.pushInternal.deviceToken
                        completionBlock:^(NSError *error) {
                            if (error) {
                                [weakSelf callCompletionBlock:completionBlock
                                                    withError:error];
                            } else {
                                [weakSelf setContactWithCompletionBlock:completionBlock];
                            }
                        }];
    } else {
        [self setContactWithCompletionBlock:completionBlock];
    }
}

- (void)setContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.mobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                       completionBlock:^(NSError *error) {
                                           [weakSelf callCompletionBlock:completionBlock
                                                               withError:error];
                                       }];
}

- (void)callSetPushToken:(NSString *)applicationCode
         completionBlock:(EMSCompletionBlock)completionBlock {
    self.meRequestContext.applicationCode = applicationCode;
    [self setPushTokenWithCompletionBlock:completionBlock];
}

- (void)callCompletionBlock:(EMSCompletionBlock)completionBlock
                  withError:(NSError *)error {
    if (error) {
        self.meRequestContext.applicationCode = nil;
    }
    if (completionBlock) {
        completionBlock(error);
    }
}

@end
