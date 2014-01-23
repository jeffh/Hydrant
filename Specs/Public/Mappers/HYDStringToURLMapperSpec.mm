// DO NOT any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringToURLMapperSpec)

describe(@"HYDStringToURLMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        mapper = HYDStringToURL(@"destinationKey");
        [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = @"http://jeffhui.net";
        [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @1;
        [SpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = [NSURL URLWithString:@"http://jeffhui.net"];
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");

    it(@"should report the same destination key", ^{
        [mapper destinationKey] should equal(@"destinationKey");
    });
});

SPEC_END
