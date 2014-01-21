// DO NOT any other library headers here to simulate an API user.
#import "JKSSerializer.h"
#import "JKSFakeMapper.h"
#import "JKSError+Spec.h"

@interface JKSAnotherFakeMapper : JKSFakeMapper
@end
@implementation JKSAnotherFakeMapper
@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSErrorSpec)

xdescribe(@"JKSError", ^{
    __block JKSError *fatalError;
    __block JKSError *nonFatalError;
    __block JKSFakeMapper *originalMapper;
    __block JKSFakeMapper *wrappingMapper;

    beforeEach(^{
        originalMapper = [[JKSFakeMapper alloc] initWithDestinationKey:@"Yo"];
        wrappingMapper = [[JKSAnotherFakeMapper alloc] initWithDestinationKey:@"Ya"];
        fatalError = [JKSError fatalError];
        nonFatalError = [JKSError nonFatalError];
    });

    context(@"a fatal error", ^{
        it(@"should store the source object", ^{
            fatalError.userInfo[JKSSourceObjectKey] should equal(@1);
        });

        it(@"should store fatalness in user info", ^{
            [fatalError.userInfo[JKSIsFatalKey] boolValue] should be_truthy;
        });

        it(@"should store the destination key", ^{
            fatalError.userInfo[JKSDestinationKeyPathKey] should equal(@"Yo");
        });

        it(@"should be able to report the errorous keypaths", ^{
            [fatalError errorKeyPaths] should equal(@[@"Yo"]);
        });
    });

    context(@"a non-fatal error", ^{
        it(@"should store the original error", ^{
            nonFatalError.userInfo[NSUnderlyingErrorKey] should equal(fatalError);
        });

        it(@"should store the original error in array of errors key", ^{
            nonFatalError.userInfo[JKSUnderlyingErrorsKey] should equal(@[fatalError]);
        });

        it(@"should store non-fatalness in user info", ^{
            [nonFatalError.userInfo[JKSIsFatalKey] boolValue] should_not be_truthy;
        });

        it(@"should store the destination key", ^{
            nonFatalError.userInfo[JKSDestinationKeyPathKey] should equal(@"Ya");
        });

        it(@"should be able to report all the errorous keypaths (decorators do not report)", ^{
            [nonFatalError errorKeyPaths] should equal(@[@"Yo"]);
        });
    });

    context(@"a error containing multiple errors", ^{
        __block JKSError *errorList;

        beforeEach(^{
//            errorList = 
        });

        it(@"should store the first error as the original error", ^{
            nonFatalError.userInfo[NSUnderlyingErrorKey] should equal(fatalError);
        });

        it(@"should store the original errors with index information", ^{
            errorList.userInfo[JKSUnderlyingErrorsKey] should equal(@[fatalError, nonFatalError]);
        });

        it(@"should store fatalness", ^{
            [errorList.userInfo[JKSIsFatalKey] boolValue] should be_truthy;
        });

        it(@"should store the store object", ^{
            errorList.userInfo[JKSSourceObjectKey] should equal(@[@1, @2]);
        });

        it(@"should store the current destination key", ^{
            errorList.userInfo[JKSDestinationKeyPathKey] should equal(@"Ya");
        });

        it(@"should be able to report all the errorous keypaths", ^{
            [errorList errorKeyPaths] should equal(@[@"Ya.Yo", @"Ya.Yo"]);
        });
    });
});

SPEC_END
