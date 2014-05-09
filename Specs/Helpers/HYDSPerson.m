#import "HYDSPerson.h"

@implementation HYDSPerson

- (id)initWithFixtureData
{
    self = [super init];
    if (self) {
        self.firstName = @"John";
        self.lastName = @"Doe";
        self.age = 23;
        self.identifier = 5;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    return \
        (self.fullName == [object fullName] || [self.fullName isEqual:[object fullName]]) &&
        (self.firstName == [object firstName] || [self.firstName isEqual:[object firstName]]) &&
        (self.lastName == [object lastName] || [self.lastName isEqual:[object lastName]]) &&
        self.age == [object age] &&
        (self.parent == (HYDSPerson *)[object parent] || [self.parent isEqual:[object parent]]) &&
        (self.siblings == (NSArray *)[object siblings] || [self.siblings isEqual:[object siblings]]) &&
        (self.birthDate == [object birthDate] || [self.birthDate isEqual:[object birthDate]]) &&
        (self.gender == [object gender]) &&
        (self.homepage == self.homepage || [self.homepage isEqual:[object homepage]]) &&
        (self.incomeInThousands == [object incomeInThousands]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p fullName=%@ firstName=%@ lastName=%@ age=%lu parent=%@ siblings=%@ birthDate=%@ gender=%lu homepage=%@ incomeInThousands=%f>",
            NSStringFromClass([self class]),
            self,
            self.fullName,
            self.firstName,
            self.lastName,
            (unsigned long)self.age,
            self.parent,
            self.siblings,
            self.birthDate,
            (unsigned long)self.gender,
            self.homepage,
            self.incomeInThousands];
}

@end
