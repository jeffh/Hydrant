// DO NOT any other library headers here to simulate an API user.
#import "JOM.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JOMIdentityMapperSpec)

describe(@"JOMIdentityMapper", ^{
    __block JOMIdentityMapper *mapper;
    __block JOMError *error;
    __block id parsedObject;

    beforeEach(^{
        mapper = [[JOMIdentityMapper alloc] initWithDestinationKey:@"destinationKey"];
    });

    it(@"should have the destinationKey it was provided", ^{
        [mapper destinationKey] should equal(@"destinationKey");
    });

    describe(@"parsing an object", ^{
        beforeEach(^{
            parsedObject = [mapper objectFromSourceObject:@1 error:&error];
        });

        it(@"should never produce an error", ^{
            error should be_nil;
        });

        it(@"should return the same value it was given", ^{
            parsedObject should equal(@1);
        });
    });

    describe(@"reverse mapping", ^{
        __block id<JOMMapper> reverseMapper;

        beforeEach(^{
            reverseMapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
        });

        it(@"should pass the destination key to the reverse mapper", ^{
            [reverseMapper destinationKey] should equal(@"otherKey");
        });

        describe(@"parsing an object", ^{
            beforeEach(^{
                parsedObject = [reverseMapper objectFromSourceObject:@1 error:&error];
            });

            it(@"should never produce an error", ^{
                error should be_nil;
            });

            it(@"should return the same value it was given", ^{
                parsedObject should equal(@1);
            });
        });
    });
});

SPEC_END
