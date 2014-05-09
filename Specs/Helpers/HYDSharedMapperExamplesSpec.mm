#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDDefaultAccessor.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SHARED_EXAMPLE_GROUPS_BEGIN(HYDSharedMapperExamplesSpec)

sharedExamplesFor(@"a mapper that does the inverse of the original", ^(NSDictionary *scope) {
    __block id<HYDMapper> mapper;
    __block NSArray *childMappers;
    __block id sourceObject;
    __block id<HYDAccessor> reverseAccessor;
    __block void (^sourceObjectsMatcher)(id actual, id expected);

    beforeEach(^{
        mapper = scope[@"mapper"];
        sourceObject = scope[@"sourceObject"];
        childMappers = scope[@"childMappers"];

        // optional
        reverseAccessor = scope[@"reverseAccessor"] ?: HYDAccessDefault(@"otherKey");
        sourceObjectsMatcher = scope[@"sourceObjectsMatcher"];
    });

    __block HYDError *error;
    __block id<HYDMapper> reverseMapper;

    beforeEach(^{
        error = nil;
        reverseMapper = [mapper reverseMapper];
    });

    it(@"should be the inverse of the current mapper", ^{
        id parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        error should be_nil;

        id result = [reverseMapper objectFromSourceObject:parsedObject error:&error];
        error should be_nil;

        if (sourceObjectsMatcher) {
            sourceObjectsMatcher(result, sourceObject);
        } else {
            result should equal(sourceObject);
        }
    });
});

sharedExamplesFor(@"a mapper that converts from one value to another", ^(NSDictionary *scope) {
    __block id<HYDMapper> mapper;
    __block id validSourceObject;
    __block id invalidSourceObject;
    __block id expectedParsedObject;
    __block id<HYDAccessor> destinationAccessor;
    __block void (^parsedObjectsMatcher)(id actual, id expected);

    beforeEach(^{
        mapper = scope[@"mapper"];
        destinationAccessor = scope[@"destinationAccessor"];
        validSourceObject = scope[@"validSourceObject"];
        invalidSourceObject = scope[@"invalidSourceObject"];
        expectedParsedObject = scope[@"expectedParsedObject"];

        // optional
        parsedObjectsMatcher = scope[@"parsedObjectsMatcher"];
    });

    __block id sourceObject;
    __block id parsedObject;
    __block HYDError *error;

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when a valid source object is provided", ^{
            beforeEach(^{
                sourceObject = validSourceObject;
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

        context(@"when invalid source object is provided", ^{
            beforeEach(^{
                sourceObject = invalidSourceObject;
            });

            it(@"should provide a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
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
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
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
