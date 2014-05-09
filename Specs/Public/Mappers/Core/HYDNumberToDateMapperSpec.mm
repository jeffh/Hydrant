// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDNumberToDateMapperSpec)

describe(@"HYDNumberToDateMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        mapper = HYDMapNumberToDateSince1970(HYDDateTimeUnitMilliseconds);
        [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = @1000.1;
        [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = [NSObject new];
        [SpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = [NSDate dateWithTimeIntervalSince1970:1.0001];
        [SpecHelper specHelper].sharedExampleContext[@"sourceObjectsMatcher"] = ^(NSNumber *actual, NSNumber *expected) {
            [actual doubleValue] should be_close_to([expected doubleValue]);
        };
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
