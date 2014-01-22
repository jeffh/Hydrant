#import "JKSFirstMapper.h"
#import "JKSFakeMapper.h"
#import "JKSError.h"
#import "JKSError+Spec.h"
#import "JKSObjectFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSFirstMapperSpec)

describe(@"JKSFirstMapper", ^{
    __block JKSFirstMapper *mapper;
    __block JKSFakeMapper *child1;
    __block JKSFakeMapper *child2;
    __block JKSFakeMapper *child3;
    __block JKSError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        sourceObject = @"source";
        child1 = [[JKSFakeMapper alloc] initWithDestinationKey:nil];
        child2 = [[JKSFakeMapper alloc] initWithDestinationKey:@"LOL"];
        child3 = [[JKSFakeMapper alloc] initWithDestinationKey:@"OK"];
        mapper = JKSFirst(child1, child2, child3);
    });

    it(@"should return the first non-nil destination key as its destination key", ^{
        [mapper destinationKey] should equal(@"LOL");
    });

    sharedExamplesFor(@"a mapper that tries all the mapper", ^(NSDictionary *scope) {
        __block id<JKSFactory> factory;
        __block id<JKSMapper> rootMapper;

        beforeEach(^{
            rootMapper = scope[@"rootMapper"];
            factory = scope[@"factory"];
        });

        context(@"that can be parsed immediately", ^{
            beforeEach(^{
                child1.objectsToReturn = @[@0];
                child2.objectsToReturn = @[@1];
                child3.objectsToReturn = @[@2];
            });

            it(@"should tell the child mapper before trying to parse it", ^{
                child1.rootMapperReceived should be_same_instance_as(rootMapper);
                if (factory) {
                    child1.factoryReceived should be_same_instance_as(factory);
                } else {
                    child1.factoryReceived should conform_to(@protocol(JKSFactory));
                }
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
                child1.errorsToReturn = @[[JKSError fatalError]];
                child2.errorsToReturn = @[[JKSError nonFatalError]];
                child2.objectsToReturn = @[@1];
                child3.objectsToReturn = @[@2];
            });

            it(@"should try each child until success", ^{
                child1.sourceObjectsReceived should equal(@[sourceObject]);
                child2.sourceObjectsReceived should equal(@[sourceObject]);
                child3.sourceObjectsReceived should be_empty;
            });

            it(@"should tell the child mapper before trying to parse it", ^{
                child1.rootMapperReceived should be_same_instance_as(rootMapper);
                child2.rootMapperReceived should be_same_instance_as(rootMapper);
                if (factory) {
                    child1.factoryReceived should be_same_instance_as(factory);
                    child2.factoryReceived should be_same_instance_as(factory);
                } else {
                    child1.factoryReceived should conform_to(@protocol(JKSFactory));
                    child2.factoryReceived should conform_to(@protocol(JKSFactory));
                }
            });

            it(@"should return the first non-nil object", ^{
                parsedObject should equal(@1);
            });

            it(@"should report a non-fatal error of the errors", ^{
                error should be_a_non_fatal_error().with_code(JKSErrorMultipleErrors);
                error.userInfo[JKSUnderlyingErrorsKey] should equal(@[[JKSError fatalError],
                                                                      [JKSError nonFatalError]]);
            });
        });

        context(@"that can not be parsed", ^{
            beforeEach(^{
                child1.errorsToReturn = @[[JKSError fatalError]];
                child2.errorsToReturn = @[[JKSError fatalError]];
                child3.errorsToReturn = @[[JKSError fatalError]];
            });

            it(@"should tell the child mapper before trying to parse it", ^{
                child1.rootMapperReceived should be_same_instance_as(rootMapper);
                child2.rootMapperReceived should be_same_instance_as(rootMapper);
                child3.rootMapperReceived should be_same_instance_as(rootMapper);
                if (factory) {
                    child1.factoryReceived should be_same_instance_as(factory);
                    child2.factoryReceived should be_same_instance_as(factory);
                    child3.factoryReceived should be_same_instance_as(factory);
                } else {
                    child1.factoryReceived should conform_to(@protocol(JKSFactory));
                    child2.factoryReceived should conform_to(@protocol(JKSFactory));
                    child3.factoryReceived should conform_to(@protocol(JKSFactory));
                }
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
                error should be_a_fatal_error().with_code(JKSErrorMultipleErrors);
            });
        });
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"as a root mapper", ^{
            beforeEach(^{
                [SpecHelper specHelper].sharedExampleContext[@"rootMapper"] = mapper;
            });

            itShouldBehaveLike(@"a mapper that tries all the mapper");
        });

        context(@"as a child mapper", ^{
            __block id<JKSFactory> factory;
            __block id<JKSMapper> rootMapper;

            beforeEach(^{
                rootMapper = nice_fake_for(@protocol(JKSMapper));
                factory = [[JKSObjectFactory alloc] init];

                [SpecHelper specHelper].sharedExampleContext[@"rootMapper"] = rootMapper;
                [SpecHelper specHelper].sharedExampleContext[@"factory"] = factory;

                [mapper setupAsChildMapperWithMapper:rootMapper factory:factory];
            });

            itShouldBehaveLike(@"a mapper that tries all the mapper");
        });
    });
});

SPEC_END
