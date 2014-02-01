// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDFakeMapper.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDOptionalMapperSpec)

describe(@"HYDOptionalMapper", ^{
    __block HYDOptionalMapper *mapper;
    __block HYDFakeMapper *childMapper;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        childMapper = [[HYDFakeMapper alloc] init];
        childMapper.destinationKey = @"destinationKey";
        mapper = HYDMapOptionallyWithDefault(childMapper, @42);
    });

    it(@"should ask the child mapper for the destination key", ^{
        mapper.destinationKey should equal(@"destinationKey");
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the source object is valid to the child mapper", ^{
            beforeEach(^{
                sourceObject = @"valid";
                childMapper.errorsToReturn = @[[NSNull null]];
                childMapper.objectsToReturn = @[@1];
            });

            it(@"should tell its child mappers that it is the current root mapper", ^{
                childMapper.sourceObjectsReceived[0] should be_same_instance_as(sourceObject);
            });

            it(@"should not produce an error", ^{
                error should be_nil;
            });

            it(@"should return the child mapper's value", ^{
                parsedObject should equal(@1);
            });
        });

        context(@"when the source object produces a fatal error to the child mapper", ^{
            beforeEach(^{
                sourceObject = @"invalid";
                childMapper.errorsToReturn = @[[HYDError fatalError]];
            });

            it(@"should return the default value", ^{
                parsedObject should equal(@42);
            });

            it(@"should report a non-fatal error", ^{
                error should be_a_non_fatal_error().with_code(HYDErrorInvalidSourceObjectType);
            });
        });
    });

    describe(@"errornously parsing an object without an error pointer", ^{
        it(@"should not explode", ^{
            childMapper.errorsToReturn = @[[HYDError fatalError]];
            [mapper objectFromSourceObject:@"invalid" error:nil];
        });
    });

    describe(@"reverse mapping", ^{
        __block id<HYDMapper> reverseMapper;
        __block HYDFakeMapper *reverseChildMapper;

        beforeEach(^{
            reverseChildMapper = [[HYDFakeMapper alloc] initWithDestinationKey:@"otherKey"];
            childMapper.reverseMapperToReturn = reverseChildMapper;
            sourceObject = @"valid";

            reverseMapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
        });

        it(@"should have received the other destination key", ^{
            childMapper.reverseMapperDestinationKeyReceived should equal(@"otherKey");
        });

        context(@"with a good source object", ^{
            beforeEach(^{
                reverseChildMapper.objectsToReturn = @[sourceObject];
                childMapper.objectsToReturn = @[@1];
            });

            it(@"should be in the inverse of the current mapper", ^{
                id inputObject = [mapper objectFromSourceObject:sourceObject error:&error];
                error should be_nil;

                id result = [reverseMapper objectFromSourceObject:inputObject error:&error];
                result should equal(sourceObject);
                error should be_nil;
            });
        });

        context(@"with a bad source object", ^{
            beforeEach(^{
                reverseChildMapper.errorsToReturn = @[[HYDError fatalError]];
                parsedObject = [reverseMapper objectFromSourceObject:@1 error:&error];
            });

            it(@"should emit a non-fatal error", ^{
                error should be_a_non_fatal_error().with_code(HYDErrorInvalidSourceObjectType);
            });

            it(@"should return the default value", ^{
                parsedObject should equal(@42);
            });
        });
    });
});

SPEC_END
