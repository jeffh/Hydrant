// DO NOT any other library headers here to simulate an API user.
#import "JOM.h"
#import "JOMFakeMapper.h"
#import "JOMError+Spec.h"

@interface JOMAnotherFakeMapper : JOMFakeMapper
@end
@implementation JOMAnotherFakeMapper
@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JOMErrorSpec)

xdescribe(@"JOMError", ^{
    __block JOMError *fatalError;
    __block JOMError *nonFatalError;
    __block JOMFakeMapper *originalMapper;
    __block JOMFakeMapper *wrappingMapper;

    beforeEach(^{
        originalMapper = [[JOMFakeMapper alloc] initWithDestinationKey:@"Yo"];
        wrappingMapper = [[JOMAnotherFakeMapper alloc] initWithDestinationKey:@"Ya"];
        fatalError = [JOMError fatalError];
        nonFatalError = [JOMError nonFatalError];
    });

    context(@"a fatal error", ^{
        it(@"should store the source object", ^{
            fatalError.userInfo[JOMSourceObjectKey] should equal(@1);
        });

        it(@"should store fatalness in user info", ^{
            [fatalError.userInfo[JOMIsFatalKey] boolValue] should be_truthy;
        });

        it(@"should store the destination key", ^{
            fatalError.userInfo[JOMDestinationKeyPathKey] should equal(@"Yo");
        });
    });

    context(@"a non-fatal error", ^{
        it(@"should store the original error", ^{
            nonFatalError.userInfo[NSUnderlyingErrorKey] should equal(fatalError);
        });

        it(@"should store the original error in array of errors key", ^{
            nonFatalError.userInfo[JOMUnderlyingErrorsKey] should equal(@[fatalError]);
        });

        it(@"should store non-fatalness in user info", ^{
            [nonFatalError.userInfo[JOMIsFatalKey] boolValue] should_not be_truthy;
        });

        it(@"should store the destination key", ^{
            nonFatalError.userInfo[JOMDestinationKeyPathKey] should equal(@"Ya");
        });
    });

    context(@"a error containing multiple errors", ^{
        __block JOMError *errorList;

        beforeEach(^{
//            errorList = 
        });

        it(@"should store the first error as the original error", ^{
            nonFatalError.userInfo[NSUnderlyingErrorKey] should equal(fatalError);
        });

        it(@"should store the original errors with index information", ^{
            errorList.userInfo[JOMUnderlyingErrorsKey] should equal(@[fatalError, nonFatalError]);
        });

        it(@"should store fatalness", ^{
            [errorList.userInfo[JOMIsFatalKey] boolValue] should be_truthy;
        });

        it(@"should store the store object", ^{
            errorList.userInfo[JOMSourceObjectKey] should equal(@[@1, @2]);
        });

        it(@"should store the current destination key", ^{
            errorList.userInfo[JOMDestinationKeyPathKey] should equal(@"Ya");
        });
    });
});

SPEC_END
