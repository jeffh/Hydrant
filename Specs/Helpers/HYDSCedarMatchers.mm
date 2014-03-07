#import "HYDSCedarMatchers.h"
#import "HYDError.h"

OBJC_EXTERN BeAnError be_an_error = BeAnError().with_domain(HYDErrorDomain);
OBJC_EXTERN BeAnError be_a_fatal_error = BeAnError().with_domain(HYDErrorDomain).and_fatal();
OBJC_EXTERN BeAnError be_a_non_fatal_error = BeAnError().with_domain(HYDErrorDomain).and_non_fatal();

bool BeAnError::matches(const HYDError *error) const {
    return (this->domain_matches(error) &&
            this->code_matches(error) &&
            this->fatality_matches(error) &&
            this->subset_of_userinfo_matches(error)
            );
}

bool BeAnError::domain_matches(const HYDError *error) const {
    return !this->expectedDomain || [this->expectedDomain isEqual:error.domain];
}

bool BeAnError::code_matches(const HYDError *error) const {
    return !this->checkErrorCode || this->expectedErrorCode == error.code;
}

bool BeAnError::fatality_matches(const HYDError *error) const {
    return !this->checkFatality || this->isFatal == error.isFatal;
}

bool BeAnError::subset_of_userinfo_matches(const HYDError *error) const {
    if (this->userInfoSubset) {
        NSDictionary *userInfo = error.userInfo;
        for (id key in this->userInfoSubset) {
            id value = this->userInfoSubset[key];
            if (![value isEqual:userInfo[key]]) {
                return NO;
            }
        }
    }
    return YES;
}

NSString * BeAnError::failure_message_end() const {
    return [NSString stringWithFormat:@"be an error (domain=%@%@%@) with at least userInfo of %@",
            this->expectedDomain,
            this->checkErrorCode ? [NSString stringWithFormat:@", code=%ld", (long)this->expectedErrorCode] : @"",
            this->checkFatality ? [NSString stringWithFormat:@", isFatal=%d", this->isFatal] : @"",
            this->userInfoSubset];
}

BeAnError BeAnError::with_code(NSInteger code) const {
    BeAnError matcher(*this);
    matcher.checkErrorCode = true;
    matcher.expectedErrorCode = code;
    return matcher;
}

BeAnError BeAnError::with_domain(NSString *domain) const {
    BeAnError matcher(*this);
    matcher.expectedDomain = domain;
    return matcher;
}

BeAnError BeAnError::and_fatal() const {
    BeAnError matcher(*this);
    matcher.checkFatality = true;
    matcher.isFatal = true;
    return matcher;
}

BeAnError BeAnError::and_non_fatal() const {
    BeAnError matcher(*this);
    matcher.checkFatality = true;
    matcher.isFatal = false;
    return matcher;
}
