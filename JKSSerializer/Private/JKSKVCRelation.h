#import <Foundation/Foundation.h>
#import "JKSSerializer.h"
#import "JKSProcessor.h"

@interface JKSKVCRelation : NSObject <JKSProcessor>
@property (strong, nonatomic) NSString *destinationKey;
@property (strong, nonatomic) Class objectClass;
@property (strong, nonatomic) Class destinationClass;
@property (assign, nonatomic) BOOL isArrayOfClass;

+ (instancetype)relationFromArray:(NSArray *)arraySyntax;
- (id)initWithDestinationKey:(NSString *)key
                   fromClass:(Class)objectClass
                     isArray:(BOOL)isArray
          toDestinationClass:(Class)destinationClass;

@end
