#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSPerson.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDOptionalTypedMapperSpec)

describe(@"HYDOptionalTypedMapper", ^{
    __block id<HYDMapper> mapper;
    __block HYDError *error;
    __block id result;

    beforeEach(^{
        mapper = HYDMapObject([HYDSPerson class],
                              @{@"first_name": @[HYDMapOptionally(), @"firstName"]});

        id sourceObject = @{@"first_name": @1};

        result = [mapper objectFromSourceObject:sourceObject error:&error];
    });

    it(@"should map correctly", ^{
        result should equal([HYDSPerson new]);
        error should be_a_non_fatal_error;
    });
});

SPEC_END
