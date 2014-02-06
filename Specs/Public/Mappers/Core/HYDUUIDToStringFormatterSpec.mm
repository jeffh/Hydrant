// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDUUIDToStringFormatterSpec)

describe(@"HYDUUIDToStringFormatter", ^{
    __block id<HYDMapper> mapper;
    __block NSUUID *uuid;

    beforeEach(^{
        uuid = [NSUUID UUID];
        mapper = HYDMapUUIDToString(@"destinationKey");
        [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [SpecHelper specHelper].sharedExampleContext[@"destinationKey"] = @"destinationKey";
        [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = uuid;
        [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @1;
        [SpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = [uuid UUIDString];
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
