// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringValueTransformerSpec)

describe(@"HYDStringValueTransformer", ^{
    __block HYDStringValueTransformer *transformer;

    beforeEach(^{
        transformer = [[HYDStringValueTransformer alloc] init];
    });

    it(@"should return strings as-is", ^{
        [transformer transformedValue:@"foo"] should equal(@"foo");
    });

    it(@"should return numbers as strings", ^{
        [transformer transformedValue:@1] should equal(@"1");
    });

    it(@"should return [NSNull null] as nil", ^{
        [transformer transformedValue:[NSNull null]] should be_nil;
    });
});

SPEC_END
