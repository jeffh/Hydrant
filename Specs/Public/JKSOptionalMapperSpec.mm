// DO NOT any other library headers here to simulate an API user.
#import "JKSSerializer.h"
#import "JKSFakeMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSOptionalMapperSpec)

describe(@"JKSOptionalMapper", ^{
    __block JKSOptionalMapper *mapper;
    __block JKSFakeMapper *childMapper;
    __block JKSError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        childMapper = [[JKSFakeMapper alloc] init];
        childMapper.destinationKey = @"destinationKey";
        mapper = JKSOptionalWithDefault(childMapper, @42);
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
                    childMapper.errorsToReturn = @[[JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectType sourceObject:sourceObject byMapper:childMapper]];
                });

                it(@"should tell its child mappers that it is the current root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(mapper);
                    childMapper.factoryReceived should conform_to(@protocol(JKSFactory));
                });

                it(@"should return the default value", ^{
                    parsedObject should equal(@42);
                });

                it(@"should report a non-fatal error", ^{
                    error.isFatal should_not be_truthy;
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorOptionalMappingFailed);
                });
            });
        });

        context(@"when the mapper is a child mapper", ^{
            __block id<JKSMapper> rootMapper;
            __block id<JKSFactory> factory;

            beforeEach(^{
                rootMapper = nice_fake_for(@protocol(JKSMapper));
                factory = [[JKSObjectFactory alloc] init];
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
                    childMapper.errorsToReturn = @[[JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectType sourceObject:sourceObject byMapper:childMapper]];
                });

                it(@"should tell its child mappers the root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(rootMapper);
                    childMapper.factoryReceived should be_same_instance_as(factory);
                });

                it(@"should return the default value", ^{
                    parsedObject should equal(@42);
                });

                it(@"should report an optional error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorOptionalMappingFailed);
                });
            });
        });
    });

    describe(@"reverse mapping", ^{
        __block id<JKSMapper> reverseMapper;
        __block JKSFakeMapper *reverseChildMapper;

        beforeEach(^{
            reverseChildMapper = [[JKSFakeMapper alloc] init];
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
                reverseChildMapper.errorsToReturn = @[[JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectType sourceObject:@1 byMapper:reverseChildMapper]];
                parsedObject = [reverseMapper objectFromSourceObject:@1 error:&error];
            });

            it(@"should emit a non-fatal error", ^{
                error.domain should equal(JKSErrorDomain);
                error.code should equal(JKSErrorOptionalMappingFailed);
                error.isFatal should_not be_truthy;
            });

            it(@"should return the default value", ^{
                parsedObject should equal(@42);
            });
        });
    });
});

SPEC_END
