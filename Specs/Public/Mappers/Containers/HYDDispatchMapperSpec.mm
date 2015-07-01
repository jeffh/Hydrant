#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDDispatchMapperSpec)

describe(@"HYDDispatchMapper", ^{
    __block id<HYDMapper> mapper;
    __block HYDSFakeMapper *childMapper1;
    __block HYDSFakeMapper *childMapper2;
    __block HYDSFakeMapper *childMapper3;

    beforeEach(^{
        childMapper1 = [[HYDSFakeMapper alloc] init];
        childMapper2 = [[HYDSFakeMapper alloc] init];
        childMapper3 = [[HYDSFakeMapper alloc] init];
        mapper = HYDMapDispatch(@[@[[NSNumberFormatter class], childMapper1, [NSNumber class]],
                                  @[[NSFormatter class], childMapper2, [NSNumber class]],
                                  @[@protocol(HYDMapper), childMapper3, [NSString class]]]);
    });

    describe(@"parsing an object", ^{
        __block HYDError *error;
        __block id sourceObject;
        __block id parsedObject;

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when given a valid source object of the exact type specified", ^{
            beforeEach(^{
                sourceObject = [[NSNumberFormatter alloc] init];
                childMapper1.objectsToReturn = @[@1];
            });

            it(@"should return no error", ^{
                error should be_nil;
            });

            it(@"should return the value from the child mapper", ^{
                parsedObject should equal(@1);
            });

            it(@"should dispatch the child mapper associated with that type", ^{
                childMapper1.sourceObjectsReceived should equal(@[sourceObject]);
            });
        });

        context(@"when given a valid source object of parent type", ^{
            beforeEach(^{
                sourceObject = [[NSFormatter alloc] init];
                childMapper2.objectsToReturn = @[@1];
            });

            it(@"should return no error", ^{
                error should be_nil;
            });

            it(@"should return the value from the child mapper of superclass", ^{
                parsedObject should equal(@1);
            });

            it(@"should dispatch the child mapper associated with that type", ^{
                childMapper2.sourceObjectsReceived should equal(@[sourceObject]);
            });
        });

        context(@"when given a valid source object of a protocol", ^{
            beforeEach(^{
                sourceObject = [[HYDSFakeMapper alloc] init];
                childMapper3.objectsToReturn = @[@1];
            });

            it(@"should return no error", ^{
                error should be_nil;
            });

            it(@"should return the value from the child mapper of superclass", ^{
                parsedObject should equal(@1);
            });

            it(@"should dispatch the child mapper associated with that type", ^{
                childMapper3.sourceObjectsReceived should equal(@[sourceObject]);
            });
        });

        context(@"when a child mapper fails", ^{
            beforeEach(^{
                sourceObject = [[NSFormatter alloc] init];
                childMapper2.errorsToReturn = @[[HYDError nonFatalError]];
                childMapper2.objectsToReturn = @[@1];
            });

            it(@"should return its error", ^{
                error should equal([HYDError nonFatalError]);
            });

            it(@"should return the value from the child mapper of superclass", ^{
                parsedObject should equal(@1);
            });

            it(@"should dispatch the child mapper associated with that type", ^{
                childMapper2.sourceObjectsReceived should equal(@[sourceObject]);
            });
        });

        context(@"when given a source object that doesn't match any of the specified types", ^{
            beforeEach(^{
                sourceObject = @1;
            });

            it(@"should return an error", ^{
                error should equal([HYDError errorWithCode:HYDErrorInvalidSourceObjectType
                                              sourceObject:sourceObject
                                            sourceAccessor:nil
                                         destinationObject:nil
                                       destinationAccessor:nil
                                                   isFatal:YES
                                          underlyingErrors:nil]);
            });

            it(@"should not to use any child mappers", ^{
                childMapper1.sourceObjectsReceived should be_empty;
                childMapper2.sourceObjectsReceived should be_empty;
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });
    });

    describe(@"reverse mapper", ^{
        __block NSNumberFormatter *placeholderValue;

        beforeEach(^{
            placeholderValue = [NSNumberFormatter new];

            HYDSFakeMapper *reverseMapper1 = [[HYDSFakeMapper alloc] init];
            childMapper1.reverseMapperToReturn = reverseMapper1;
            childMapper1.objectsToReturn = @[@1];
            reverseMapper1.objectsToReturn = @[placeholderValue];

            HYDSFakeMapper *reverseMapper2 = [[HYDSFakeMapper alloc] init];
            childMapper2.reverseMapperToReturn = reverseMapper2;

            HYDSFakeMapper *reverseMapper3 = [[HYDSFakeMapper alloc] init];
            childMapper3.reverseMapperToReturn = reverseMapper3;

            [CDRSpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [CDRSpecHelper specHelper].sharedExampleContext[@"sourceObject"] = placeholderValue;
            [CDRSpecHelper specHelper].sharedExampleContext[@"childMappers"] = @[childMapper1, childMapper2, childMapper3];
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
