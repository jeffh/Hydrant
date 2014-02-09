// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDFakeFormatter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringToObjectFormatterMapperSpec)

describe(@"HYDStringToObjectFormatterMapper", ^{
    __block HYDStringToObjectFormatterMapper *mapper;
    __block HYDFakeFormatter *formatter;
    __block HYDError *error;

    beforeEach(^{
        formatter = [[HYDFakeFormatter alloc] init];
        mapper = HYDMapStringToObjectByFormatter(@"destinationAccessor", formatter);
    });

    it(@"should return the same destination key it was given", ^{
        mapper.destinationAccessor should equal(HYDAccessKey(@"destinationAccessor"));
    });

    describe(@"parsing an object", ^{
        __block id sourceObject;
        __block id parsedObject;

        beforeEach(^{
            sourceObject = @"HI";
        });

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the source object is valid", ^{
            beforeEach(^{
                formatter.objectToReturn = @1;
                formatter.returnSuccess = YES;
            });

            it(@"should return the formatter's object", ^{
                parsedObject should equal(@1);
            });

            it(@"should not return any error", ^{
                error should be_nil;
            });
        });

        context(@"when the source object is invalid", ^{
            beforeEach(^{
                formatter.errorDescriptionToReturn = @"No cheese";
                formatter.returnSuccess = NO;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            });

            it(@"should contain the error description as an underlying error", ^{
                NSError *originalError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:@{NSLocalizedDescriptionKey: @"No cheese"}];
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[originalError]);
                error.userInfo[NSUnderlyingErrorKey] should equal(originalError);
            });
        });

        context(@"when the source object is NSNull", ^{
            beforeEach(^{
                sourceObject = [NSNull null];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should contain the error description", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            });
        });

        context(@"when the source object is nil", ^{
            beforeEach(^{
                formatter.returnSuccess = NO;
                sourceObject = nil;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            });

            it(@"should not crash by invoking the formatter", ^{
                formatter.didReceiveString should_not be_truthy;
            });

            it(@"should contain the error description as an underlying error", ^{
                NSError *originalError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:@{NSLocalizedDescriptionKey: @"Failed to format string into object: (null) for key 'destinationAccessor'"}];
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[originalError]);
                error.userInfo[NSUnderlyingErrorKey] should equal(originalError);
            });
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            mapper = HYDMapStringToObjectByFormatter(@"destinationAccessor", [[NSNumberFormatter alloc] init]);
            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @"1";
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
