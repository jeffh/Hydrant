// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDCollectionMapperSpec)

describe(@"HYDCollectionMapper", ^{
    __block HYDCollectionMapper *mapper;
    __block HYDSFakeMapper *childMapper;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        childMapper = [[HYDSFakeMapper alloc] init];
        mapper = HYDMapArrayOf(childMapper);
    });

    context(@"constructing with a type that doesn't support HYDCollection", ^{
        it(@"should raise an exception on creation", ^{
            ^{
                id<HYDMapper> m = [[HYDCollectionMapper alloc] initWithItemMapper:nil sourceCollectionClass:[NSNumber class] destinationCollectionClass:[NSArray class]];
                [m objectFromSourceObject:nil error:nil];
            } should raise_exception;
        });
    });

    context(@"constructing with a type that doesn't support HYDCollection", ^{
        it(@"should raise an exception on creation", ^{
            ^{
                id<HYDMapper> m = [[HYDCollectionMapper alloc] initWithItemMapper:nil sourceCollectionClass:[NSNumber class] destinationCollectionClass:[NSArray class]];
                [m objectFromSourceObject:nil error:nil];
            } should raise_exception;
        });
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the source object is valid for the child mapper", ^{
            beforeEach(^{
                sourceObject = @[@1];
                childMapper.objectsToReturn = @[@"1"];
            });

            it(@"should return the child mapper's resulting object in an array", ^{
                childMapper.sourceObjectsReceived should equal(@[@1]);
                parsedObject should equal(@[@"1"]);
            });

            it(@"should not return any errors", ^{
                error should be_nil;
            });
        });

        context(@"when the source object is valid for the child mapper and it returns nil", ^{
            beforeEach(^{
                sourceObject = @[@1];
                childMapper.objectsToReturn = @[[NSNull null]];
            });

            it(@"should return the child mapper's resulting object in an array", ^{
                childMapper.sourceObjectsReceived should equal(@[@1]);
                parsedObject should equal(@[[NSNull null]]);
            });

            it(@"should not return any errors", ^{
                error should be_nil;
            });
        });

        context(@"when the source object is not the correct class", ^{
            beforeEach(^{
                sourceObject = [NSSet set];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectType);
            });
        });

        context(@"when the source object does not support HYDCollection", ^{
            beforeEach(^{
                sourceObject = @1;
            });

            it(@"should return a fatal error", ^{
                error.domain should equal(HYDErrorDomain);
                error.code should equal(HYDErrorInvalidSourceObjectType);
                error.isFatal should be_truthy;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the source object's item makes the child mapper produce a fatal error", ^{
            __block HYDError *expectedError;

            beforeEach(^{
                expectedError = [HYDError fatalError];
                sourceObject = @[@1, @2];
                childMapper.objectsToReturn = @[[NSNull null], @2];
                childMapper.errorsToReturn = @[expectedError, [NSNull null]];
            });

            it(@"should wrap the fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorMultipleErrors);

                HYDError *wrappedError = [HYDError errorFromError:expectedError
                                         prependingSourceAccessor:HYDAccessKey(@"0")
                                           andDestinationAccessor:HYDAccessKey(@"0")
                                          replacementSourceObject:@1
                                                          isFatal:YES];
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[wrappedError]);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the source object's item makes the child mapper produce a non-fatal error with a nil", ^{
            __block HYDError *expectedError;

            beforeEach(^{
                expectedError = [HYDError nonFatalError];
                sourceObject = @[@1, @2];
                childMapper.objectsToReturn = @[[NSNull null], @2];
                childMapper.errorsToReturn = @[expectedError, [NSNull null]];
            });

            it(@"should wrap the non-fatal error", ^{
                error should be_a_non_fatal_error.with_code(HYDErrorMultipleErrors);

                HYDError *wrappedError = [HYDError errorFromError:expectedError
                                         prependingSourceAccessor:HYDAccessKey(@"0")
                                           andDestinationAccessor:HYDAccessKey(@"0")
                                          replacementSourceObject:@1
                                                          isFatal:NO];
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[wrappedError]);
            });

            it(@"should return the collection without the object in the collection", ^{
                parsedObject should equal(@[@2]);
            });
        });

        context(@"when the source object's item makes the child mapper produce a non-fatal error with an object", ^{
            __block HYDError *expectedError;

            beforeEach(^{
                expectedError = [HYDError nonFatalError];
                sourceObject = @[@1, @2];
                childMapper.objectsToReturn = @[@1, @2];
                childMapper.errorsToReturn = @[expectedError, [NSNull null]];
            });

            it(@"should wrap the non-fatal error", ^{
                error should be_a_non_fatal_error.with_code(HYDErrorMultipleErrors);

                HYDError *wrappedError = [HYDError errorFromError:expectedError
                                         prependingSourceAccessor:HYDAccessKey(@"0")
                                           andDestinationAccessor:HYDAccessKey(@"0")
                                          replacementSourceObject:@1
                                                          isFatal:NO];
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[wrappedError]);
            });

            it(@"should return the collection with the non-fatal object", ^{
                parsedObject should equal(@[@1, @2]);
            });
        });

        context(@"when the source object is nil", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should produce an error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectType);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });
    });

    describe(@"errornously parsing an object that's not a HYDCollection", ^{
        it(@"should not explode", ^{
            [mapper objectFromSourceObject:@1 error:nil];
        });
    });

    describe(@"errornously parsing an object without an error pointer", ^{
        it(@"should not explode", ^{
            childMapper.errorsToReturn = @[[HYDError nonFatalError], [HYDError fatalError]];
            [mapper objectFromSourceObject:@[@1, @2] error:nil];
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            HYDSFakeMapper *reverseChildMapper = [[HYDSFakeMapper alloc] init];
            childMapper.reverseMapperToReturn = reverseChildMapper;
            childMapper.objectsToReturn = @[@2];
            reverseChildMapper.objectsToReturn = @[@1];

            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @[@1];
            [SpecHelper specHelper].sharedExampleContext[@"childMappers"] = @[childMapper];
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
