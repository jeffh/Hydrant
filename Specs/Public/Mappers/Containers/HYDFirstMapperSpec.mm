#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDFirstMapperSpec)

describe(@"HYDFirstMapper", ^{
    __block id<HYDMapper> mapper;
    __block HYDSFakeMapper *child1;
    __block HYDSFakeMapper *child2;
    __block HYDSFakeMapper *child3;
    __block HYDError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        sourceObject = @"source";
        child1 = [[HYDSFakeMapper alloc] init];
        child2 = [[HYDSFakeMapper alloc] init];
        child3 = [[HYDSFakeMapper alloc] init];
        mapper = HYDMapFirst(child1, child2, child3);
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"that can be parsed immediately", ^{
            beforeEach(^{
                child1.objectsToReturn = @[@0];
                child2.objectsToReturn = @[@1];
                child3.objectsToReturn = @[@2];
            });

            it(@"should try each child until success", ^{
                child1.sourceObjectsReceived should equal(@[sourceObject]);
                child2.sourceObjectsReceived should be_empty;
                child3.sourceObjectsReceived should be_empty;
            });

            it(@"should return the first non-nil object", ^{
                parsedObject should equal(@0);
            });

            it(@"should not error", ^{
                error should be_nil;
            });
        });

        context(@"that can be parsed after some failures", ^{
            beforeEach(^{
                child1.errorsToReturn = @[[HYDError fatalError]];
                child2.errorsToReturn = @[[HYDError nonFatalError]];
                child2.objectsToReturn = @[@1];
                child3.objectsToReturn = @[@2];
            });

            it(@"should try each child until success", ^{
                child1.sourceObjectsReceived should equal(@[sourceObject]);
                child2.sourceObjectsReceived should equal(@[sourceObject]);
                child3.sourceObjectsReceived should be_empty;
            });

            it(@"should return the first non-nil object", ^{
                parsedObject should equal(@1);
            });

            it(@"should report a non-fatal error of the errors", ^{
                error should be_a_non_fatal_error.with_code(HYDErrorMultipleErrors);
                error.userInfo[HYDUnderlyingErrorsKey] should equal(@[[HYDError fatalError],
                        [HYDError nonFatalError]]);
            });
        });

        context(@"that can not be parsed", ^{
            beforeEach(^{
                child1.errorsToReturn = @[[HYDError fatalError]];
                child2.errorsToReturn = @[[HYDError fatalError]];
                child3.errorsToReturn = @[[HYDError fatalError]];
            });

            it(@"should try each child until success", ^{
                child1.sourceObjectsReceived should equal(@[sourceObject]);
                child2.sourceObjectsReceived should equal(@[sourceObject]);
                child3.sourceObjectsReceived should equal(@[sourceObject]);
            });

            it(@"should return the a nil object", ^{
                parsedObject should be_nil;
            });

            it(@"should report a fatal error of the errors", ^{
                error should be_a_fatal_error.with_code(HYDErrorMultipleErrors);
            });
        });
    });

    describe(@"errornously parsing an object without an error pointer", ^{
        it(@"should not explode", ^{
            child1.errorsToReturn = @[[HYDError fatalError]];
            child2.errorsToReturn = @[[HYDError nonFatalError]];
            child2.objectsToReturn = @[@1];
            child3.objectsToReturn = @[@2];
            [mapper objectFromSourceObject:sourceObject error:nil];
        });
    });

    describe(@"reverse mapping", ^{
        beforeEach(^{
            HYDSFakeMapper *reversedChild1 = [[HYDSFakeMapper alloc] init];
            HYDSFakeMapper *reversedChild2 = [[HYDSFakeMapper alloc] init];
            HYDSFakeMapper *reversedChild3 = [[HYDSFakeMapper alloc] init];
            child1.reverseMapperToReturn = reversedChild1;
            child2.reverseMapperToReturn = reversedChild2;
            child3.reverseMapperToReturn = reversedChild3;

            child1.objectsToReturn = @[@1];
            reversedChild1.objectsToReturn = @[@"LOL"];

            [CDRSpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [CDRSpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @"LOL";
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
