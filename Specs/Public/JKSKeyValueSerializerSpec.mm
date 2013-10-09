#import "JKSKeyValueSerializer.h"
#import "JKSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSKeyValueSerializerSpec)

describe(@"JKSKeyValueSerializer", ^{
    __block JKSKeyValueSerializer *serializer;
    __block JKSPerson *person;

    beforeEach(^{
        person = [[[JKSPerson alloc] initWithFixtureData] autorelease];
        serializer = [[[JKSKeyValueSerializer alloc] init] autorelease];
    });

    describe(@"basic serialization", ^{
        beforeEach(^{
            [serializer registerClass:[JKSPerson class]
                          withMapping:@{@"firstName": @"first",
                                        @"lastName": @"last",
                                        @"age": @"age",
                                        @"parent": @"parent"}];
        });

        it(@"should serialize basic properties", ^{
            NSMutableDictionary *output = [[NSMutableDictionary new] autorelease];
            [serializer serializeToObject:output fromObject:person nullObject:nil];

            output should equal(@{@"first": @"John",
                                  @"last": @"Doe",
                                  @"age": @23});
        });

        it(@"should deserialize basic properties", ^{
            NSDictionary *input = @{@"first": @"John",
                                    @"last": @"Doe",
                                    @"age": @23};
            JKSPerson *outputPerson = [[[JKSPerson alloc] init] autorelease];
            [serializer deserializeToObject:outputPerson fromObject:input nullObject:nil];

            outputPerson should equal(person);
        });
    });

    describe(@"collection serialization", ^{
        beforeEach(^{
            person.siblings = @[[[[JKSPerson alloc] initWithFixtureData] autorelease],
                                [[[JKSPerson alloc] initWithFixtureData] autorelease]];
            [serializer registerClass:[JKSPerson class]
                          withMapping:@{@"firstName": @"first",
                                        @"siblings": @[@"siblings", @[[JKSPerson class]], [NSMutableDictionary class]]}];
        });

        it(@"should serialize collections", ^{
            NSMutableDictionary *output = [[NSMutableDictionary new] autorelease];
            [serializer serializeToObject:output fromObject:person nullObject:[NSNull null]];

            output should equal(@{@"first": @"John",
                                  @"siblings": @[@{@"first": @"John", @"siblings": [NSNull null]},
                                                 @{@"first": @"John", @"siblings": [NSNull null]}]});
        });

        it(@"should deserialize collections", ^{
            JKSPerson *outputPerson = [[[JKSPerson alloc] init] autorelease];
            [serializer deserializeToObject:outputPerson
                                 fromObject:@{@"first": @"John",
                                              @"siblings": @[@{@"first": @"John", @"siblings": [NSNull null]},
                                                             @{@"first": @"John", @"siblings": [NSNull null]}]}
                                 nullObject:nil];

            JKSPerson *expectedPerson = [[[JKSPerson alloc] init] autorelease];
            expectedPerson.firstName = @"John";
            JKSPerson *sibling1 = [[[JKSPerson alloc] init] autorelease];
            sibling1.firstName = @"John";
            JKSPerson *sibling2 = [[[JKSPerson alloc] init] autorelease];
            sibling2.firstName = @"John";
            expectedPerson.siblings = @[sibling1, sibling2];

            outputPerson should equal(expectedPerson);
        });
    });

    describe(@"relationship serialization", ^{
        __block JKSPerson *parent;
        beforeEach(^{
            parent = [[JKSPerson alloc] init];
            parent.firstName = @"James";
            parent.lastName = @"Taylor";
            parent.age = 11;
            person.parent = parent;
            [serializer registerClass:[JKSPerson class]
                          withMapping:@{@"firstName": @"first",
                                        @"lastName": @"last",
                                        @"age": @"age",
                                        @"parent": @[@"aParent", [JKSPerson class], [NSMutableDictionary class]]}];
        });

        it(@"should recursively serialize", ^{
            NSMutableDictionary *output = [[NSMutableDictionary new] autorelease];
            [serializer serializeToObject:output fromObject:person nullObject:[NSNull null]];

            output should equal(@{@"first": @"John",
                                  @"last": @"Doe",
                                  @"age": @23,
                                  @"aParent": @{@"first": @"James",
                                                @"last": @"Taylor",
                                                @"age": @11,
                                                @"aParent": [NSNull null]}});
        });

        it(@"should recursively deserialize", ^{
            NSDictionary *input = @{@"first": @"John",
                                    @"last": @"Doe",
                                    @"age": @23,
                                    @"aParent": @{@"first": @"James",
                                                  @"last": @"Taylor",
                                                  @"age": @11,
                                                  @"aParent": [NSNull null]}};
            JKSPerson *outputPerson = [[[JKSPerson alloc] init] autorelease];
            [serializer deserializeToObject:outputPerson fromObject:input nullObject:[NSNull null]];

            outputPerson should equal(person);
        });
    });
});

SPEC_END
