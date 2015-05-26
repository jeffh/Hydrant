#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDEnumMapperSpec)

describe(@"HYDEnumMapper", ^{
    __block id<HYDMapper> mapper;
    __block HYDError *error;

    beforeEach(^{
        error = nil;
        mapper = HYDMapEnum(@{@(HYDSPersonGenderUnknown) : @"Unknown",
                              @(HYDSPersonGenderMale) : @"Male",
                              @(HYDSPersonGenderFemale) : @"Female"});
    });

    describe(@"parsing the source object", ^{
        __block id sourceObject;
        __block id parsedObject;

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when an enumerable value is provided", ^{
            beforeEach(^{
                sourceObject = @(HYDSPersonGenderFemale);
            });

            it(@"should not have any error", ^{
                error should be_nil;
            });

            it(@"should produce the string equivalent", ^{
                parsedObject should equal(@"Female");
            });
        });

        context(@"when an unknown value is provided", ^{
            beforeEach(^{
                sourceObject = @(99);
            });

            it(@"should produce a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            });
        });

        context(@"when nil is provided", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should not have any error", ^{
                error should_not be_nil;
            });

            it(@"should produce nil", ^{
                parsedObject should be_nil;
            });
        });
    });

    describe(@"errornously parsing an object without an error pointer", ^{
        it(@"should not explode", ^{
            [mapper objectFromSourceObject:@99 error:nil];
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
        });

        context(@"with a female value", ^{
            beforeEach(^{
                [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @(HYDSPersonGenderFemale);
            });

            itShouldBehaveLike(@"a mapper that does the inverse of the original");
        });

        context(@"with a male value", ^{
            beforeEach(^{
                [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @(HYDSPersonGenderMale);
            });

            itShouldBehaveLike(@"a mapper that does the inverse of the original");
        });

        context(@"with an unknown value", ^{
            beforeEach(^{
                [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @(HYDSPersonGenderUnknown);
            });

            itShouldBehaveLike(@"a mapper that does the inverse of the original");
        });
    });
});

SPEC_END
