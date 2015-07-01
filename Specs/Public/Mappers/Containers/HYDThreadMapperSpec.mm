#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDError+Spec.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDThreadMapperSpec)

describe(@"HYDThreadMapper", ^{
    __block id<HYDMapper> mapper;
    __block HYDSFakeMapper *mapper1;
    __block HYDSFakeMapper *mapper2;

    beforeEach(^{
        mapper1 = [[HYDSFakeMapper alloc] init];
        mapper2 = [[HYDSFakeMapper alloc] init];
        mapper = HYDMapThread(mapper1, mapper2);
    });

    describe(@"parsing an object", ^{
        __block id sourceObject;
        __block id parsedObject;
        __block HYDError *error;

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"with a valid source object", ^{
            beforeEach(^{
                sourceObject = @1;
                mapper1.objectsToReturn = @[@2];
                mapper2.objectsToReturn = @[@3];
            });

            it(@"should return the final object", ^{
                parsedObject should equal(@3);
            });

            it(@"should return no error", ^{
                error should be_nil;
            });
        });

        context(@"with an invalid source object", ^{
            beforeEach(^{
                sourceObject = @1;
                mapper1.objectsToReturn = @[@2];
                mapper2.errorsToReturn = @[[HYDError fatalError]];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return the fatal error", ^{
                error should equal([HYDError fatalError]);
            });
        });

        context(@"with a source object that is nonfatal for the first mapper", ^{
            beforeEach(^{
                sourceObject = @1;
                mapper1.errorsToReturn = @[[HYDError nonFatalError]];
                mapper2.objectsToReturn = @[@2];
            });

            it(@"should return nil", ^{
                parsedObject should equal(@2);
            });

            it(@"should return the non fatal error", ^{
                error should equal([HYDError nonFatalError]);
            });
        });

        context(@"with a source object that is nonfatal for the first mapper and fatal for the last mapper", ^{
            beforeEach(^{
                sourceObject = @1;
                mapper1.errorsToReturn = @[[HYDError nonFatalError]];
                mapper2.errorsToReturn = @[[HYDError fatalError]];
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return the fatal error", ^{
                error should equal([HYDError fatalError]);
            });
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            HYDSFakeMapper *reverseChildMapper1 = [[HYDSFakeMapper alloc] init];
            reverseChildMapper1.objectsToReturn = @[@1];
            mapper1.objectsToReturn = @[@2];
            mapper1.reverseMapperToReturn = reverseChildMapper1;

            HYDSFakeMapper *reverseChildMapper2 = [[HYDSFakeMapper alloc] init];
            reverseChildMapper2.objectsToReturn = @[@2];
            mapper2.reverseMapperToReturn = reverseChildMapper2;
            mapper2.objectsToReturn = @[@3];

            [CDRSpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [CDRSpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @1;
            [CDRSpecHelper specHelper].sharedExampleContext[@"childMappers"] = @[mapper1, mapper2];
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
