// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDError+Spec.h"


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
                         sourceAccessor:HYDAccessKey(@"sourceAccessor")
                      destinationObject:@2
                    destinationAccessor:HYDAccessKey(@"destinationAccessor")
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
            error.userInfo[HYDSourceAccessorKey] should equal(HYDAccessKey(@"sourceAccessor"));
            error.sourceAccessor should equal(HYDAccessKey(@"sourceAccessor"));
        });

        it(@"should store the destination key", ^{
            error.userInfo[HYDDestinationAccessorKey] should equal(HYDAccessKey(@"destinationAccessor"));
            error.destinationAccessor should equal(HYDAccessKey(@"destinationAccessor"));
        });

        it(@"should store underlying errors", ^{
            error.userInfo[HYDUnderlyingErrorsKey] should equal(@[innerError]);
            [error underlyingErrors] should equal(@[innerError]);
            error.userInfo[NSUnderlyingErrorKey] should equal(innerError);
        });

        it(@"should have a pretty description with fatal errors", ^{
            [error description] should equal([NSString stringWithFormat:@"[FATAL] HYDErrorDomain (code=HYDErrorInvalidSourceObjectValue) because \"Could not map from 'sourceAccessor' to 'destinationAccessor'\"\n"
                                              @"  - [%@] (code=%ld) %@\n", innerError.domain, (long)innerError.code, innerError.localizedDescription]);
        });

        it(@"should have a pretty description with all errors", ^{
            [error fullDescription] should equal([error description]);
        });

        it(@"should have a pretty recursive description with fatal errors", ^{
            [error recursiveDescription] should equal([NSString stringWithFormat:@"HYDErrorDomain code=%lu isFatal=YES reason=\"Could not map from 'sourceAccessor' to 'destinationAccessor'\" underlyingFatalErrors=(\n  - %@\n)", (long)error.code, innerError]);
        });

        it(@"should have a pretty recursive description with all errors", ^{
            [error fullRecursiveDescription] should equal([NSString stringWithFormat:@"HYDErrorDomain code=%lu isFatal=YES reason=\"Could not map from 'sourceAccessor' to 'destinationAccessor'\" underlyingErrors=(\n  - %@\n)", (long)error.code, innerError]);
        });
    });

    context(@"with the error mimimally filled out", ^{
        beforeEach(^{
            error = [HYDError errorWithCode:HYDErrorInvalidResultingObjectType
                               sourceObject:nil
                             sourceAccessor:nil
                          destinationObject:nil
                        destinationAccessor:nil
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
            error.userInfo[HYDSourceAccessorKey] should be_nil;
            error.sourceAccessor should be_nil;
        });

        it(@"should store the destination key", ^{
            error.userInfo[HYDDestinationAccessorKey] should be_nil;
            error.destinationAccessor should be_nil;
        });

        it(@"should store underlying errors", ^{
            error.userInfo[HYDUnderlyingErrorsKey] should be_nil;
            [error underlyingErrors] should be_nil;
            error.userInfo[NSUnderlyingErrorKey] should be_nil;
        });

        it(@"should have a pretty description with fatal errors", ^{
            [error description] should equal(@"[non-fatal] HYDErrorDomain (code=HYDErrorInvalidResultingObjectType) because \"Could not map objects\"\n");
        });

        it(@"should have a pretty description with fatal errors", ^{
            [error fullDescription] should equal([error description]);
        });

        it(@"should have a pretty recursive description with fatal errors", ^{
            [error recursiveDescription] should equal([NSString stringWithFormat:@"HYDErrorDomain code=%lu isFatal=NO reason=\"Could not map objects\"", (long)error.code]);
        });

        it(@"should have a pretty recursive description with all errors", ^{
            [error fullRecursiveDescription] should equal([NSString stringWithFormat:@"HYDErrorDomain code=%lu isFatal=NO reason=\"Could not map objects\"", (long)error.code]);
        });
    });

    context(@"wrapping the error with no values", ^{
        __block HYDError *wrappedError;

        beforeEach(^{
            wrappedError = [HYDError errorFromError:error
                           prependingSourceAccessor:nil
                             andDestinationAccessor:nil
                            replacementSourceObject:nil
                                            isFatal:YES];
        });

        it(@"should inherit values all the values but fatalness", ^{
            wrappedError should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            wrappedError.underlyingErrors should equal(error.underlyingErrors);
            wrappedError.sourceObject should equal(error.sourceObject);
            wrappedError.destinationObject should equal(error.destinationObject);
            wrappedError.sourceAccessor should equal(HYDAccessKey(@"sourceAccessor"));
            wrappedError.destinationAccessor should equal(HYDAccessKey(@"destinationAccessor"));
        });
    });

    context(@"wrapping the error filled out", ^{
        __block HYDError *wrappedError;

        beforeEach(^{
            wrappedError = [HYDError errorFromError:error
                           prependingSourceAccessor:HYDAccessKey(@"preSource")
                             andDestinationAccessor:HYDAccessKey(@"preDestination")
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
            wrappedError.sourceAccessor should equal(HYDAccessKeyPath(@"preSource.sourceAccessor"));
        });

        it(@"should prepend the destination key", ^{
            wrappedError.destinationAccessor should equal(HYDAccessKeyPath(@"preDestination.destinationAccessor"));
        });

        it(@"should use the specfied fatalness", ^{
            wrappedError.isFatal should_not be_truthy;
        });

        it(@"should have a pretty description with fatal errors", ^{
            [wrappedError description] should equal(@"[non-fatal] HYDErrorDomain (code=HYDErrorInvalidSourceObjectValue) because \"Could not map from 'preSource.sourceAccessor' to 'preDestination.destinationAccessor'\"\n");
        });

        it(@"should have a pretty description with all errors", ^{
            [wrappedError fullDescription] should equal([NSString stringWithFormat:@"[non-fatal] HYDErrorDomain (code=HYDErrorInvalidSourceObjectValue) because \"Could not map from 'preSource.sourceAccessor' to 'preDestination.destinationAccessor'\"\n"
                                                         @"  - [%@] (code=%ld) %@\n",
                                                         innerError.domain, (long)innerError.code, innerError.localizedDescription]);
        });

        it(@"should have a pretty recursive description with fatal errors", ^{
            [wrappedError recursiveDescription] should equal([NSString stringWithFormat:@"HYDErrorDomain code=%lu isFatal=NO reason=\"Could not map from 'preSource.sourceAccessor' to 'preDestination.destinationAccessor'\"", (long)wrappedError.code]);
        });

        it(@"should have a pretty recursive description with all errors", ^{
            [wrappedError fullRecursiveDescription] should equal([NSString stringWithFormat:@"HYDErrorDomain code=%lu isFatal=NO reason=\"Could not map from 'preSource.sourceAccessor' to 'preDestination.destinationAccessor'\" underlyingErrors=(\n  - %@\n)", (long)wrappedError.code, innerError]);
        });
    });

    context(@"wrapping the errors in container with all arguments filled", ^{
        __block HYDError *errorContainer;

        beforeEach(^{
            errorContainer = [HYDError errorFromErrors:@[error, [HYDError nonFatalError]]
                                          sourceObject:@"newSource"
                                        sourceAccessor:HYDAccessKey(@"source")
                                     destinationObject:@"newDestination"
                                   destinationAccessor:HYDAccessKey(@"destination")
                                               isFatal:NO];
        });

        it(@"should use the multiple error code", ^{
            errorContainer.code should equal(HYDErrorMultipleErrors);
        });

        it(@"should override the source object", ^{
            errorContainer.sourceObject should equal(@"newSource");
        });

        it(@"should override the source key", ^{
            errorContainer.sourceAccessor should equal(HYDAccessKey(@"source"));
        });

        it(@"should override the destination key", ^{
            errorContainer.destinationAccessor should equal(HYDAccessKey(@"destination"));
        });

        it(@"should use the specfied fatalness", ^{
            errorContainer.isFatal should_not be_truthy;
        });

        context(@"when the error is fatal", ^{
            beforeEach(^{
                NSMutableDictionary *userInfo = [errorContainer.userInfo mutableCopy];
                userInfo[HYDIsFatalKey] = @YES;
                errorContainer = [HYDError errorWithDomain:errorContainer.domain
                                                      code:errorContainer.code
                                                  userInfo:userInfo];
            });

            it(@"should have a pretty description with fatal errors", ^{
                [errorContainer description] should equal(@"[FATAL] HYDErrorDomain (code=HYDErrorMultipleErrors) because \"Multiple parsing errors occurred (fatal=1, total=2)\"\n"
                                                          @"  - Could not map from 'source.sourceAccessor' to 'destination.destinationAccessor' (HYDErrorInvalidSourceObjectValue)\n"
                                                          @"    |- [NSCocoaErrorDomain] (code=2) The operation couldn’t be completed. (Cocoa error 2.)\n");
            });

            it(@"should have a pretty description with all errors", ^{
                [errorContainer fullDescription] should equal(@"[FATAL] HYDErrorDomain (code=HYDErrorMultipleErrors) because \"Multiple parsing errors occurred (fatal=1, total=2)\"\n"
                                                              @"  - Could not map from 'source.sourceAccessor' to 'destination.destinationAccessor' (HYDErrorInvalidSourceObjectValue)\n"
                                                              @"    |- [NSCocoaErrorDomain] (code=2) The operation couldn’t be completed. (Cocoa error 2.)\n"
                                                              @"  - Could not map from 'source.sourceAccessor' to 'destination.destinationAccessor' (HYDErrorInvalidSourceObjectValue)\n");
            });

            it(@"should have a pretty recursive description that includes fatal errors", ^{
                NSString *format = @"HYDErrorDomain code=%lu isFatal=YES reason=\"Multiple parsing errors occurred (fatal=1, total=2)\" underlyingFatalErrors=(\n"
                @"  - HYDErrorDomain code=1 isFatal=YES reason=\"Could not map from 'sourceAccessor' to 'destinationAccessor'\" underlyingFatalErrors=(\n"
                @"      - Error Domain=NSCocoaErrorDomain Code=2 \"The operation couldn’t be completed. (Cocoa error 2.)\"\n"
                @"    )\n"
                @")";
                [errorContainer recursiveDescription] should equal([NSString stringWithFormat:format,
                                                                    (long)errorContainer.code, error, [HYDError nonFatalError]]);
            });
        });

        context(@"when the error is nonfatal", ^{
            it(@"should have a pretty description with no child errors", ^{
                [errorContainer description] should equal(@"[non-fatal] HYDErrorDomain (code=HYDErrorMultipleErrors) because \"Multiple parsing errors occurred (fatal=1, total=2)\"\n");
            });

            it(@"should have a pretty description with all errors", ^{
                [errorContainer fullDescription] should equal(@"[non-fatal] HYDErrorDomain (code=HYDErrorMultipleErrors) because \"Multiple parsing errors occurred (fatal=1, total=2)\"\n"
                                                              @"  - Could not map from 'source.sourceAccessor' to 'destination.destinationAccessor' (HYDErrorInvalidSourceObjectValue)\n"
                                                              @"    |- [NSCocoaErrorDomain] (code=2) The operation couldn’t be completed. (Cocoa error 2.)\n"
                                                              @"  - Could not map from 'source.sourceAccessor' to 'destination.destinationAccessor' (HYDErrorInvalidSourceObjectValue)\n");
            });

            it(@"should have a pretty description that does not include underlying errors", ^{
                NSString *format = @"HYDErrorDomain code=%lu isFatal=NO reason=\"Multiple parsing errors occurred (fatal=1, total=2)\"";
                [errorContainer recursiveDescription] should equal([NSString stringWithFormat:format, (long)errorContainer.code]);
            });
        });

        it(@"should have a pretty recursive description with all errors", ^{
            NSString *format = @"HYDErrorDomain code=%lu isFatal=NO reason=\"Multiple parsing errors occurred (fatal=1, total=2)\" underlyingErrors=(\n"
            @"  - HYDErrorDomain code=1 isFatal=YES reason=\"Could not map from 'sourceAccessor' to 'destinationAccessor'\" underlyingErrors=(\n"
            @"      - Error Domain=NSCocoaErrorDomain Code=2 \"The operation couldn’t be completed. (Cocoa error 2.)\"\n"
            @"    )\n"
            @"  - HYDErrorDomain code=1 isFatal=NO reason=\"Could not map from 'sourceAccessor' to 'destinationAccessor'\"\n"
            @")";
            [errorContainer fullRecursiveDescription] should equal([NSString stringWithFormat:format,
                                                                    (long)errorContainer.code, error, [HYDError nonFatalError]]);
        });
    });
});

SPEC_END
