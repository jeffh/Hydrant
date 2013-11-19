#import <Foundation/Foundation.h>

@interface JKSPerson : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (assign, nonatomic) NSUInteger age;
@property (strong, nonatomic) JKSPerson *parent;
@property (strong, nonatomic) NSArray *siblings;
@property (assign, nonatomic) NSInteger identifier;
@property (strong, nonatomic) NSDate *birthDate;

- (id)initWithFixtureData;

@end
