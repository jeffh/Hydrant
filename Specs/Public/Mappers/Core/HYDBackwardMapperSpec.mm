// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDSFakeAccessor.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDBackwardMapperSpec)

describe(@"HYDBackwardMapper", ^{
    __block HYDBackwardMapper *mapper;
    __block HYDSFakeMapper *childMapper;
    __block HYDSFakeAccessor *accessor;
    __block id validSourceObject;
    __block id expectedDestinationObject;

    beforeEach(^{
        validSourceObject = @"me";
        expectedDestinationObject = @{@"walk": @"you"};
        childMapper = [[HYDSFakeMapper alloc] initWithDestinationKey:@"key"];
        accessor = [[HYDSFakeAccessor alloc] init];
        accessor.fieldNames = @[@"walk"];
        mapper = HYDMapBackward(accessor, childMapper);
    });

    it(@"should return the destination accessor of both of the child mapper", ^{
        [mapper destinationAccessor] should equal(HYDAccessDefault(@"key"));
    });

    describe(@"parsing an object", ^{
        __block id sourceObject;
        __block id resultingObject;
        __block HYDError *error;

        subjectAction(^{
            resultingObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the source object is valid", ^{
            beforeEach(^{
                sourceObject = validSourceObject;
                childMapper.objectsToReturn = @[@"you"];
            });

            it(@"should use the accessor to produce the resulting object", ^{
                accessor.valuesToSetReceived should equal(@[@"you"]);
            });

            it(@"should pass the partial of the source object to the child mapper", ^{
                childMapper.sourceObjectsReceived should equal(@[sourceObject]);
            });

            it(@"should return the value the child mapper returns", ^{
                resultingObject should equal(expectedDestinationObject);
            });

            it(@"should return no error", ^{
                error should be_nil;
            });
        });

        context(@"when the source object fatally fails to produce the object via the accessor", ^{
            beforeEach(^{
                sourceObject = @{@"nowhere": @"me"};
                childMapper.objectsToReturn = @[@"you"];
                accessor.setValuesErrorToReturn = [HYDError fatalError];
            });

            it(@"should return nil", ^{
                resultingObject should be_nil;
            });

            it(@"should return the error", ^{
                error should be_same_instance_as(accessor.setValuesErrorToReturn);
            });
        });

        context(@"when the source object fails to be mapped fatally", ^{
            beforeEach(^{
                sourceObject = @{@"walk": @{@"nowhere": @"me"}};
                childMapper.errorsToReturn = @[[HYDError fatalError]];
                childMapper.objectsToReturn = @[@1];
            });

            it(@"should return nil", ^{
                resultingObject should be_nil;
            });

            it(@"should return the error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectType);
                error should equal([HYDError errorFromError:[HYDError fatalError]
                                   prependingSourceAccessor:nil
                                     andDestinationAccessor:accessor
                                    replacementSourceObject:sourceObject
                                                    isFatal:YES]);
            });
        });

        context(@"when the source object fails to be mapped non-fatally", ^{
            beforeEach(^{
                sourceObject = @{@"walk": @"me"};
                childMapper.errorsToReturn = @[[HYDError nonFatalError]];
                childMapper.objectsToReturn = @[@"you"];
            });

            it(@"should return the child mapper's object", ^{
                resultingObject should equal(expectedDestinationObject);
            });

            it(@"should return the error", ^{
                error should be_a_non_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            });
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            // fake accessor doesn't support key paths
            mapper = HYDMapBackward(HYDAccessDefault(@"walk.to"), childMapper);

            HYDSFakeMapper *reverseChildMapper = [[HYDSFakeMapper alloc] initWithDestinationAccessor:HYDAccessDefault(@"walk.to")];
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
