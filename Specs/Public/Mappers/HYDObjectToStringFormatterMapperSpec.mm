// DO NOT any other library headers here to simulate an API user.
#import "Hydrant.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDObjectToStringFormatterMapperSpec)

describe(@"HYDObjectToStringFormatterMapper", ^{
    __block HYDObjectToStringFormatterMapper *mapper;
    __block NSFormatter *formatter;
    __block HYDError *error;

    beforeEach(^{
        formatter = nice_fake_for([NSFormatter class]);
        mapper = HYDMapObjectToStringByFormatter(@"destinationKey", formatter);
    });

    it(@"should return the same destination key it was given", ^{
        mapper.destinationKey should equal(@"destinationKey");
    });

    describe(@"parsing an object", ^{
        __block id sourceObject;
        __block id parsedObject;

        beforeEach(^{
            sourceObject = @1;
        });

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the source object is valid", ^{
            beforeEach(^{
                formatter stub_method(@selector(stringForObjectValue:)).and_return(@"Yep");
            });

            it(@"should return the formatter's object", ^{
                parsedObject should equal(@"Yep");
            });

            it(@"should not return any error", ^{
                error should be_nil;
            });
        });

        context(@"when the source object is invalid", ^{
            beforeEach(^{
                formatter stub_method(@selector(stringForObjectValue:)).and_return((id)nil);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error().with_code(HYDErrorInvalidSourceObjectValue);
            });
        });

        context(@"when the source object is nil", ^{
            beforeEach(^{
                formatter stub_method(@selector(stringForObjectValue:)).and_return((id)nil);
                sourceObject = nil;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error().with_code(HYDErrorInvalidSourceObjectValue);
            });
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            mapper = HYDMapObjectToStringByFormatter(@"destinationKey", [[NSNumberFormatter alloc] init]);
            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @1;
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
