// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDFakeMapper.h"
#import "HYDError+Spec.h"

@interface HYDAnotherFakeMapper : HYDFakeMapper
@end
@implementation HYDAnotherFakeMapper
@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDErrorSpec)

describe(@"HYDError", ^{
    __block HYDError *error;
    __block NSError *innerError;

    beforeEach(^{
        innerError = [NSError errorWithDomain:NSCocoaErrorDomain code:2 userInfo:nil];
        error = [HYDError errorWithCode:HYDErrorInvalidSourceObjectValue
                           sourceObject:@1
                              sourceKey:@"sourceKey"
                      destinationObject:@2
                         destinationKey:@"destinationKey"
                                isFatal:YES
                       underlyingErrors:@[innerError]];
    });

    context(@"with the error all filled out", ^{
        it(@"should set the domain", ^{
            error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
        });

        it(@"should store the source object", ^{
            error.userInfo[HYDSourceObjectKey] should equal(@1);
            [error sourceObject] should equal(@1);
        });

        it(@"should store the destination object", ^{
            error.userInfo[HYDDestinationObjectKey] should equal(@2);
            [error destinationObject] should equal(@2);
        });

        it(@"should store fatalness in user info", ^{
            [error.userInfo[HYDIsFatalKey] boolValue] should be_truthy;
            [error isFatal] should be_truthy;
        });

        it(@"should store the source key", ^{
            error.userInfo[HYDSourceKeyPathKey] should equal(@"sourceKey");
            error.sourceKey should equal(@"sourceKey");
        });

        it(@"should store the destination key", ^{
            error.userInfo[HYDDestinationKeyPathKey] should equal(@"destinationKey");
            error.destinationKey should equal(@"destinationKey");
        });

        it(@"should store underlying errors", ^{
            error.userInfo[HYDUnderlyingErrorsKey] should equal(@[innerError]);
            [error underlyingErrors] should equal(@[innerError]);
            error.userInfo[NSUnderlyingErrorKey] should equal(innerError);
        });

        it(@"should have a pretty description", ^{
            [error description] should equal([NSString stringWithFormat:@"HYDErrorDomain code=%lu isFatal=YES reason=\"Could not map from 'sourceKey' to 'destinationKey'\" underlyingErrors=(\n  - %@\n)", (long)error.code, innerError]);
        });
    });

    context(@"with the error mimimally filled out", ^{
        beforeEach(^{
            error = [HYDError errorWithCode:HYDErrorInvalidResultingObjectType
                               sourceObject:nil
                                  sourceKey:nil
                          destinationObject:nil
                             destinationKey:nil
                                    isFatal:NO
                           underlyingErrors:nil];
        });

        it(@"should set the domain", ^{
            error should be_a_non_fatal_error.with_code(HYDErrorInvalidResultingObjectType);
        });

        it(@"should store the source object", ^{
            error.userInfo[HYDSourceObjectKey] should be_nil;
            [error sourceObject] should be_nil;
        });

        it(@"should store the destination object", ^{
            error.userInfo[HYDDestinationObjectKey] should be_nil;
            [error destinationObject] should be_nil;
        });

        it(@"should store fatalness in user info", ^{
            [error.userInfo[HYDIsFatalKey] boolValue] should_not be_truthy;
            [error isFatal] should_not be_truthy;
        });

        it(@"should store the source key", ^{
            error.userInfo[HYDSourceKeyPathKey] should be_nil;
            error.sourceKey should be_nil;
        });

        it(@"should store the destination key", ^{
            error.userInfo[HYDDestinationKeyPathKey] should be_nil;
            error.destinationKey should be_nil;
        });

        it(@"should store underlying errors", ^{
            error.userInfo[HYDUnderlyingErrorsKey] should be_nil;
            [error underlyingErrors] should be_nil;
            error.userInfo[NSUnderlyingErrorKey] should be_nil;
        });

        it(@"should have a pretty description", ^{
            [error description] should equal([NSString stringWithFormat:@"HYDErrorDomain code=%lu isFatal=NO reason=\"Could not map objects\"", (long)error.code]);
        });
    });

    context(@"wrapping the error with no values", ^{
        __block HYDError *wrappedError;

        beforeEach(^{
            wrappedError = [HYDError errorFromError:error
                                prependingSourceKey:nil
                                  andDestinationKey:nil
                            replacementSourceObject:nil
                                            isFatal:YES];
        });

        it(@"should inherit values all the values but fatalness", ^{
            wrappedError should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            wrappedError.underlyingErrors should equal(error.underlyingErrors);
            wrappedError.sourceObject should equal(error.sourceObject);
            wrappedError.destinationObject should equal(error.destinationObject);
            wrappedError.sourceKey should equal(@"sourceKey");
            wrappedError.destinationKey should equal(@"destinationKey");
        });
    });

    context(@"wrapping the error filled out", ^{
        __block HYDError *wrappedError;

        beforeEach(^{
            wrappedError = [HYDError errorFromError:error
                                prependingSourceKey:@"preSource"
                                  andDestinationKey:@"preDestination"
                            replacementSourceObject:@3
                                            isFatal:NO];
        });

        it(@"should inherit values that weren't specified when wrapping", ^{
            wrappedError should be_a_non_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            wrappedError.underlyingErrors should equal(error.underlyingErrors);
            wrappedError.destinationObject should equal(error.destinationObject);
        });

        it(@"should override the source object", ^{
            wrappedError.sourceObject should equal(@3);
        });

        it(@"should prepend the source key", ^{
            wrappedError.sourceKey should equal(@"preSource.sourceKey");
        });

        it(@"should prepend the destination key", ^{
            wrappedError.destinationKey should equal(@"preDestination.destinationKey");
        });

        it(@"should use the specfied fatalness", ^{
            wrappedError.isFatal should_not be_truthy;
        });

        it(@"should have a pretty description", ^{
            [wrappedError description] should equal([NSString stringWithFormat:@"HYDErrorDomain code=%lu isFatal=NO reason=\"Could not map from 'preSource.sourceKey' to 'preDestination.destinationKey'\" underlyingErrors=(\n  - %@\n)", (long)wrappedError.code, innerError]);
        });
    });

    context(@"wrapping the errors in container with all arguments filled", ^{
        __block HYDError *errorContainer;

        beforeEach(^{
            errorContainer = [HYDError errorFromErrors:@[error, [HYDError nonFatalError]]
                                          sourceObject:@"newSource"
                                             sourceKey:@"source"
                                     destinationObject:@"newDestination"
                                        destinationKey:@"destination"
                                               isFatal:NO];
        });

        it(@"should use the multiple error code", ^{
            errorContainer.code should equal(HYDErrorMultipleErrors);
        });

        it(@"should override the source object", ^{
            errorContainer.sourceObject should equal(@"newSource");
        });

        it(@"should override the source key", ^{
            errorContainer.sourceKey should equal(@"source");
        });

        it(@"should override the destination key", ^{
            errorContainer.destinationKey should equal(@"destination");
        });

        it(@"should use the specfied fatalness", ^{
            errorContainer.isFatal should_not be_truthy;
        });

        it(@"should have a pretty description", ^{
            NSString *format = @"HYDErrorDomain code=%lu isFatal=NO reason=\"Multiple parsing errors occurred (fatal=1, total=2)\" underlyingErrors=(\n"
            @"  - HYDErrorDomain code=1 isFatal=YES reason=\"Could not map from 'sourceKey' to 'destinationKey'\" underlyingErrors=(\n"
            @"      - Error Domain=NSCocoaErrorDomain Code=2 \"The operation couldn’t be completed. (Cocoa error 2.)\"\n"
            @"    )\n"
            @"  - HYDErrorDomain code=1 isFatal=NO reason=\"Could not map from 'sourceKey' to 'destinationKey'\"\n"
            @")";
            [errorContainer description] should equal([NSString stringWithFormat:format,
                                                       (long)errorContainer.code, error, [HYDError nonFatalError]]);
        });
    });
});

SPEC_END
