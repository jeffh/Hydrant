// DO NOT any other library headers here to simulate an API user.
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

xdescribe(@"HYDError", ^{
    __block HYDError *fatalError;
    __block HYDError *nonFatalError;
    __block HYDFakeMapper *originalMapper;
    __block HYDFakeMapper *wrappingMapper;

    beforeEach(^{
        originalMapper = [[HYDFakeMapper alloc] initWithDestinationKey:@"Yo"];
        wrappingMapper = [[HYDAnotherFakeMapper alloc] initWithDestinationKey:@"Ya"];
        fatalError = [HYDError fatalError];
        nonFatalError = [HYDError nonFatalError];
    });

    context(@"a fatal error", ^{
        it(@"should store the source object", ^{
            fatalError.userInfo[HYDSourceObjectKey] should equal(@1);
        });

        it(@"should store fatalness in user info", ^{
            [fatalError.userInfo[HYDIsFatalKey] boolValue] should be_truthy;
        });

        it(@"should store the destination key", ^{
            fatalError.userInfo[HYDDestinationKeyPathKey] should equal(@"Yo");
        });
    });

    context(@"a non-fatal error", ^{
        it(@"should store the original error", ^{
            nonFatalError.userInfo[NSUnderlyingErrorKey] should equal(fatalError);
        });

        it(@"should store the original error in array of errors key", ^{
            nonFatalError.userInfo[HYDUnderlyingErrorsKey] should equal(@[fatalError]);
        });

        it(@"should store non-fatalness in user info", ^{
            [nonFatalError.userInfo[HYDIsFatalKey] boolValue] should_not be_truthy;
        });

        it(@"should store the destination key", ^{
            nonFatalError.userInfo[HYDDestinationKeyPathKey] should equal(@"Ya");
        });
    });

    context(@"a error containing multiple errors", ^{
        __block HYDError *errorList;

        beforeEach(^{
//            errorList = 
        });

        it(@"should store the first error as the original error", ^{
            nonFatalError.userInfo[NSUnderlyingErrorKey] should equal(fatalError);
        });

        it(@"should store the original errors with index information", ^{
            errorList.userInfo[HYDUnderlyingErrorsKey] should equal(@[fatalError, nonFatalError]);
        });

        it(@"should store fatalness", ^{
            [errorList.userInfo[HYDIsFatalKey] boolValue] should be_truthy;
        });

        it(@"should store the store object", ^{
            errorList.userInfo[HYDSourceObjectKey] should equal(@[@1, @2]);
        });

        it(@"should store the current destination key", ^{
            errorList.userInfo[HYDDestinationKeyPathKey] should equal(@"Ya");
        });
    });
});

SPEC_END
