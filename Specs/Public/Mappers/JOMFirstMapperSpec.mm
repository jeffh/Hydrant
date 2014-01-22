#import "JOMFirstMapper.h"
#import "JOMFakeMapper.h"
#import "JOMError.h"
#import "JOMError+Spec.h"
#import "JOMObjectFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JOMFirstMapperSpec)

describe(@"JOMFirstMapper", ^{
    __block JOMFirstMapper *mapper;
    __block JOMFakeMapper *child1;
    __block JOMFakeMapper *child2;
    __block JOMFakeMapper *child3;
    __block JOMError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        sourceObject = @"source";
        child1 = [[JOMFakeMapper alloc] initWithDestinationKey:nil];
        child2 = [[JOMFakeMapper alloc] initWithDestinationKey:@"LOL"];
        child3 = [[JOMFakeMapper alloc] initWithDestinationKey:@"OK"];
        mapper = JOMFirst(child1, child2, child3);
    });

    it(@"should return the first non-nil destination key as its destination key", ^{
        [mapper destinationKey] should equal(@"LOL");
    });

    sharedExamplesFor(@"a mapper that tries all the mapper", ^(NSDictionary *scope) {
        __block id<JOMFactory> factory;
        __block id<JOMMapper> rootMapper;

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
                    child1.factoryReceived should conform_to(@protocol(JOMFactory));
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
                child1.errorsToReturn = @[[JOMError fatalError]];
                child2.errorsToReturn = @[[JOMError nonFatalError]];
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
                    child1.factoryReceived should conform_to(@protocol(JOMFactory));
                    child2.factoryReceived should conform_to(@protocol(JOMFactory));
                }
            });

            it(@"should return the first non-nil object", ^{
                parsedObject should equal(@1);
            });

            it(@"should report a non-fatal error of the errors", ^{
                error should be_a_non_fatal_error().with_code(JOMErrorMultipleErrors);
                error.userInfo[JOMUnderlyingErrorsKey] should equal(@[[JOMError fatalError],
                                                                      [JOMError nonFatalError]]);
            });
        });

        context(@"that can not be parsed", ^{
            beforeEach(^{
                child1.errorsToReturn = @[[JOMError fatalError]];
                child2.errorsToReturn = @[[JOMError fatalError]];
                child3.errorsToReturn = @[[JOMError fatalError]];
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
                    child1.factoryReceived should conform_to(@protocol(JOMFactory));
                    child2.factoryReceived should conform_to(@protocol(JOMFactory));
                    child3.factoryReceived should conform_to(@protocol(JOMFactory));
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
                error should be_a_fatal_error().with_code(JOMErrorMultipleErrors);
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
            __block id<JOMFactory> factory;
            __block id<JOMMapper> rootMapper;

            beforeEach(^{
                rootMapper = nice_fake_for(@protocol(JOMMapper));
                factory = [[JOMObjectFactory alloc] init];

                [SpecHelper specHelper].sharedExampleContext[@"rootMapper"] = rootMapper;
                [SpecHelper specHelper].sharedExampleContext[@"factory"] = factory;

                [mapper setupAsChildMapperWithMapper:rootMapper factory:factory];
            });

            itShouldBehaveLike(@"a mapper that tries all the mapper");
        });
    });

    xdescribe(@"reverse mapping", ^{
    });
});

SPEC_END
