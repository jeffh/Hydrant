#import <Cedar/Cedar.h>
// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDError+Spec.h"
#import "HYDSFakeMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDObjectToStringFormatterMapperSpec)

describe(@"HYDObjectToStringFormatterMapper", ^{
    __block id<HYDMapper> mapper;
    __block NSFormatter *formatter;
    __block HYDError *error;
    __block HYDSFakeMapper *innerMapper;

    beforeEach(^{
        error = [HYDError dummyError];
        innerMapper = [[HYDSFakeMapper alloc] init];
        formatter = nice_fake_for([NSFormatter class]);
        mapper = HYDMapObjectToStringByFormatter(innerMapper, formatter);
    });

    describe(@"parsing an object", ^{
        __block id sourceObject;
        __block id parsedObject;

        beforeEach(^{
            sourceObject = @1;
        });

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the source object is valid for the formatter", ^{
            beforeEach(^{
                innerMapper.objectsToReturn = @[@2];
                formatter stub_method(@selector(stringForObjectValue:)).with(@2).and_return(@"Yep");
            });

            it(@"should call the inner mapper", ^{
                innerMapper.sourceObjectsReceived should equal(@[sourceObject]);
            });

            it(@"should return the formatter's object", ^{
                parsedObject should equal(@"Yep");
            });

            it(@"should not return any error", ^{
                error should be_nil;
            });
        });

        context(@"when the source object is produces a nonfatal error for the inner mapper", ^{
            beforeEach(^{
                innerMapper.objectsToReturn = @[@2];
                innerMapper.errorsToReturn = @[[HYDError nonFatalError]];
                formatter stub_method(@selector(stringForObjectValue:)).with(@2).and_return(@"Oh");
            });

            it(@"should call the inner mapper", ^{
                innerMapper.sourceObjectsReceived should equal(@[sourceObject]);
            });

            it(@"should return the formatter result", ^{
                parsedObject should equal(@"Oh");
            });

            it(@"should return the non-fatal error", ^{
                error should equal([HYDError nonFatalError]);
            });
        });

        context(@"when the source object is produces a fatal error for the inner mapper", ^{
            beforeEach(^{
                innerMapper.errorsToReturn = @[[HYDError fatalError]];
            });

            it(@"should not call the formatter", ^{
                formatter should_not have_received(@selector(stringForObjectValue:));
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return the fatal error", ^{
                error should equal([HYDError fatalError]);
            });
        });

        context(@"when the source object is invalid for the formatter", ^{
            beforeEach(^{
                innerMapper.objectsToReturn = @[@2];
                formatter stub_method(@selector(stringForObjectValue:)).and_return((id)nil);
            });

            it(@"should call the inner mapper", ^{
                innerMapper.sourceObjectsReceived should equal(@[sourceObject]);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            });
        });

        context(@"when the source object is nil", ^{
            beforeEach(^{
                innerMapper.objectsToReturn = @[[NSNull null]];
                formatter stub_method(@selector(stringForObjectValue:)).and_return((id)nil);
            });

            it(@"should call the inner mapper", ^{
                innerMapper.sourceObjectsReceived should equal(@[sourceObject]);
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });

            it(@"should return a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
            });
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            mapper = HYDMapObjectToStringByFormatter([[NSNumberFormatter alloc] init]);
            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = @1;
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SPEC_END
