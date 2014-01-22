// DO NOT any other library headers here to simulate an API user.
#import "JOM.h"
#import "JOMPerson.h"
#import "JOMFakeMapper.h"
#import "JOMError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JOMCollectionMapperSpec)

describe(@"JOMCollectionMapper", ^{
    __block JOMCollectionMapper *mapper;
    __block JOMFakeMapper *childMapper;
    __block JOMError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        childMapper = [[JOMFakeMapper alloc] initWithDestinationKey:@"key"];
        mapper = JOMArrayOf(childMapper);
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
                    childMapper.factoryReceived should conform_to(@protocol(JOMFactory));
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
                    childMapper.factoryReceived should conform_to(@protocol(JOMFactory));
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
                    error.domain should equal(JOMErrorDomain);
                    error.code should equal(JOMErrorInvalidSourceObjectType);
                    error.isFatal should be_truthy;
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object's item makes the child mapper produce a fatal error", ^{
                __block JOMError *expectedError;

                beforeEach(^{
                    expectedError = [JOMError fatalError];
                    sourceObject = @[@1, @2];
                    childMapper.objectsToReturn = @[[NSNull null], @2];
                    childMapper.errorsToReturn = @[expectedError, [NSNull null]];
                });

                it(@"should wrap the fatal error", ^{
                    error should be_a_fatal_error().with_code(JOMErrorMultipleErrors);

                    JOMError *wrappedError = [JOMError errorFromError:expectedError
                                                  prependingSourceKey:@"0"
                                                    andDestinationKey:@"0"
                                              replacementSourceObject:@1
                                                              isFatal:YES];
                    error.userInfo[JOMUnderlyingErrorsKey] should equal(@[wrappedError]);
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object's item makes the child mapper produce a non-fatal error", ^{
                __block JOMError *expectedError;

                beforeEach(^{
                    expectedError = [JOMError nonFatalError];
                    sourceObject = @[@1, @2];
                    childMapper.objectsToReturn = @[[NSNull null], @2];
                    childMapper.errorsToReturn = @[expectedError, [NSNull null]];
                });

                it(@"should pass along the factory and root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(mapper);
                    childMapper.factoryReceived should conform_to(@protocol(JOMFactory));
                });

                it(@"should wrap the non-fatal error", ^{
                    error should be_a_non_fatal_error().with_code(JOMErrorMultipleErrors);
                    
                    JOMError *wrappedError = [JOMError errorFromError:expectedError
                                                  prependingSourceKey:@"0"
                                                    andDestinationKey:@"0"
                                              replacementSourceObject:@1
                                                              isFatal:NO];
                    error.userInfo[JOMUnderlyingErrorsKey] should equal(@[wrappedError]);
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
            __block id<JOMMapper> rootMapper;
            __block JOMObjectFactory *factory;

            beforeEach(^{
                rootMapper = nice_fake_for(@protocol(JOMMapper));
                factory = [[JOMObjectFactory alloc] init];
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
                    error.domain should equal(JOMErrorDomain);
                    error.code should equal(JOMErrorInvalidSourceObjectType);
                    error.isFatal should be_truthy;
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object's item makes the child mapper produce a fatal error", ^{
                __block JOMError *expectedError;

                beforeEach(^{
                    expectedError = [JOMError fatalError];
                    sourceObject = @[@1, @2];
                    childMapper.objectsToReturn = @[[NSNull null], @2];
                    childMapper.errorsToReturn = @[expectedError, [NSNull null]];
                });

                it(@"should wrap the fatal error", ^{
                    error should be_a_fatal_error().with_code(JOMErrorMultipleErrors);
                    JOMError *wrappedError = [JOMError errorFromError:expectedError
                                                  prependingSourceKey:@"0"
                                                    andDestinationKey:@"0"
                                              replacementSourceObject:@1
                                                              isFatal:YES];
                    error.userInfo[JOMUnderlyingErrorsKey] should equal(@[wrappedError]);
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object's item makes the child mapper produce a non-fatal error", ^{
                __block JOMError *expectedError;

                beforeEach(^{
                    expectedError = [JOMError nonFatalError];
                    sourceObject = @[@1, @2];
                    childMapper.objectsToReturn = @[[NSNull null], @2];
                    childMapper.errorsToReturn = @[expectedError, [NSNull null]];
                });

                it(@"should pass along the factory and root mapper", ^{
                    childMapper.rootMapperReceived should be_same_instance_as(rootMapper);
                    childMapper.factoryReceived should be_same_instance_as(factory);
                });

                it(@"should wrap the non-fatal error", ^{
                    error should be_a_non_fatal_error().with_code(JOMErrorMultipleErrors);
                    JOMError *wrappedError = [JOMError errorFromError:expectedError
                                                  prependingSourceKey:@"0"
                                                    andDestinationKey:@"0"
                                              replacementSourceObject:@1
                                                              isFatal:NO];
                    error.userInfo[JOMUnderlyingErrorsKey] should equal(@[wrappedError]);
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
        __block id<JOMMapper> reverseMapper;
        __block JOMFakeMapper *reverseChildMapper;

        beforeEach(^{
            reverseChildMapper = [[JOMFakeMapper alloc] initWithDestinationKey:@"otherKey"];
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
