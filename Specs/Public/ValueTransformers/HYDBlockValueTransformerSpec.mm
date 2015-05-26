#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDBlockValueTransformerSpec)

describe(@"HYDBlockValueTransformer", ^{
    __block HYDBlockValueTransformer *transformer;
    __block id blockValue;
    __block id reversedBlockValue;

    beforeEach(^{
        blockValue = nil;
        reversedBlockValue = nil;

        transformer = [[HYDBlockValueTransformer alloc] initWithBlock:^id(id value) {
            blockValue = value;
            return @1;
        } reversedBlock:^id(id value) {
            reversedBlockValue = value;
            return @2;
        }];
    });

    describe(@"transforming a value", ^{
        __block id result;

        subjectAction(^{
            result = [transformer transformedValue:@"HI"];
        });

        context(@"when the block is provided", ^{
            it(@"should use the block to produce the new value", ^{
                result should equal(@1);
            });

            it(@"should pass along the value it received to the block", ^{
                blockValue should equal(@"HI");
            });
        });

        context(@"when the block is not provided", ^{
            beforeEach(^{
                transformer = [[HYDBlockValueTransformer alloc] initWithBlock:nil reversedBlock:nil];
            });

            it(@"should return nil", ^{
                result should be_nil;
            });
        });
    });

    describe(@"reverse transforming a value", ^{
        __block id result;

        subjectAction(^{
            result = [transformer reverseTransformedValue:@"HI"];
        });

        context(@"when the reverse block is provided", ^{
            it(@"should use the block to produce the new value", ^{
                result should equal(@2);
            });

            it(@"should pass along the value it received to the block", ^{
                reversedBlockValue should equal(@"HI");
            });
        });

        context(@"when the reverse block is not provided", ^{
            beforeEach(^{
                transformer = [[HYDBlockValueTransformer alloc] initWithBlock:nil reversedBlock:nil];
            });

            it(@"should return nil", ^{
                result should be_nil;
            });
        });
    });
});

SPEC_END
