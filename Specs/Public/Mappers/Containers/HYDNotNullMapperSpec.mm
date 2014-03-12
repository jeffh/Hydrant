// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDNotNullMapperSpec)

describe(@"HYDNotNullMapper", ^{
    __block HYDNotNullMapper *mapper;
    __block HYDSFakeMapper *childMapper;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        childMapper = [[HYDSFakeMapper alloc] init];
        mapper = HYDMapNotNullFrom(childMapper);
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the child mapper returns a non-nil value successfully", ^{
            beforeEach(^{
                childMapper.objectsToReturn = @[@1];
            });

            it(@"should return the value the child mapper returned", ^{
                parsedObject should equal(@1);
            });

            it(@"should not return an error", ^{
                error should be_nil;
            });
        });

        context(@"when the child mapper returns a nil value successfully", ^{
            beforeEach(^{
                childMapper.objectsToReturn = @[[NSNull null]];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidResultingObjectType);
            });
        });

        context(@"when the child mapper returns an error", ^{
            __block HYDError *childError;

            beforeEach(^{
                childError = [HYDError fatalError];
                childMapper.errorsToReturn = @[childError];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return the same error", ^{
                error should be_same_instance_as(childError);
            });
        });
    });

    describe(@"parsing an object without an error pointer", ^{
        beforeEach(^{
            sourceObject = @1;
            childMapper.errorsToReturn = @[[HYDError nonFatalError]];
        });

        it(@"should not explode", ^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:nil];
        });
    });

    describe(@"reverse mapping", ^{
        __block id<HYDMapper> reverseMapper;
        __block HYDSFakeMapper *reverseChildMapper;

        beforeEach(^{
            reverseChildMapper = [[HYDSFakeMapper alloc] init];
            childMapper.reverseMapperToReturn = reverseChildMapper;
            sourceObject = @"valid";

            reverseMapper = [mapper reverseMapper];
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

        context(@"with a nil value", ^{
            beforeEach(^{
                reverseChildMapper.objectsToReturn = @[[NSNull null]];
                parsedObject = [reverseMapper objectFromSourceObject:@1 error:&error];
            });

            it(@"should not allow nil values", ^{
                parsedObject should be_nil;
                error should be_a_fatal_error.with_code(HYDErrorInvalidResultingObjectType);
            });
        });

    });
});

SPEC_END
