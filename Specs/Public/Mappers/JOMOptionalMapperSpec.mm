// DO NOT any other library headers here to simulate an API user.
#import "JOM.h"
#import "JOMFakeMapper.h"
#import "JOMError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JOMOptionalMapperSpec)

describe(@"JOMOptionalMapper", ^{
    __block JOMOptionalMapper *mapper;
    __block JOMFakeMapper *childMapper;
    __block JOMError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        childMapper = [[JOMFakeMapper alloc] init];
        childMapper.destinationKey = @"destinationKey";
        mapper = JOMOptionalWithDefault(childMapper, @42);
    });

    it(@"should ask the child mapper for the destination key", ^{
        mapper.destinationKey should equal(@"destinationKey");
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the mapper is the root mapper", ^{
            context(@"when the source object is valid to the child mapper", ^{
                beforeEach(^{
                    sourceObject = @"valid";
                    childMapper.errorsToReturn = @[[NSNull null]];
                    childMapper.objectsToReturn = @[@1];
                });

                it(@"should tell its child mappers that it is the current root mapper", ^{
                    childMapper.sourceObjectsReceived[0] should be_same_instance_as(sourceObject);
                });

                it(@"should not produce an error", ^{
                    error should be_nil;
                });

                it(@"should return the child mapper's value", ^{
                    parsedObject should equal(@1);
                });
            });

            context(@"when the source object produces a fatal error to the child mapper", ^{
                beforeEach(^{
                    sourceObject = @"invalid";
                    childMapper.errorsToReturn = @[[JOMError fatalError]];
                });

                it(@"should tell its child mappers that it is the current root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(mapper);
                    childMapper.factoryReceived should conform_to(@protocol(JOMFactory));
                });

                it(@"should return the default value", ^{
                    parsedObject should equal(@42);
                });

                it(@"should report a non-fatal error", ^{
                    error should be_a_non_fatal_error().with_code(JOMErrorInvalidSourceObjectType);
                });
            });
        });

        context(@"when the mapper is a child mapper", ^{
            __block id<JOMMapper> rootMapper;
            __block id<JOMFactory> factory;

            beforeEach(^{
                rootMapper = nice_fake_for(@protocol(JOMMapper));
                factory = [[JOMObjectFactory alloc] init];
                [mapper setupAsChildMapperWithMapper:rootMapper factory:factory];
            });

            context(@"when the source object is valid to the child mapper", ^{
                beforeEach(^{
                    sourceObject = @"valid";
                    childMapper.objectsToReturn = @[@1];
                });

                it(@"should tell its child mappers the root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(rootMapper);
                    childMapper.factoryReceived should be_same_instance_as(factory);
                });

                it(@"should not produce an error", ^{
                    error should be_nil;
                });

                it(@"should return the child mapper's value", ^{
                    parsedObject should equal(@1);
                });
            });

            context(@"when the source object is invalid to the child mapper", ^{
                beforeEach(^{
                    sourceObject = @"invalid";
                    childMapper.errorsToReturn = @[[JOMError fatalError]];
                });

                it(@"should tell its child mappers the root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(rootMapper);
                    childMapper.factoryReceived should be_same_instance_as(factory);
                });

                it(@"should return the default value", ^{
                    parsedObject should equal(@42);
                });

                it(@"should report an optional error", ^{
                    error should be_a_non_fatal_error().with_code(JOMErrorInvalidSourceObjectType);
                });
            });
        });
    });

    describe(@"reverse mapping", ^{
        __block id<JOMMapper> reverseMapper;
        __block JOMFakeMapper *reverseChildMapper;

        beforeEach(^{
            reverseChildMapper = [[JOMFakeMapper alloc] initWithDestinationKey:@"otherKey"];
            childMapper.reverseMapperToReturn = reverseChildMapper;
            sourceObject = @"valid";

            reverseMapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
        });

        it(@"should have received the other destination key", ^{
            childMapper.reverseMapperDestinationKeyReceived should equal(@"otherKey");
        });

        context(@"with a good source object", ^{
            beforeEach(^{
                reverseChildMapper.objectsToReturn = @[sourceObject];
                childMapper.objectsToReturn = @[@1];
            });

            it(@"should be in the inverse of the current mapper", ^{
                id inputObject = [mapper objectFromSourceObject:sourceObject error:&error];
                error should be_nil;

                id result = [reverseMapper objectFromSourceObject:inputObject error:&error];
                result should equal(sourceObject);
                error should be_nil;
            });
        });

        context(@"with a bad source object", ^{
            beforeEach(^{
                reverseChildMapper.errorsToReturn = @[[JOMError fatalError]];
                parsedObject = [reverseMapper objectFromSourceObject:@1 error:&error];
            });

            it(@"should emit a non-fatal error", ^{
                error should be_a_non_fatal_error().with_code(JOMErrorInvalidSourceObjectType);
            });

            it(@"should return the default value", ^{
                parsedObject should equal(@42);
            });
        });
    });
});

SPEC_END
