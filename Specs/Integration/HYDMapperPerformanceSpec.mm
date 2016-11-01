#import <Cedar/Cedar.h>
#import "Hydrant.h"
#import <objc/runtime.h>
#import "HYDSPerson.h"
// used for internal cache smashing and performance baselining
#import "HYDClassInspector.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

NSArray *numberOfObjects(NSUInteger times, id object) {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:times];
    for (NSInteger i=0; i<times; i++) {
        [items addObject:object];
    }
    return items;
}

// This captures all object allocations that fix a particular class prefix
NSUInteger numberOfAllocationsOf(const char *classPrefix, void(^block)()) {
    __block NSUInteger allocationCount = 0;
    __block BOOL capturing = NO;
    SEL selector = @selector(alloc);
    size_t classPrefixLength = strlen(classPrefix);
    Method originalMethod = class_getClassMethod([NSObject class], selector);
    IMP originalImpl = method_getImplementation(originalMethod);
    Class metaClass = object_getClass([NSObject class]);
    IMP replacementImpl = imp_implementationWithBlock(^id(id that){
        if (capturing && strncmp(classPrefix, object_getClassName(that), classPrefixLength) == 0) {
            ++allocationCount;
        }
        id (*allocPtr)(id, SEL) = (id (*)(id, SEL))originalImpl;
        return (*allocPtr)(that, selector);
    });
    class_replaceMethod(metaClass, selector, replacementImpl, method_getTypeEncoding(originalMethod));
    @try {
        capturing = YES;
        block();
    }
    @finally {
        capturing = NO;
        class_replaceMethod(metaClass, selector, originalImpl, method_getTypeEncoding(originalMethod));
    }
    return allocationCount;
}

SPEC_BEGIN(HYDMapperPerformanceSpec)

describe(@"HYDMapperPerformance", ^{
    __block NSDictionary *validObject;
    __block NSDictionary *invalidObject;
    __block id<HYDMapper> nonFatalMapper;

    beforeEach(^{
        [HYDClassInspector clearInstanceCache];

        validObject = @{@"id": @1,
                        @"name": @{@"first": @"john",
                                   @"last": @"appleseed"},
                        @"siblings": @[@"John", @"Doe"],
                        @"birthDate": @"2014-01-01T20:19:24.000001",
                        @"gender": @"male",
                        @"age": @"23"};
        invalidObject = @{@"id": @1,
                          @"name": @{@"first": [NSNull null],
                                     @"last": [NSNull null]},
                          @"siblings": @[@"John", @"Doe"],
                          @"birthDate": @"Not A Real Date",
                          @"gender": @"haha",
                          @"age": @"lulzwut"};
        nonFatalMapper = HYDMapArrayOfObjects([HYDSPerson class],
                                              @{@"name.first": @[HYDMapOptionally(), @"firstName"],
                                                @"name.last": @[HYDMapOptionally(), @"lastName"],
                                                @"age": @[HYDMapOptionallyTo(HYDMapNumberToString(NSNumberFormatterDecimalStyle)), @"age"],
                                                @"siblings": @[HYDMapOptionally(), @"siblings"],
                                                @"id": @"identifier",
                                                @"birthDate": @[HYDMapOptionallyTo(HYDMapDateToString(HYDDateFormatRFC3339_milliseconds)), @"birthDate"],
                                                @"gender": @[HYDMapOptionallyWithDefault(HYDMapEnum(@{@"male": @(HYDSPersonGenderMale),
                                                                                                      @"female": @(HYDSPersonGenderFemale)}),
                                                                                         @(HYDSPersonGenderUnknown)),
                                                             @"gender"]});
    });

    context(@"parsing a valid object", ^{
        it(@"should minimize object allocations", ^{
            [HYDClassInspector clearInstanceCache];

            NSArray *sourceObject = numberOfObjects(10, validObject);
            NSUInteger fudgeFactor = 50;
            NSUInteger idealNumberOfAllocations = numberOfAllocationsOf("", ^{
                NSMutableArray *results = [NSMutableArray arrayWithCapacity:sourceObject.count];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = HYDDateFormatRFC3339_milliseconds;

                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

                id (^optional)(id value) = ^id(id value) {
                    if (value && ![[NSNull null] isEqual:value]) {
                        return value;
                    }
                    return nil;
                };

                NSDictionary *enumMapping = @{@"male": @(HYDSPersonGenderMale),
                                              @"female": @(HYDSPersonGenderFemale)};
                for (id item in sourceObject) {
                    HYDSPerson *person = [[HYDSPerson alloc] init];
                    person.firstName = optional([item valueForKeyPath:@"name.first"]);
                    person.lastName = optional([item valueForKeyPath:@"name.last"]);
                    person.age = [[numberFormatter numberFromString:item[@"age"]] unsignedIntegerValue];
                    person.siblings = optional(item[@"sibilings"]);
                    person.identifier = [optional(item[@"id"]) integerValue];
                    if (item[@"birthDate"]) {
                        person.birthDate = [dateFormatter dateFromString:item[@"birthDate"]];
                    }
                    person.gender = (HYDSPersonGender)[enumMapping[item[@"gender"]] integerValue];
                    [results addObject:person];
                }
                [results removeAllObjects];
            });

            NSUInteger numberOfInspectorAllocations = numberOfAllocationsOf("", ^{
                HYDError *error = nil;
                [nonFatalMapper objectFromSourceObject:sourceObject error:&error];
            });
            numberOfInspectorAllocations should be_less_than(idealNumberOfAllocations * fudgeFactor);
        });
    });

    // reflection is a slow operation and should be cached when possible.
    context(@"parsing an invalid object", ^{
        it(@"should not have a large number of property reflection objects", ^{
            [HYDClassInspector clearInstanceCache];

            NSInteger numberOfProperties = 12;
            NSArray *sourceObject = numberOfObjects(1000, invalidObject);
            NSUInteger numberOfPropertyAllocations = numberOfAllocationsOf("HYDProperty", ^{
                HYDError *error = nil;
                [nonFatalMapper objectFromSourceObject:sourceObject error:&error];
                [nonFatalMapper objectFromSourceObject:sourceObject error:&error];
            });
            numberOfPropertyAllocations should be_less_than_or_equal_to(numberOfProperties);
            numberOfPropertyAllocations should be_greater_than(0);
        });

        it(@"should not have a large number of class reflection objects", ^{
            [HYDClassInspector clearInstanceCache];

            NSArray *sourceObject = numberOfObjects(1000, invalidObject);
            NSUInteger numberOfInspectorAllocations = numberOfAllocationsOf("HYDClassInspector", ^{
                HYDError *error = nil;
                [nonFatalMapper objectFromSourceObject:sourceObject error:&error];
                [nonFatalMapper objectFromSourceObject:sourceObject error:&error];
            });
            numberOfInspectorAllocations should equal(1);
        });

        it(@"should minimize object allocations", ^{
            [HYDClassInspector clearInstanceCache];

            NSArray *sourceObject = numberOfObjects(10, invalidObject);
            NSUInteger fudgeFactor = 38;
            NSUInteger idealNumberOfAllocations = numberOfAllocationsOf("", ^{
                NSMutableArray *results = [NSMutableArray arrayWithCapacity:sourceObject.count];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = HYDDateFormatRFC3339_milliseconds;

                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

                id (^optional)(id value) = ^id(id value) {
                    if (value && ![[NSNull null] isEqual:value]) {
                        return value;
                    }
                    return nil;
                };

                NSDictionary *enumMapping = @{@"male": @(HYDSPersonGenderMale),
                                              @"female": @(HYDSPersonGenderFemale)};
                for (id item in sourceObject) {
                    HYDSPerson *person = [[HYDSPerson alloc] init];
                    person.firstName = optional([item valueForKeyPath:@"name.first"]);
                    person.lastName = optional([item valueForKeyPath:@"name.last"]);
                    person.age = [[numberFormatter numberFromString:item[@"age"]] unsignedIntegerValue];
                    person.siblings = optional(item[@"sibilings"]);
                    person.identifier = [optional(item[@"id"]) integerValue];
                    if (item[@"birthDate"]) {
                        person.birthDate = [dateFormatter dateFromString:item[@"birthDate"]];
                    }
                    person.gender = (HYDSPersonGender)[enumMapping[item[@"gender"]] integerValue];
                    [results addObject:person];
                }
                [results removeAllObjects];
            });

            NSUInteger numberOfInspectorAllocations = numberOfAllocationsOf("", ^{
                HYDError *error = nil;
                [nonFatalMapper objectFromSourceObject:sourceObject error:&error];
            });
            numberOfInspectorAllocations should be_less_than(idealNumberOfAllocations * fudgeFactor);
        });
    });

    context(@"parsing an object that generates supressed errors", ^{
        // This example exists to avoid a large number of string allocations because HYDError tend to use +[NSString stringWithFormat:]
        // that caused significant performance regressions.
        it(@"should not have a large number of allocations of strings", ^{
            [HYDClassInspector clearInstanceCache];

            NSArray *sourceObject = numberOfObjects(1000, invalidObject);
            numberOfAllocationsOf("NSString", ^{
                HYDError *error = nil;
                [nonFatalMapper objectFromSourceObject:sourceObject error:&error];
            }) should equal(1); // 1 comes from +[HYDClassInspector inspectorForClass:]
        });
    });

    context(@"parsing an object that generates a fatal error", ^{
        __block id<HYDMapper> mapper;

        beforeEach(^{
            mapper = HYDMapArrayOfObjects([HYDSPerson class],
                                          @{@"name.first": @"firstName",
                                            @"name.last": @"lastName",
                                            @"age": @[HYDMapNumberToString(NSNumberFormatterDecimalStyle), @"age"],
                                            @"siblings": @"siblings",
                                            @"id": @"identifier",
                                            @"birthDate": @[HYDMapDateToString(HYDDateFormatRFC3339_milliseconds), @"birthDate"],
                                            @"gender": @[HYDMapEnum(@{@"male": @(HYDSPersonGenderMale),
                                                                      @"female": @(HYDSPersonGenderFemale)}),
                                                         @"gender"]});
        });

        // This example exists to avoid a large number of string allocations because HYDError tend to use +[NSString stringWithFormat:]
        // that caused significant performance regressions.
        it(@"should not have a large number of allocations of strings", ^{
            [HYDClassInspector clearInstanceCache];

            NSArray *sourceObject = numberOfObjects(1000, invalidObject);
            numberOfAllocationsOf("NSString", ^{
                HYDError *error = nil;
                [mapper objectFromSourceObject:sourceObject error:&error];
                [error description];
            }) should be_less_than(sourceObject.count * invalidObject.count + 1);
            // 1 comes from +[HYDClassInspector inspectorForClass:]
        });
    });
});

SPEC_END
