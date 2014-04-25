#import <Foundation/Foundation.h>


@interface HYDReflectiveMapper ()

@property (strong, nonatomic) id<HYDMapper> innerMapper;
@property (strong, nonatomic) Class sourceClass;
@property (strong, nonatomic) Class destinationClass;

@property (copy, nonatomic) NSSet *optionalFields;
@property (copy, nonatomic) NSSet *onlyFields;
@property (copy, nonatomic) NSSet *excludedFields;
@property (copy, nonatomic) NSDictionary *overriddenMapping;
@property (copy, nonatomic) NSDictionary *typeMapping;
@property (strong, nonatomic) NSValueTransformer *destinationToSourceKeyTransformer;

@property (strong, nonatomic) id<HYDMapper> internalMapper;

- (NSDictionary *)buildMapping;
- (id<HYDMapper>)mapperForProperty:(HYDProperty *)property;

@end
