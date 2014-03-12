// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringToURLMapperSpec)

describe(@"HYDStringToURLMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        mapper = HYDMapStringToURL();
        [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [SpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = @"http://jeffhui.net";
        [SpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @1;
        [SpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = [NSURL URLWithString:@"http://jeffhui.net"];
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
