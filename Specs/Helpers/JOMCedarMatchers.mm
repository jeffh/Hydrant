#import "JOMCedarMatchers.h"
#import "JOMError.h"

BeAnError be_an_error() {
    return BeAnError().with_domain(JOMErrorDomain);
}

BeAnError be_a_fatal_error() {
    return be_an_error().and_fatal();
}

BeAnError be_a_non_fatal_error() {
    return be_an_error().and_non_fatal();
}

bool BeAnError::matches(const JOMError *error) const {
    return (this->domain_matches(error) &&
            this->code_matches(error) &&
            this->fatality_matches(error) &&
            this->subset_of_userinfo_matches(error)
            );
}

bool BeAnError::domain_matches(const JOMError *error) const {
    return !this->expectedDomain || [this->expectedDomain isEqual:error.domain];
}

bool BeAnError::code_matches(const JOMError *error) const {
    return !this->checkErrorCode || this->expectedErrorCode == error.code;
}

bool BeAnError::fatality_matches(const JOMError *error) const {
    return !this->checkFatality || this->isFatal == error.isFatal;
}

bool BeAnError::subset_of_userinfo_matches(const JOMError *error) const {
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
    return [NSString stringWithFormat:@"be an error (domain=%@, code=%ld, userInfo=%@, isFatal=%d)",
            this->expectedDomain, (long)this->expectedErrorCode, this->userInfoSubset, this->isFatal];
}

BeAnError & BeAnError::with_code(NSInteger code) {
    this->checkErrorCode = true;
    this->expectedErrorCode = code;
    return *this;
}

BeAnError & BeAnError::with_domain(NSString *domain) {
    this->expectedDomain = domain;
    return *this;
}

BeAnError & BeAnError::and_fatal() {
    this->checkFatality = true;
    this->isFatal = true;
    return *this;
}

BeAnError & BeAnError::and_non_fatal() {
    this->checkFatality = true;
    this->isFatal = false;
    return *this;
}