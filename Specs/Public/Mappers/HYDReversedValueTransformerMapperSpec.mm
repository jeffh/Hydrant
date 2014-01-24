#import "HYDReversedValueTransformerMapper.h"
#import "HYDIrreversableValueTransformer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDReversedValueTransformerMapperSpec)

describe(@"HYDReversedValueTransformer", ^{
    __block HYDReversedValueTransformerMapper *mapper;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    context(@"when using a value transformer via name", ^{
        beforeEach(^{
            mapper = HYDMapReverseValue(@"destinationKey", NSNegateBooleanTransformerName);
        });

        it(@"should preserve the destination it was given", ^{
            [mapper destinationKey] should equal(@"destinationKey");
        });

        describe(@"parsing an object", ^{
            beforeEach(^{
                sourceObject = @YES;
                parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            });

            it(@"should transform the value it was given", ^{
                parsedObject should equal(@NO);
            });

            it(@"should never error", ^{
                error should be_nil;
            });
        });

        describe(@"reverse mapper", ^{
            __block id<HYDMapper> reverseMapper;

            beforeEach(^{
                reverseMapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
            });

            it(@"should corrected configure the destination key", ^{
                [reverseMapper destinationKey] should equal(@"otherKey");
            });

            it(@"should be the inverse of the original mapper", ^{
                id sourceObject = @YES;
                id result = [mapper objectFromSourceObject:sourceObject error:&error];
                error should be_nil;

                id finalObject = [reverseMapper objectFromSourceObject:result error:&error];
                error should be_nil;
                finalObject should equal(sourceObject);
            });
        });
    });

    context(@"when trying to use a missing value transformer via name", ^{
        it(@"should raise an exception", ^{
            ^{
                mapper = HYDMapReverseValue(@"destinationKey", @"invalidTransformer");
            } should raise_exception.with_name(NSInvalidArgumentException);
        });
    });

    context(@"when trying to use an irreversable value transformer", ^{
        it(@"should raise an exception", ^{
            ^{
                mapper = HYDMapReverseValue(@"key", [[HYDIrreversableValueTransformer alloc] init]);
            } should raise_exception;
        });
    });
});

SPEC_END
