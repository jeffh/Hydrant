#import <Foundation/Foundation.h>

#import "JKSError.h"

class BeAnError : public Cedar::Matchers::Base<> {
public:
    BeAnError() : Base<>(), checkErrorCode(false), expectedDomain(nil), userInfoSubset(nil), checkFatality(false) {};
    ~BeAnError(){}

    bool matches(const JKSError *) const;

    BeAnError & with_code(NSInteger code);
    BeAnError & with_domain(NSString *domain);
    BeAnError & and_has_info(NSDictionary *userInfoPartial);
    BeAnError & and_has_source_key(NSString *sourceKey);
    BeAnError & and_has_destination_key(NSString *sourceKey);
    BeAnError & and_fatal();
    BeAnError & and_non_fatal();

protected:
    virtual NSString * failure_message_end() const;
    bool domain_matches(const JKSError *error) const;
    bool code_matches(const JKSError *error) const;
    bool fatality_matches(const JKSError *error) const;
    bool subset_of_userinfo_matches(const JKSError *error) const;

private:
    BOOL checkFatality;
    BOOL isFatal;
    BOOL checkErrorCode;
    NSInteger expectedErrorCode;
    NSString *expectedDomain;
    NSMutableDictionary *userInfoSubset;
};

BeAnError be_an_error();
BeAnError be_a_fatal_error();
BeAnError be_a_non_fatal_error();
