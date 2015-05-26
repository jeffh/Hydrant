#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeFormatter.h"
#import "HYDSFakeMapper.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDStringToObjectFormatterMapperSpec)

describe(@"HYDStringToObjectFormatterMapper", ^{
    __block id<HYDMapper> mapper;
    __block HYDSFakeFormatter *formatter;
    __block HYDError *error;
    __block HYDSFakeMapper *innerMapper;

    beforeEach(^{
        innerMapper = [[HYDSFakeMapper alloc] init];
        formatter = [[HYDSFakeFormatter alloc] init];
        mapper = HYDMapStringToObjectByFormatter(innerMapper, formatter);
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
                innerMapper.objectsToReturn = @[@"Dog"];
                formatter.objectToReturn = @1;
                formatter.returnSuccess = YES;
            });

            it(@"should pass along the inner mapper's value to the formatter", ^{
                formatter.stringReceived should equal(@"Dog");
            });

            it(@"should pass the source object to the inner mapper", ^{
                innerMapper.sourceObjectsReceived should equal(@[sourceObject]);
            });

            it(@"should return the formatter's object", ^{
                parsedObject should equal(@1);
            });

            it(@"should not return any error", ^{
                error should be_nil;
            });
        });

        context(@"when the source object makes the inner mapper return a nonfatal error", ^{
            beforeEach(^{
                innerMapper.objectsToReturn = @[@"Dog"];
                innerMapper.errorsToReturn = @[[HYDError nonFatalError]];
                formatter.objectToReturn = @1;
                formatter.returnSuccess = YES;
            });

            it(@"should return a fatal error", ^{
                error should equal([HYDError nonFatalError]);
            });

            it(@"should pass along the inner mapper's object to the formatter", ^{
                formatter.stringReceived should equal(@"Dog");
            });

            it(@"should return the formatter value", ^{
                parsedObject should equal(@1);
            });
        });

        context(@"when the source object makes the inner mapper return a fatal error", ^{
            beforeEach(^{
                innerMapper.errorsToReturn = @[[HYDError fatalError]];
                formatter.returnSuccess = NO;
            });

            it(@"should return a fatal error", ^{
                error should equal([HYDError fatalError]);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the source object is invalid for the formatter", ^{
            beforeEach(^{
                innerMapper.objectsToReturn = @[@"Lo"];
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
                NSError *originalError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFormattingError userInfo:@{NSLocalizedDescriptionKey: @"Failed to format string into object: (null)"}];
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[originalError]);
                error.userInfo[NSUnderlyingErrorKey] should equal(originalError);
            });
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            mapper = HYDMapStringToObjectByFormatter([[NSNumberFormatter alloc] init]);
            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @"1";
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
