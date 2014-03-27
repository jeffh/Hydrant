#import <Foundation/Foundation.h>


@interface HYDProperty : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary *attributes;

- (id)initWithName:(NSString *)name attributes:(NSDictionary *)attributes;

- (NSString *)encodingType;
- (NSString *)ivarName;
- (Class)classType;
- (BOOL)isEncodingType:(const char *)encoding;
- (BOOL)isObjCObjectType;

@end
