// DO NOT any other library headers here to simulate an API user.
#import "JKSSerializer.h"
#import "JKSError+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSTypedMapperSpec)

describe(@"JKSTypedMapper", ^{
    __block JKSTypedMapper *mapper;
    __block id<JKSMapper> innerMapper;
    __block JKSError *error;
    __block id sourceObject;
    __block id parsedObject;

    beforeEach(^{
        error = nil;
        sourceObject = @"SOURCE";
        innerMapper = nice_fake_for(@protocol(JKSMapper));
        innerMapper stub_method(@selector(destinationKey)).and_return(@"mah-key");

        mapper = JKSEnforceTypes(innerMapper,
                                 @[[NSString class], [NSArray class]],
                                 @[[NSNumber class], [NSArray class]]);
    });

    it(@"should pass through to the inner mapper for the destination key", ^{
        mapper.destinationKey should equal(@"mah-key");
    });

    describe(@"parsing an object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"as a child mapper", ^{
            __block id<JKSMapper> parentMapper;
            __block id<JKSFactory> factory;

            beforeEach(^{
                parentMapper = nice_fake_for(@protocol(JKSMapper));
                factory = nice_fake_for(@protocol(JKSFactory));
                [mapper setupAsChildMapperWithMapper:parentMapper factory:factory];
            });

            context(@"when the type is a subclass", ^{
                beforeEach(^{
                    sourceObject = [NSMutableArray array];
                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_return([@[@1] mutableCopy]);
                });

                it(@"should not error", ^{
                    error should be_nil;
                });

                it(@"should return the inner mapper's value", ^{
                    parsedObject should equal(@[@1]);
                });
            });

            context(@"when the source object is invalid type for the inner mapper", ^{
                beforeEach(^{
                    sourceObject = @2;
                });

                it(@"should not invoke the inner mapper", ^{
                    innerMapper should_not have_received(@selector(setupAsChildMapperWithMapper:factory:));
                    innerMapper should_not have_received(@selector(objectFromSourceObject:error:));
                });

                it(@"should produce a type error", ^{
                    error should be_a_fatal_error().with_code(JKSErrorInvalidSourceObjectType);
                });
            });

            context(@"when the object is valid to the inner mapper and is the correct type", ^{
                beforeEach(^{
                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_return(@1);
                });

                it(@"should invoke the inner mapper's setup method", ^{
                    innerMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(parentMapper, factory);
                });

                it(@"should not error", ^{
                    error should be_nil;
                });

                it(@"should return the object the inner mapper returned", ^{
                    parsedObject should equal(@1);
                });
            });

            context(@"when the inner mapper returns nil from a nil source object", ^{
                beforeEach(^{
                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_return((id)nil);
                });

                it(@"should invoke the inner mapper's setup method", ^{
                    innerMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(parentMapper, factory);
                });

                it(@"should not error", ^{
                    error should be_nil;
                });

                it(@"should return the object the inner mapper returned", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the object is valid to the inner mapper but is the incorrect return type", ^{
                beforeEach(^{
                    sourceObject = nil;
                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_return(@"Cheese");
                });

                it(@"should invoke the inner mapper's setup method", ^{
                    innerMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(parentMapper, factory);
                });

                it(@"should produce a fatal error with invalid return type", ^{
                    error should be_a_fatal_error().with_code(JKSErrorInvalidResultingObjectType);
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the object causes a fatal error to the inner mapper", ^{
                __block NSError *innerMapperError;
                beforeEach(^{
                    innerMapperError = [JKSError fatalError];

                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_do(^(NSInvocation *invocation) {
                        id returnObject = nil;
                        NSError __autoreleasing **errorPtr = nil;
                        [invocation getArgument:&errorPtr atIndex:3];
                        *errorPtr = innerMapperError;
                        [invocation setReturnValue:&returnObject];
                    });
                });

                it(@"should invoke the inner mapper's setup method", ^{
                    innerMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(parentMapper, factory);
                });

                it(@"should bubble up the error", ^{
                    error should be_same_instance_as(innerMapperError);
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });
        });

        context(@"as the root mapper", ^{
            context(@"when the type is a subclass", ^{
                beforeEach(^{
                    sourceObject = [NSMutableArray array];
                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_return([@[@1] mutableCopy]);
                });

                it(@"should not error", ^{
                    error should be_nil;
                });

                it(@"should return the inner mapper's value", ^{
                    parsedObject should equal(@[@1]);
                });
            });

            context(@"when the source object is invalid type for the inner mapper", ^{
                beforeEach(^{
                    sourceObject = @2;
                });

                it(@"should not invoke the inner mapper", ^{
                    innerMapper should_not have_received(@selector(setupAsChildMapperWithMapper:factory:));
                    innerMapper should_not have_received(@selector(objectFromSourceObject:error:));
                });

                it(@"should produce a fatal type error", ^{
                    error should be_a_fatal_error().with_code(JKSErrorInvalidSourceObjectType);
                });
            });

            context(@"when the object is valid to the inner mapper and is the correct type", ^{
                beforeEach(^{
                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_return(@1);
                });

                it(@"should invoke the inner mapper's setup method", ^{
                    innerMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(mapper, Arguments::any([JKSObjectFactory class]));
                });

                it(@"should not error", ^{
                    error should be_nil;
                });

                it(@"should return the object the inner mapper returned", ^{
                    parsedObject should equal(@1);
                });
            });

            context(@"when the inner mapper returns nil from a nil source object", ^{
                beforeEach(^{
                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_return((id)nil);
                });

                it(@"should invoke the inner mapper's setup method", ^{
                    innerMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(mapper, Arguments::any([JKSObjectFactory class]));
                });

                it(@"should not error", ^{
                    error should be_nil;
                });

                it(@"should return the object the inner mapper returned", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the object is valid to the inner mapper but is the incorrect return type", ^{
                beforeEach(^{
                    sourceObject = nil;
                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_return(@"Cheese");
                });

                it(@"should invoke the inner mapper's setup method", ^{
                    innerMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(mapper, Arguments::any([JKSObjectFactory class]));
                });

                it(@"should produce a fatal error with invalid return type", ^{
                    error should be_a_fatal_error().with_code(JKSErrorInvalidResultingObjectType);
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the object is causes an error to the inner mapper", ^{
                __block NSError *innerMapperError;
                beforeEach(^{
                    innerMapperError = [JKSError fatalError];
                    innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_do(^(NSInvocation *invocation) {
                        id returnObject = nil;
                        NSError __autoreleasing **errorPtr = nil;
                        [invocation getArgument:&errorPtr atIndex:3];
                        *errorPtr = innerMapperError;
                        [invocation setReturnValue:&returnObject];
                    });
                });

                it(@"should invoke the inner mapper's setup method", ^{
                    innerMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(mapper, Arguments::any([JKSObjectFactory class]));
                });

                it(@"should bubble up the error", ^{
                    error should be_same_instance_as(innerMapperError);
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });
        });
    });

    describe(@"reverse mapper", ^{
        __block id<JKSMapper> innerReverseMapper;
        __block JKSTypedMapper *reverseMapper;

        beforeEach(^{
            innerReverseMapper = nice_fake_for(@protocol(JKSMapper));
            innerReverseMapper stub_method(@selector(objectFromSourceObject:error:)).and_return(sourceObject);
            innerMapper stub_method(@selector(objectFromSourceObject:error:)).and_return(@1);
            innerMapper stub_method(@selector(reverseMapperWithDestinationKey:)).and_return(innerReverseMapper);

            reverseMapper = [mapper reverseMapperWithDestinationKey:@"KEY"];
        });

        it(@"should pass along the destination key to the inner mapper", ^{
            innerMapper should have_received(@selector(reverseMapperWithDestinationKey:)).with(@"KEY");
        });

        it(@"should use be reverse-compatible with the current mapper", ^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            error should be_nil;

            id result = [reverseMapper objectFromSourceObject:parsedObject error:&error];
            error should be_nil;

            result should equal(sourceObject);
        });
    });
});

SPEC_END
