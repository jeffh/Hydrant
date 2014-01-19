#import "JKSKeyValuePathMapper.h"
#import "JKSPerson.h"
#import "JKSObjectFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSKeyValuePathMapperSpec)

describe(@"JKSKeyValuePathMapper", ^{
    __block JKSKeyValuePathMapper *mapper;
    __block NSError *error;
    __block JKSPerson *expectedPerson;
    __block NSDictionary *validSourceObject;
    __block id sourceObject;
    __block id parsedObject;
    __block id<JKSMapper> childMapper;

    beforeEach(^{
        expectedPerson = [[JKSPerson alloc] initWithFixtureData];
        validSourceObject = @{@"name": @{@"first": @"John",
                                         @"last": @"Doe"},
                              @"age": @23,
                              @"identifier": @5};

        childMapper = nice_fake_for(@protocol(JKSMapper));
        childMapper stub_method(@selector(destinationKey)).and_return(@"identifier");
        childMapper stub_method(@selector(objectFromSourceObject:error:)).and_do(^(NSInvocation *invocation) {
            id value = nil;
            [invocation getArgument:&value atIndex:2];
            [invocation setReturnValue:&value];
        });
        childMapper stub_method(@selector(reverseMapperWithDestinationKey:)).and_return(childMapper);

        mapper = JKSMapKeyValuePathsTo(@"destinationKey",
                                       [NSDictionary class],
                                       [JKSPerson class],
                                       @{@"name.first": @"firstName",
                                         @"name.last": @"lastName",
                                         @"age": @"age",
                                         @"identifier": childMapper});
    });

    it(@"should return the same destination key it was provided", ^{
        mapper.destinationKey should equal(@"destinationKey");
    });

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"as the root mapper", ^{
            context(@"when a valid source object is given", ^{
                beforeEach(^{
                    sourceObject = validSourceObject;
                });

                it(@"should setup child mappers with itself as the root mapper", ^{
                    childMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(mapper, Arguments::any([JKSObjectFactory class]));
                });

                it(@"should not have any error", ^{
                    error should be_nil;
                });

                it(@"should produce an instance of the class given", ^{
                    parsedObject should be_instance_of([JKSPerson class]);
                });

                it(@"should set all the properties on the parsed object based on the mapping provided", ^{
                    parsedObject should equal(expectedPerson);
                });
            });

            context(@"when a field is missing in the provided source object", ^{
                beforeEach(^{
                    sourceObject = @{@"first_name": @"John",
                                     @"age": @23,
                                     @"id": @5};
                });

                it(@"should have a parse error", ^{
                    error should_not be_nil;
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object is nil", ^{
                beforeEach(^{
                    sourceObject = nil;
                });

                it(@"should not have a parse error", ^{
                    error should be_nil;
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });
        });

        context(@"as a child mapper", ^{
            __block id<JKSMapper> parentMapper;
            __block id<JKSFactory> factory;

            beforeEach(^{
                parentMapper = nice_fake_for(@protocol(JKSMapper));
                factory = [[JKSObjectFactory alloc] init];
                [mapper setupAsChildMapperWithMapper:parentMapper factory:factory];
            });

            context(@"when a valid source object is given", ^{
                beforeEach(^{
                    sourceObject = validSourceObject;
                });

                it(@"should propagate the mapping to its children", ^{
                    childMapper should have_received(@selector(setupAsChildMapperWithMapper:factory:)).with(parentMapper, factory);
                });

                it(@"should not have any error", ^{
                    error should be_nil;
                });

                it(@"should produce an instance of the class given", ^{
                    parsedObject should be_instance_of([JKSPerson class]);
                });

                it(@"should set all the properties on the parsed object based on the mapping provided", ^{
                    parsedObject should equal(expectedPerson);
                });
            });

            context(@"when a field is missing in the provided source object", ^{
                beforeEach(^{
                    sourceObject = @{@"first_name" : @"John",
                                     @"age" : @23,
                                     @"id" : @5};
                });

                it(@"should have a parse error", ^{
                    error should_not be_nil;
                });

                it(@"should return nil", ^{
                    parsedObject should be_nil;
                });
            });

            context(@"when the source object is nil", ^{
                beforeEach(^{
                    sourceObject = nil;
                });

                it(@"should not have a parse error", ^{
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

        beforeEach(^{
            reverseMapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
        });

        it(@"should set the reverse mapper's destinationKey", ^{
            reverseMapper.destinationKey should equal(@"otherKey");
        });

        it(@"should produce the original mapper's source object", ^{
            id result = [reverseMapper objectFromSourceObject:expectedPerson
                                                        error:&error];
            result should be_instance_of([NSDictionary class]).or_any_subclass();
            error should be_nil;
        });

        it(@"should be the inverse of the original mapper", ^{
            id result = [mapper objectFromSourceObject:validSourceObject
                                                 error:&error];
            error should be_nil;
            id derivedSource = [reverseMapper objectFromSourceObject:result error:&error];
            derivedSource should equal(validSourceObject);
            error should be_nil;
        });
    });
});

SPEC_END
