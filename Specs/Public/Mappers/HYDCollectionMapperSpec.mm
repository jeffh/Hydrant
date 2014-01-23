// DO NOT any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDPerson.h"
#import "HYDFakeMapper.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDCollectionMapperSpec)

describe(@"HYDCollectionMapper", ^{
    __block HYDCollectionMapper *mapper;
    __block HYDFakeMapper *childMapper;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        childMapper = [[HYDFakeMapper alloc] initWithDestinationKey:@"key"];
        mapper = HYDArrayOf(childMapper);
    });

    it(@"should return the destination key of its child mapper", ^{
        [mapper destinationKey] should equal(@"key");
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

        context(@"when the source object is not a fast enumerable", ^{
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
                error should be_a_fatal_error().with_code(HYDErrorMultipleErrors);

                HYDError *wrappedError = [HYDError errorFromError:expectedError
                                              prependingSourceKey:@"0"
                                                andDestinationKey:@"0"
                                          replacementSourceObject:@1
                                                          isFatal:YES];
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[wrappedError]);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the source object's item makes the child mapper produce a non-fatal error", ^{
            __block HYDError *expectedError;

            beforeEach(^{
                expectedError = [HYDError nonFatalError];
                sourceObject = @[@1, @2];
                childMapper.objectsToReturn = @[[NSNull null], @2];
                childMapper.errorsToReturn = @[expectedError, [NSNull null]];
            });

            it(@"should wrap the non-fatal error", ^{
                error should be_a_non_fatal_error().with_code(HYDErrorMultipleErrors);

                HYDError *wrappedError = [HYDError errorFromError:expectedError
                                              prependingSourceKey:@"0"
                                                andDestinationKey:@"0"
                                          replacementSourceObject:@1
                                                          isFatal:NO];
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[wrappedError]);
            });

            it(@"should return the collection without the non-fatal object", ^{
                parsedObject should equal(@[@2]);
            });
        });

        context(@"when the source object is nil", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should not produce an error", ^{
                error should be_nil;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            HYDFakeMapper *reverseChildMapper = [[HYDFakeMapper alloc] initWithDestinationKey:@"otherKey"];
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
