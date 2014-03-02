// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSIrreversableValueTransformer.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDReversedValueTransformerSpec)

describe(@"HYDReversedValueTransformer", ^{
    __block HYDReversedValueTransformer *transformer;
    __block NSValueTransformer *wrappedTransformer;

    beforeEach(^{
        wrappedTransformer = nice_fake_for([NSValueTransformer class]);
        transformer = [[HYDReversedValueTransformer alloc] initWithValueTransformer:wrappedTransformer];
    });

    context(@"when the wrapped transformer does not support reversability", ^{
        it(@"should raise an exception", ^{
            wrappedTransformer = [HYDSIrreversableValueTransformer new];
            ^{
                transformer = [[HYDReversedValueTransformer alloc] initWithValueTransformer:wrappedTransformer];
            } should raise_exception;
        });
    });

    describe(@"transforming a value", ^{
        __block id result;

        subjectAction(^{
            wrappedTransformer stub_method(@selector(reverseTransformedValue:)).and_return(@"food");
            result = [transformer transformedValue:@1];
        });

        it(@"should pass through to the wrapped transformer's reverseTransformValue", ^{
            result should equal(@"food");
        });
    });

    describe(@"reverse transforming a value", ^{
        __block id result;

        subjectAction(^{
            wrappedTransformer stub_method(@selector(transformedValue:)).and_return(@"food");
            result = [transformer reverseTransformedValue:@1];
        });

        it(@"should pass through to the wrapped transformer's reverseTransformValue", ^{
            result should equal(@"food");
        });
    });
});

SPEC_END
