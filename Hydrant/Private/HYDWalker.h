#import "HYDBase.h"
#import "HYDMapper.h"


@protocol HYDWalkerDelegate;


@interface HYDWalker : NSObject <HYDMapper>

@property (copy, nonatomic, readonly) NSString *destinationKey;
@property (strong, nonatomic, readonly) Class sourceClass;
@property (strong, nonatomic, readonly) Class destinationClass;
@property (strong, nonatomic, readonly) NSDictionary *mapping;
@property (strong, nonatomic, readonly) id<HYDFactory> factory;
@property (weak, nonatomic, readonly) id<HYDWalkerDelegate> delegate;


- (id)initWithDestinationKey:(NSString *)destinationKey
                 sourceClass:(Class)sourceClass
            destinationClass:(Class)destinationClass
                     mapping:(NSDictionary *)mapping
                     factory:(id<HYDFactory>)factory
                    delegate:(id<HYDWalkerDelegate>)delegate;

- (NSDictionary *)inverseMapping;

@end


@protocol HYDWalkerDelegate <NSObject>

- (BOOL)walker:(HYDWalker *)walker shouldReadKey:(NSString *)key onObject:(id)target;
- (id)walker:(HYDWalker *)walker valueForKey:(NSString *)key onObject:(id)target;
- (void)walker:(HYDWalker *)walker setValue:(id)value forKey:(NSString *)key onObject:(id)target;

@end
