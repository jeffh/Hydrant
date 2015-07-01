#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringToUUIDFormatterSpec)

describe(@"HYDStringToUUIDFormatter", ^{
    __block id<HYDMapper> mapper;
    __block NSUUID *uuid;

    beforeEach(^{
        uuid = [NSUUID UUID];
        mapper = HYDMapStringToUUID();
        [CDRSpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        [CDRSpecHelper specHelper].sharedExampleContext[@"validSourceObject"] = [uuid UUIDString];
        [CDRSpecHelper specHelper].sharedExampleContext[@"invalidSourceObject"] = @1;
        [CDRSpecHelper specHelper].sharedExampleContext[@"expectedParsedObject"] = uuid;
    });

    itShouldBehaveLike(@"a mapper that converts from one value to another");
});

SPEC_END
