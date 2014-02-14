// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDError+Spec.h"
#import "HYDFakeMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDPostProcessingMapperSpec)

describe(@"HYDPostProcessingMapper", ^{
    __block HYDPostProcessingMapper *mapper;
    __block HYDFakeMapper *childMapper;
    __block id parsedObject;
    __block id sourceObject;
    __block HYDError *error;
    __block id incomingSourceObject;
    __block id incomingResultingObject;
    __block HYDError *incomingError;
    __block HYDError *outgoingError;
    __block BOOL setOutgoingError;
    __block BOOL blockWasCalled;
    __block BOOL reversedBlockWasCalled;

    beforeEach(^{
        setOutgoingError = NO;
        blockWasCalled = NO;
        reversedBlockWasCalled = NO;
        childMapper = [[HYDFakeMapper alloc] initWithDestinationKey:@"destinationAccessor"];
        mapper = HYDMapWithPostProcessing(childMapper, ^(id theSourceObject, id resultingObject, __autoreleasing HYDError **theError) {
            incomingSourceObject = theSourceObject;
            incomingResultingObject = resultingObject;
            incomingError = *theError;
            if (setOutgoingError) {
                *theError = outgoingError;
            }
            blockWasCalled = YES;
        }, ^(id theSourceObject, id resultingObject, __autoreleasing HYDError **theError) {
            reversedBlockWasCalled = YES;
        });
    });

    it(@"should return the destination key it was given", ^{
        [mapper destinationAccessor] should equal(HYDAccessDefault(@"destinationAccessor"));
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            sourceObject = @"HI";
            childMapper.objectsToReturn = @[@1];
            childMapper.errorsToReturn = @[[HYDError nonFatalError]];
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        it(@"should not call the reversed block", ^{
            reversedBlockWasCalled should_not be_truthy;
        });

        it(@"should pass the arguments to the block", ^{
            incomingSourceObject should equal(@"HI");
            incomingResultingObject should equal(@1);
            incomingError should equal([HYDError nonFatalError]);
        });

        it(@"should return the resulting object", ^{
            parsedObject should equal(@1);
            error should equal([HYDError nonFatalError]);
        });

        context(@"when the block mutates the error to a fatal error", ^{
            beforeEach(^{
                setOutgoingError = YES;
                outgoingError = [HYDError fatalError];
            });

            it(@"should set the new resulting error", ^{
                error should equal([HYDError fatalError]);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when the block mutates the error to be nil", ^{
            beforeEach(^{
                setOutgoingError = YES;
                outgoingError = nil;
            });

            it(@"should set the new resulting error", ^{
                error should be_nil;
            });

            it(@"should return the object", ^{
                parsedObject should equal(@1);
            });
        });
    });

    describe(@"reverse mapping", ^{
        beforeEach(^{
            HYDFakeMapper *reverseChildMapper = [[HYDFakeMapper alloc] initWithDestinationKey:@"otherKey"];
            reverseChildMapper.objectsToReturn = @[@"LOL"];
            childMapper.reverseMapperToReturn = reverseChildMapper;

            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @"LOL";
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");

        it(@"should call the reversed block", ^{
            [[mapper reverseMapperWithDestinationAccessor:HYDAccessKey(@"key")] objectFromSourceObject:@1 error:nil];

            blockWasCalled should_not be_truthy;
            reversedBlockWasCalled should be_truthy;
        });

    });
});

SPEC_END
