#import "JKSPerson.h"

@implementation JKSPerson

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
    return (self.firstName == [object firstName] || [self.firstName isEqual:[object firstName]]) &&
        (self.lastName == [object lastName] || [self.lastName isEqual:[object lastName]]) &&
        self.age == [object age] &&
        (self.parent == (JKSPerson *)[object parent] || [self.parent isEqual:[object parent]]) &&
        (self.siblings == (NSArray *)[object siblings] || [self.siblings isEqual:[object siblings]]) &&
        (self.birthDate == [object birthDate] || [self.birthDate isEqual:[object birthDate]]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p firstName=%@ lastName=%@ age=%lu parent=%@ siblings=%@ birthDate=%@>",
            NSStringFromClass([self class]),
            self,
            self.firstName,
            self.lastName,
            (unsigned long)self.age,
            self.parent,
            self.siblings,
            self.birthDate];
}

@end
