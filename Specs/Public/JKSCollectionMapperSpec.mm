// DO NOT any other library headers here to simulate an API user.
#import "JKSSerializer.h"
#import "JKSPerson.h"
#import "JKSFakeMapper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSCollectionMapperSpec)

describe(@"JKSCollectionMapper", ^{
    __block JKSCollectionMapper *mapper;
    __block JKSFakeMapper *childMapper;
    __block JKSError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        childMapper = [[JKSFakeMapper alloc] initWithDestinationKey:@"key"];
        mapper = JKSArrayOf(childMapper);
    });

    it(@"should return the destination key of its child mapper", ^{
        [mapper destinationKey] should equal(@"key");
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when the mapper is the root", ^{
            context(@"when the source object is valid for the child mapper", ^{
                beforeEach(^{
                    sourceObject = @[@1];
                    childMapper.objectsToReturn = @[@"1"];
                });

                it(@"should pass along the factory and root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(mapper);
                    childMapper.factoryReceived should conform_to(@protocol(JKSFactory));
                });

                it(@"should return the child mapper's resulting object in an array", ^{
                    childMapper.sourceObjectsReceived should equal(@[@1]);
                    parsedObject should equal(@[@"1"]);
                });

                it(@"should not return any errors", ^{
                    error should be_nil;
                });
            });

            context(@"when the source object is valid for the child mapper and it returns nil", ^{
                beforeEach(^{
                    sourceObject = @[@1];
                    childMapper.objectsToReturn = @[[NSNull null]];
                });

                it(@"should pass along the factory and root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(mapper);
                    childMapper.factoryReceived should conform_to(@protocol(JKSFactory));
                });

                it(@"should return the child mapper's resulting object in an array", ^{
                    childMapper.sourceObjectsReceived should equal(@[@1]);
                    parsedObject should equal(@[[NSNull null]]);
                });

                it(@"should not return any errors", ^{
                    error should be_nil;
                });
            });

            context(@"when the source object is not a fast enumerable", ^{
                beforeEach(^{
                    sourceObject = @1;
                });

                it(@"should return a fatal error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorInvalidSourceObjectType);
                    error.isFatal should be_truthy;
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object's item makes the child mapper produce a fatal error", ^{
                __block JKSError *expectedError;
                beforeEach(^{
                    expectedError = [JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectType sourceObject:@1 byMapper:childMapper];
                    sourceObject = @[@1, @2];
                    childMapper.objectsToReturn = @[[NSNull null], @2];
                    childMapper.errorsToReturn = @[expectedError, [NSNull null]];
                });

                it(@"should wrap the fatal error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorInvalidSourceObjectValue);
                    error.userInfo[@"errors"] should equal(@[@{@"index": @0,
                                                               @"error": expectedError}]);
                    error.isFatal should be_truthy;
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object's item makes the child mapper produce a non-fatal error", ^{
                __block JKSError *expectedError;
                beforeEach(^{
                    expectedError = [JKSError mappingErrorWithCode:JKSErrorOptionalMappingFailed sourceObject:@1 byMapper:childMapper];
                    sourceObject = @[@1, @2];
                    childMapper.objectsToReturn = @[[NSNull null], @2];
                    childMapper.errorsToReturn = @[expectedError, [NSNull null]];
                });

                it(@"should pass along the factory and root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(mapper);
                    childMapper.factoryReceived should conform_to(@protocol(JKSFactory));
                });

                it(@"should wrap the non-fatal error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorOptionalMappingFailed);
                    error.userInfo[@"errors"] should equal(@[@{@"index": @0,
                                                               @"error": expectedError}]);
                    error.isFatal should_not be_truthy;
                });

                it(@"should return the collection without the non-fatal object", ^{
                    parsedObject should equal(@[@2]);
                });
            });
            
            context(@"when the source object is nil", ^{
                beforeEach(^{
                    sourceObject = nil;
                });
                
                it(@"should not produce an error", ^{
                    error should be_nil;
                });
                
                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });
        });

        context(@"when the mapper is a child mapper", ^{
            __block id<JKSMapper> rootMapper;
            __block JKSObjectFactory *factory;

            beforeEach(^{
                rootMapper = nice_fake_for(@protocol(JKSMapper));
                factory = [[JKSObjectFactory alloc] init];
                [mapper setupAsChildMapperWithMapper:rootMapper factory:factory];
            });

            context(@"when the source object is valid for the child mapper", ^{
                beforeEach(^{
                    sourceObject = @[@1];
                    childMapper.objectsToReturn = @[@"1"];
                });

                it(@"should pass along the factory and root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(rootMapper);
                    childMapper.factoryReceived should be_same_instance_as(factory);
                });

                it(@"should return the child mapper's resulting object in an array", ^{
                    childMapper.sourceObjectsReceived should equal(@[@1]);
                    parsedObject should equal(@[@"1"]);
                });

                it(@"should not return any errors", ^{
                    error should be_nil;
                });
            });

            context(@"when the source object is valid for the child mapper and it returns nil", ^{
                beforeEach(^{
                    sourceObject = @[@1];
                    childMapper.objectsToReturn = @[[NSNull null]];
                });

                it(@"should pass along the factory and root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(rootMapper);
                    childMapper.factoryReceived should be_same_instance_as(factory);
                });

                it(@"should return the child mapper's resulting object in an array", ^{
                    childMapper.sourceObjectsReceived should equal(@[@1]);
                    parsedObject should equal(@[[NSNull null]]);
                });

                it(@"should not return any errors", ^{
                    error should be_nil;
                });
            });

            context(@"when the source object is not a fast enumerable", ^{
                beforeEach(^{
                    sourceObject = @1;
                });

                it(@"should return a fatal error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorInvalidSourceObjectType);
                    error.isFatal should be_truthy;
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object's item makes the child mapper produce a fatal error", ^{
                __block JKSError *expectedError;

                beforeEach(^{
                    expectedError = [JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectType sourceObject:@1 byMapper:childMapper];
                    sourceObject = @[@1, @2];
                    childMapper.objectsToReturn = @[[NSNull null], @2];
                    childMapper.errorsToReturn = @[expectedError, [NSNull null]];
                });

                it(@"should wrap the fatal error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorInvalidSourceObjectValue);
                    error.userInfo[@"errors"] should equal(@[@{@"index": @0,
                                                               @"error": expectedError}]);
                    error.isFatal should be_truthy;
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object's item makes the child mapper produce a non-fatal error", ^{
                __block JKSError *expectedError;

                beforeEach(^{
                    expectedError = [JKSError mappingErrorWithCode:JKSErrorOptionalMappingFailed sourceObject:@1 byMapper:childMapper];
                    sourceObject = @[@1, @2];
                    childMapper.objectsToReturn = @[[NSNull null], @2];
                    childMapper.errorsToReturn = @[expectedError, [NSNull null]];
                });

                it(@"should pass along the factory and root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(rootMapper);
                    childMapper.factoryReceived should be_same_instance_as(factory);
                });

                it(@"should wrap the non-fatal error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorOptionalMappingFailed);
                    error.userInfo[@"errors"] should equal(@[@{@"index": @0,
                                                               @"error": expectedError}]);
                    error.isFatal should_not be_truthy;
                });

                it(@"should return the collection without the non-fatal object", ^{
                    parsedObject should equal(@[@2]);
                });
            });
            
            context(@"when the source object is nil", ^{
                beforeEach(^{
                    sourceObject = nil;
                });
                
                it(@"should not produce an error", ^{
                    error should be_nil;
                });
                
                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });
        });
    });

    describe(@"reverse mapping", ^{
        __block id<JKSMapper> reverseMapper;
        __block JKSFakeMapper *reverseChildMapper;

        beforeEach(^{
            reverseChildMapper = [[JKSFakeMapper alloc] initWithDestinationKey:@"otherKey"];
            childMapper.reverseMapperToReturn = reverseChildMapper;
            childMapper.objectsToReturn = @[@2];
            reverseChildMapper.objectsToReturn = @[@1];
            
            reverseMapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
        });

        it(@"should pass the new destination key to the reverse mapper", ^{
            childMapper.reverseMapperDestinationKeyReceived should equal(@"otherKey");
            [reverseMapper destinationKey] should equal(@"otherKey");
        });

        it(@"should produce an inverse mapper", ^{
            sourceObject = @[@1];
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            error should be_nil;

            id result = [reverseMapper objectFromSourceObject:parsedObject error:&error];
            error should be_nil;
            result should equal(sourceObject);
        });
    });
});

SPEC_END
