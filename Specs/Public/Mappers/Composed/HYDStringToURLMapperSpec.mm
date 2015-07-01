#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringToURLMapperSpec)

describe(@"HYDStringToURLMapper", ^{
    __block id<HYDMapper> mapper;

    beforeEach(^{
        mapper = HYDMapStringToURL();
        [CDRSpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [CDRSpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = @"http://jeffhui.net";
        [CDRSpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @1;
        [CDRSpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = [NSURL URLWithString:@"http://jeffhui.net"];
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
