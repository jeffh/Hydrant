#import "HYDValueTransformerMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDValueTransformerMapperSpec)

describe(@"HYDValueTransformerMapper", ^{
    __block HYDValueTransformerMapper *mapper;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    context(@"when using a value transformer via name", ^{
        beforeEach(^{
            mapper = HYDMapValue(@"destinationKey", NSNegateBooleanTransformerName);
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
                sourceObject = @YES;
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
                mapper = HYDMapValue(@"destinationKey", @"invalidTransformer");
            } should raise_exception.with_name(NSInvalidArgumentException);
        });
    });
});

SPEC_END
