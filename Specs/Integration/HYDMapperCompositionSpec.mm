// DO NOT include any other library headers here to simulate an API user.
#import "Hydrant.h"
#import "HYDSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HYDMapperCompositionSpec)

describe(@"Mapper Composition", ^{
    __block id<HYDMapper> mapper;
    __block HYDSPerson *expectedObjectGraph;
    __block NSDictionary *expectedObjectStructure;
    __block HYDError *error;
    __block id parsedObject;

    beforeEach(^{
        HYDDotNetDateFormatter *dotNetDateFormatter = [[HYDDotNetDateFormatter alloc] init];

        mapper = HYDMapObject(HYDRootMapper, [HYDSPerson class],
                              @{@"person": HYDMapObject(@"parent", [NSDictionary class], [HYDSPerson class],
                                                         @{@"id": @"identifier",
                                                           @"name.first": @"firstName",
                                                           @"name.last": @"lastName",
                                                           @"age": HYDMapStringToNumber(@"age"),
                                                           HYDAccessKey(@"birth.date"): HYDMapStringToDate(@"birthDate", dotNetDateFormatter)}),
                                @"identifier": HYDMapNonFatally(HYDMapIdentity(@"identifier")),
                                @"gender": HYDMapEnum(@"gender", @{@"unknown": @(HYDPersonGenderUnknown),
                                                                    @"male": @(HYDPersonGenderMale),
                                                                    @"female": @(HYDPersonGenderFemale)}),
                                @"children": HYDMapArrayOf(HYDMapObject(@"siblings", [NSDictionary class], [HYDSPerson class],
                                                                        @{@"first": @"firstName",
                                                                          @"homepage": HYDMapStringToURL(@"homepage")}))});
        expectedObjectStructure = @{@"person": @{@"id": @1,
                                                 @"name": @{@"first": @"John",
                                                            @"last": @"Doe"},
                                                 @"age": @"22",
                                                 @"birth.date": @"/Date(1390186634595)/"},
                                    @"children": @[@{@"first": @"Bob",
                                                     @"homepage": @"http://example.com"},
                                                   @{@"first": @"David",
                                                     @"homepage": @"http://google.com"}],
                                    @"identifier": @42,
                                    @"gender": @"male"};
        expectedObjectGraph = [[HYDSPerson alloc] init];
        expectedObjectGraph.identifier = 42;
        expectedObjectGraph.gender = HYDPersonGenderMale;
        expectedObjectGraph.parent = ({
            HYDSPerson *parent = [[HYDSPerson alloc] init];
            parent.identifier = 1;
            parent.firstName = @"John";
            parent.lastName = @"Doe";
            parent.age = 22;
            parent.birthDate = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            parent;
        });
        expectedObjectGraph.siblings = ({
            HYDSPerson *person1 = [[HYDSPerson alloc] init];
            person1.firstName = @"Bob";
            person1.homepage = [NSURL URLWithString:@"http://example.com"];
            HYDSPerson *person2 = [[HYDSPerson alloc] init];
            person2.firstName = @"David";
            person2.homepage = [NSURL URLWithString:@"http://google.com"];
            NSArray *items = @[person1, person2];
            items;
        });
    });

    describe(@"mapping from dictionaries to an object graph", ^{
        beforeEach(^{
            parsedObject = [mapper objectFromSourceObject:expectedObjectStructure error:&error];
        });

        it(@"should not error", ^{
            error should be_nil;
        });

        it(@"should build the object graph correctly", ^{
            parsedObject should equal(expectedObjectGraph);
        });
    });

    describe(@"mapping from object graph to dictionaries using the reverse mapper", ^{
        beforeEach(^{
            id<HYDMapper> reverseMapper = [mapper reverseMapperWithDestinationAccessor:nil];
            parsedObject = [reverseMapper objectFromSourceObject:expectedObjectGraph error:&error];
        });

        it(@"should not error", ^{
            error should be_nil;
        });

        it(@"should build the json correctly", ^{
            parsedObject should equal(expectedObjectStructure);
        });
    });
});

SPEC_END
