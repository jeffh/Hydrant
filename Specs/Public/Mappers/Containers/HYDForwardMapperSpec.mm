#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDDefaultAccessor.h"
#import "HYDSFakeAccessor.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDForwardMapperSpec)

describe(@"HYDForwardMapper", ^{
    __block id<HYDMapper> mapper;
    __block HYDSFakeMapper *childMapper;
    __block HYDSFakeAccessor *accessor;
    __block id validSourceObject;
    __block id expectedDestinationObject;

    beforeEach(^{
        validSourceObject = @{@"walk": @{@"to": @"me"}};
        expectedDestinationObject = @"you";
        childMapper = [[HYDSFakeMapper alloc] init]; //WithDestinationKey:@"key"];
        accessor = [[HYDSFakeAccessor alloc] init];
        accessor.fieldNames = @[@"walk.to"];
        mapper = HYDMapForward(accessor, childMapper);
    });

    describe(@"parsing an object", ^{
        __block id sourceObject;
        __block id resultingObject;
        __block HYDError *error;

        subjectAction(^{
            error = [HYDError dummyError];
            resultingObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the source object is valid", ^{
            beforeEach(^{
                sourceObject = validSourceObject;
                accessor.valuesToReturn = @[@"me"];
                childMapper.objectsToReturn = @[@"you"];
            });

            it(@"should use the accessor to extract the source object partial", ^{
                accessor.sourceValueReceived should equal(sourceObject);
            });

            it(@"should pass the partial of the source object to the child mapper", ^{
                childMapper.sourceObjectsReceived should equal(accessor.valuesToReturn);
            });

            it(@"should return the value the child mapper returns", ^{
                resultingObject should equal(@"you");
            });

            it(@"should return no error", ^{
                error should be_nil;
            });
        });

        context(@"when the source object fails to be accessed fatally", ^{
            beforeEach(^{
                sourceObject = @{@"walk": @{@"nowhere": @"me"}};
                accessor.sourceErrorToReturn = [HYDError fatalError];
            });

            it(@"should return nil", ^{
                resultingObject should be_nil;
            });

            it(@"should return the error", ^{
                error should be_same_instance_as(accessor.sourceErrorToReturn);
            });
        });

        context(@"when the source object fails to be mapped fatally", ^{
            beforeEach(^{
                sourceObject = @{@"walk": @{@"nowhere": @"me"}};
                accessor.valuesToReturn = @[@"me"];
                childMapper.errorsToReturn = @[[HYDError fatalError]];
                childMapper.objectsToReturn = @[@1];
            });

            it(@"should return nil", ^{
                resultingObject should be_nil;
            });

            it(@"should return the error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectType);
                error should equal([HYDError errorFromError:[HYDError fatalError]
                                   prependingSourceAccessor:accessor
                                     andDestinationAccessor:nil
                                    replacementSourceObject:sourceObject
                                                    isFatal:YES]);
            });
        });

        context(@"when the source object fails to be mapped non-fatally", ^{
            beforeEach(^{
                sourceObject = @{@"walk": @{@"nowhere": @"me"}};
                accessor.valuesToReturn = @[@"me"];
                childMapper.errorsToReturn = @[[HYDError nonFatalError]];
                childMapper.objectsToReturn = @[@1];
            });

            it(@"should return the child mapper's object", ^{
                resultingObject should equal(@1);
            });

            it(@"should return the error", ^{
                error should be_a_non_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            });
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            // fake accessor doesn't support key paths
            mapper = HYDMapForward(HYDAccessDefault(@"walk.to"), childMapper);

            HYDSFakeMapper *reverseChildMapper = [[HYDSFakeMapper alloc] init];
            reverseChildMapper.objectsToReturn = @[@"me"];
            childMapper.reverseMapperToReturn = reverseChildMapper;

            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = validSourceObject;
            [SpecHelper specHelper].sharedExampleContext[@"childMappers"] = @[childMapper];
            [SpecHelper specHelper].sharedExampleContext[@"reverseAccessor"] = HYDAccessDefault(@"walk.to");
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
