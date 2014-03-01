// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDIdentityValueTransformerSpec)

describe(@"HYDIdentityValueTransformer", ^{
    __block HYDIdentityValueTransformer *transformer;

    beforeEach(^{
        transformer = [[HYDIdentityValueTransformer alloc] init];
    });

    describe(@"transforming values", ^{
        it(@"should return any object it receives", ^{
            [transformer transformedValue:@1] should equal(@1);
            [transformer transformedValue:@"hello world"] should equal(@"hello world");
            [transformer transformedValue:nil] should be_nil;
        });
    });

    describe(@"reverse transforming values", ^{
        it(@"should return any object it receives", ^{
            [transformer transformedValue:@1] should equal(@1);
            [transformer transformedValue:@"hello world"] should equal(@"hello world");
            [transformer transformedValue:nil] should be_nil;
        });
    });
});

SPEC_END
