#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDDefaultAccessor.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SHARED_EXAMPLE_GROUPS_BEGIN(HYDSharedMapperExamplesSpec)

sharedExamplesFor(@"a mapper that does the inverse of the original", ^(NSDictionary *scope) {
    __block id<HYDMapper> mapper;
    __block NSArray *childMappers;
    __block id sourceObject;
    __block HYDSFakeMapper *innerMapper;
    __block id<HYDAccessor> reverseAccessor;
    __block void (^sourceObjectsMatcher)(id actual, id expected);

    beforeEach(^{
        mapper = scope[@"mapper"];
        sourceObject = scope[@"sourceObject"];
        childMappers = scope[@"childMappers"];

        // optional
        innerMapper = scope[@"innerMapper"];
        reverseAccessor = scope[@"reverseAccessor"] ?: HYDAccessDefault(@"otherKey");
        sourceObjectsMatcher = scope[@"sourceObjectsMatcher"];

        mapper should_not be_nil;
    });

    __block HYDError *error;
    __block id<HYDMapper> reverseMapper;
    __block id objectToGive;
    __block HYDSFakeMapper *reverseInnerMapper;

    beforeEach(^{
        objectToGive = sourceObject;
        if (innerMapper) {
            objectToGive = [NSObject new];
            innerMapper.objectsToReturn = @[sourceObject];
            reverseInnerMapper = [HYDSFakeMapper new];
            reverseInnerMapper.objectsToReturn = @[objectToGive];
            innerMapper.reverseMapperToReturn = reverseInnerMapper;
        }

        error = nil;
        reverseMapper = [mapper reverseMapper];
    });

    it(@"should be the inverse of the current mapper", ^{
        id parsedObject = [mapper objectFromSourceObject:objectToGive error:&error];
        error should be_nil;

        id result = [reverseMapper objectFromSourceObject:parsedObject error:&error];
        error should be_nil;

        if (innerMapper) {
            innerMapper.sourceObjectsReceived should equal(@[objectToGive]);

            if (sourceObjectsMatcher) {
                [innerMapper.objectsToReturn count] should equal([reverseInnerMapper.sourceObjectsReceived count]);
                sourceObjectsMatcher([innerMapper.objectsToReturn firstObject], [reverseInnerMapper.sourceObjectsReceived firstObject]);
            } else {
                innerMapper.objectsToReturn should equal(reverseInnerMapper.sourceObjectsReceived);
            }
        } else {
            if (sourceObjectsMatcher) {
                sourceObjectsMatcher(innerMapper.objectsToReturn, reverseInnerMapper.sourceObjectsReceived);
            } else {
                result should equal(sourceObject);
            }
        }
    });
});

sharedExamplesFor(@"a mapper that converts from one value to another", ^(NSDictionary *scope) {
    __block id<HYDMapper> mapper;
    __block id validSourceObject;
    __block id invalidSourceObject;
    __block id expectedParsedObject;

    __block HYDSFakeMapper *innerMapper;
    __block HYDErrorCode errorCode;
    __block id<HYDAccessor> destinationAccessor;
    __block void (^parsedObjectsMatcher)(id actual, id expected);

    beforeEach(^{
        mapper = scope[@"mapper"];
        validSourceObject = scope[@"validSourceObject"];
        invalidSourceObject = scope[@"invalidSourceObject"];
        expectedParsedObject = scope[@"expectedParsedObject"];

        // optional
        innerMapper = scope[@"innerMapper"];
        errorCode = scope[@"errorCode"] ? ((HYDErrorCode)[scope[@"errorCode"] integerValue]) : HYDErrorInvalidSourceObjectValue;
        destinationAccessor = scope[@"destinationAccessor"];
        parsedObjectsMatcher = scope[@"parsedObjectsMatcher"];

        mapper should_not be_nil;
    });

    __block id sourceObject;
    __block id parsedObject;
    __block HYDError *error;

    describe(@"parsing the source object", ^{
        __block id objectToGive;

        subjectAction(^{
            objectToGive = sourceObject;
            if (innerMapper) {
                objectToGive = [NSObject new];
                innerMapper.objectsToReturn = @[sourceObject ?: [NSNull null]];
            }
            parsedObject = [mapper objectFromSourceObject:objectToGive error:&error];
        });

        context(@"when a valid source object is provided", ^{
            beforeEach(^{
                sourceObject = validSourceObject;
            });

            it(@"should pass the object it was given to the inner mapper", ^{
                if (innerMapper) {
                    innerMapper.sourceObjectsReceived should equal(@[objectToGive]);
                }
            });

            it(@"should produce a value parsed object", ^{
                if (parsedObjectsMatcher) {
                    parsedObjectsMatcher(parsedObject, expectedParsedObject);
                } else {
                    parsedObject should equal(expectedParsedObject);
                }
            });

            it(@"should return a nil error", ^{
                error should be_nil;
            });
        });

        context(@"when the inner mapper produces a non-fatal error", ^{
            beforeEach(^{
                sourceObject = validSourceObject;
                innerMapper.errorsToReturn = @[[HYDError nonFatalError]];
            });

            it(@"should return the same error", ^{
                if (innerMapper) {
                    error should be_same_instance_as([innerMapper.errorsToReturn firstObject]);
                }
            });

            it(@"should produce a value parsed object", ^{
                if (parsedObjectsMatcher) {
                    parsedObjectsMatcher(parsedObject, expectedParsedObject);
                } else {
                    parsedObject should equal(expectedParsedObject);
                }
            });
        });

        context(@"when the inner mapper produces a fatal error", ^{
            beforeEach(^{
                sourceObject = @1;
                innerMapper.errorsToReturn = @[[HYDError fatalError]];
            });

            it(@"should return the same error", ^{
                if (innerMapper) {
                    error should be_same_instance_as([innerMapper.errorsToReturn firstObject]);
                }
            });

            it(@"should return nil", ^{
                if (innerMapper) {
                    parsedObject should be_nil;
                }
            });
        });

        context(@"when invalid source object is provided", ^{
            beforeEach(^{
                sourceObject = invalidSourceObject;
            });

            it(@"should provide a fatal error", ^{
                error should be_a_fatal_error.with_code(errorCode);
                if (destinationAccessor) {
                    error.userInfo[HYDDestinationAccessorKey] should equal(destinationAccessor);
                }
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when nil is provided", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should produce nil", ^{
                parsedObject should be_nil;
            });

            it(@"should produce a fatal error", ^{
                error should be_a_fatal_error.with_code(errorCode);
                if (destinationAccessor) {
                    error.userInfo[HYDDestinationAccessorKey] should equal(destinationAccessor);
                }
            });
        });
    });

    describe(@"errornously parsing an object without an error pointer", ^{
        it(@"should not explode", ^{
            sourceObject = invalidSourceObject;
            [mapper objectFromSourceObject:sourceObject error:nil];
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = validSourceObject;
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SHARED_EXAMPLE_GROUPS_END
