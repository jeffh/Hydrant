#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HYDPersonGender) {
    HYDPersonGenderUnknown,
    HYDPersonGenderMale,
    HYDPersonGenderFemale,
};

@interface HYDPerson : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (assign, nonatomic) NSUInteger age;
@property (strong, nonatomic) HYDPerson *parent;
@property (strong, nonatomic) NSArray *siblings;
@property (assign, nonatomic) NSInteger identifier;
@property (strong, nonatomic) NSDate *birthDate;
@property (assign, nonatomic) HYDPersonGender gender;

- (id)initWithFixtureData;

@end
