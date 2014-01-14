#import "JKSSerializer.h"
#import "JKSPerson.h"

// DO NOT any other library headers here to simulate an API user.

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSKVCMapperSpec)

describe(@"JKSKVCMapper", ^{
    __block JKSKVCMapper *serializer;
    __block JKSPerson *person;
    __block NSError *error;

    beforeEach(^{
        error = nil;
        person = [[[JKSPerson alloc] initWithFixtureData] autorelease];
        serializer = [[[JKSKVCMapper alloc] init] autorelease];
    });

    // TODO: needs tests
    it(@"should be able to parse multiple kinds of classes from a dictionary by its keys", PENDING);

    describe(@"deserialize nested structure as one", ^{
        beforeEach(^{
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"firstName": @"user.first",
                                                @"lastName": @"user.last"}];
        });

        it(@"should serialize", ^{
            NSDictionary *output = [serializer objectFromSourceObject:person error:&error];
            error should be_nil;
            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"user": @{@"first": @"John",
                                             @"last": @"Doe"}});
        });

        it(@"should deserialize", ^{
            NSDictionary *input = @{@"user": @{@"first": @"James",
                                               @"last": @"Taylor"}};
            person = [serializer objectFromSourceObject:input toClass:[JKSPerson class] error:&error];

            error should be_nil;
            JKSPerson *expectedPerson = [[JKSPerson new] autorelease];
            expectedPerson.firstName = @"James";
            expectedPerson.lastName = @"Taylor";
            person should equal(expectedPerson);
        });
    });

    describe(@"different serialization / deserialization", ^{
        beforeEach(^{
            [serializer serializeClass:[JKSPerson class]
                               toClass:[NSDictionary class]
                           withMapping:@{@"firstName": @"first",
                                         @"lastName": @"last"}];
            [serializer serializeClass:[NSDictionary class]
                               toClass:[JKSPerson class]
                           withMapping:@{@"f": @"firstName",
                                         @"l": @"lastName"}];
        });

        it(@"should serialize", ^{
            NSMutableDictionary *output = [serializer objectFromSourceObject:person error:&error];
            error should be_nil;
            output should equal(@{@"first": @"John",
                                  @"last": @"Doe"});
        });

        it(@"should deserialize", ^{
            NSDictionary *input = @{@"f": @"James",
                                    @"l": @"Taylor"};
            person = [serializer objectFromSourceObject:input error:&error];

            error should be_nil;
            JKSPerson *expectedPerson = [[JKSPerson new] autorelease];
            expectedPerson.firstName = @"James";
            expectedPerson.lastName = @"Taylor";
            person should be_instance_of([JKSPerson class]);
            person should equal(expectedPerson);
        });
    });

    describe(@"basic serialization", ^{
        beforeEach(^{
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"firstName": @"first",
                                                @"lastName": @"last",
                                                @"age": @"age",
                                                @"parent": @"parent"}];
        });

        it(@"should serialize basic properties", ^{
            serializer.nullObject = [NSNull null];
            NSMutableDictionary *output = [serializer objectFromSourceObject:person error:&error];

            error should be_nil;
            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"first": @"John",
                                  @"last": @"Doe",
                                  @"age": @23,
                                  @"parent": [NSNull null]});
        });

        it(@"should deserialize basic properties", ^{
            NSDictionary *input = @{@"first": @"John",
                                    @"last": @"Doe",
                                    @"age": @23,
                                    @"parent": [NSNull null]};
            JKSPerson *outputPerson = [serializer objectFromSourceObject:input error:&error];

            outputPerson should be_instance_of([JKSPerson class]);
            outputPerson should equal(person);
        });
    });

    describe(@"enum serialization", ^{
        context(@"as their native types", ^{
            beforeEach(^{
                serializer.nullObject = [NSNull null];
                [serializer serializeBetweenClass:[JKSPerson class]
                                         andClass:[NSDictionary class]
                                      withMapping:@{@"gender": @"gender"}];
            });

            it(@"should serialize enums", ^{
                person.gender = JKSPersonGenderMale;
                NSMutableDictionary *output = [serializer objectFromSourceObject:person error:&error];

                error should be_nil;
                output should be_instance_of([NSDictionary class]).or_any_subclass();
                output should equal(@{@"gender": @1});
            });

            it(@"should deserialize enums", ^{
                serializer.nullObject = nil;
                JKSPerson *outputPerson = [serializer objectFromSourceObject:@{@"gender" : @1} error:&error];
                error should be_nil;
                outputPerson.gender should equal(JKSPersonGenderMale);
            });
        });

        context(@"as a custom mapping", ^{
            beforeEach(^{
                serializer.nullObject = [NSNull null];
                [serializer serializeBetweenClass:[JKSPerson class]
                                         andClass:[NSDictionary class]
                                      withMapping:@{@"gender": JKSEnum(@"gender", @{@(JKSPersonGenderUnknown): @"unknown",
                                                                                    @(JKSPersonGenderMale): @"male",
                                                                                    @(JKSPersonGenderFemale): @"female"})}];
            });

            it(@"should serialize enums", ^{
                person.gender = JKSPersonGenderMale;
                NSMutableDictionary *output = [serializer objectFromSourceObject:person error:&error];

                error should be_nil;
                output should be_instance_of([NSDictionary class]).or_any_subclass();
                output should equal(@{@"gender": @"male"});
            });

            it(@"should deserialize enums", ^{
                serializer.nullObject = nil;
                JKSPerson *outputPerson = [serializer objectFromSourceObject:@{@"gender" : @"male"} error:&error];
                error should be_nil;
                outputPerson.gender should equal(JKSPersonGenderMale);
            });
        });
    });

    describe(@"number serialization", ^{
        __block NSString *numberString;

        beforeEach(^{
            person.age = 1234567;
            numberString = [NSNumberFormatter localizedStringFromNumber:@(person.age) numberStyle:NSNumberFormatterScientificStyle];

            serializer.nullObject = [NSNull null];
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"age": JKSNumberToString(@"age", NSNumberFormatterScientificStyle)}];
        });

        it(@"should serialize dates", ^{
            NSMutableDictionary *output = [serializer objectFromSourceObject:person error:&error];
            error should be_nil;
            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"age": numberString});
        });

        it(@"should deserialize dates", ^{
            serializer.nullObject = nil;
            JKSPerson *outputPerson = [serializer objectFromSourceObject:@{@"age" : numberString} error:&error];
            error should be_nil;
            outputPerson.age should equal(person.age);
        });
    });

    describe(@"date serialization", ^{
        __block NSDate *date;

        beforeEach(^{
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.calendar = [NSCalendar currentCalendar];
            components.timeZone = [NSTimeZone defaultTimeZone];
            components.year = 2012;
            components.month = 2;
            components.day = 1;
            components.hour = 13;
            components.minute = 30;
            components.second = 45;
            date = [components date];

            serializer.nullObject = [NSNull null];
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"birthDate": JKSDateToString(@"birthday", @"yyyy-MM-dd'T'HH:mm:ss'Z'")}];
        });

        it(@"should serialize dates", ^{
            person.birthDate = date;
            NSMutableDictionary *output = [serializer objectFromSourceObject:person error:&error];

            error should be_nil;
            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"birthday": @"2012-02-01T13:30:45Z"});
        });

        it(@"should deserialize dates", ^{
            serializer.nullObject = nil;
            JKSPerson *outputPerson = [serializer objectFromSourceObject:@{@"birthday" : @"2012-02-01T13:30:45Z"} error:&error];
            error should be_nil;
            outputPerson.birthDate should equal(date);
        });
    });

    describe(@"collection serialization", ^{
        beforeEach(^{
            person.siblings = @[[[[JKSPerson alloc] initWithFixtureData] autorelease],
                                [[[JKSPerson alloc] initWithFixtureData] autorelease]];
            serializer.nullObject = [NSNull null];
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"firstName": @"first",
                                                @"siblings": JKSArrayOf(@"siblings", [JKSPerson class], [NSDictionary class])}];
        });

        it(@"should serialize collections", ^{
            NSMutableDictionary *output = [serializer objectFromSourceObject:person error:&error];
            error should be_nil;
            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"first": @"John",
                                  @"siblings": @[@{@"first": @"John", @"siblings": [NSNull null]},
                                                 @{@"first": @"John", @"siblings": [NSNull null]}]});
        });

        it(@"should deserialize collections", ^{
            serializer.nullObject = nil;
            JKSPerson *outputPerson = [serializer objectFromSourceObject:@{@"first" : @"John",
                                                                           @"siblings" : @[@{@"first" : @"John", @"siblings" : [NSNull null]},
                                                                                           @{@"first" : @"John", @"siblings" : [NSNull null]}]}
                                                                   error:&error];
            error should be_nil;
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
            parent = [[[JKSPerson alloc] init] autorelease];
            parent.firstName = @"James";
            parent.lastName = @"Taylor";
            parent.age = 11;
            person.parent = parent;
            serializer.nullObject = [NSNull null];
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"firstName": @"first",
                                                @"lastName": @"last",
                                                @"age": @"age",
                                                @"parent": JKSDictionaryRelation(@"aParent", [JKSPerson class])}];
        });

        it(@"should recursively serialize", ^{
            NSMutableDictionary *output = [serializer objectFromSourceObject:person error:&error];

            error should be_nil;
            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"first": @"John",
                                  @"last": @"Doe",
                                  @"age": @23,
                                  @"aParent": @{@"first": @"James",
                                                @"last": @"Taylor",
                                                @"age": @11,
                                                @"aParent": [NSNull null]}});
        });

        it(@"should recursively deserialize", ^{
            serializer.nullObject = nil;
            NSDictionary *input = @{@"first": @"John",
                                    @"last": @"Doe",
                                    @"age": @23,
                                    @"aParent": @{@"first": @"James",
                                                  @"last": @"Taylor",
                                                  @"age": @11,
                                                  @"aParent": [NSNull null]}};
            JKSPerson *outputPerson = [serializer objectFromSourceObject:input error:&error];

            error should be_nil;
            outputPerson should be_instance_of([JKSPerson class]);
            outputPerson should equal(person);
        });
    });
});

SPEC_END
