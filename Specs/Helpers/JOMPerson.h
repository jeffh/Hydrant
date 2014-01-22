#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JOMPersonGender) {
    JOMPersonGenderUnknown,
    JOMPersonGenderMale,
    JOMPersonGenderFemale,
};

@interface JOMPerson : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (assign, nonatomic) NSUInteger age;
@property (strong, nonatomic) JOMPerson *parent;
@property (strong, nonatomic) NSArray *siblings;
@property (assign, nonatomic) NSInteger identifier;
@property (strong, nonatomic) NSDate *birthDate;
@property (assign, nonatomic) JOMPersonGender gender;

- (id)initWithFixtureData;

@end
