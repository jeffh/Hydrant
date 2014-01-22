#import "JOMClassInspector.h"
#import "JOMProperty.h"
#import <objc/runtime.h>

@interface JOMClassInspector ()
@property (strong, nonatomic) Class aClass;
@property (strong, nonatomic, readwrite) NSArray *properties;
@property (strong, nonatomic, readwrite) NSArray *weakProperties;
@property (strong, nonatomic, readwrite) NSArray *nonWeakProperties;
@end

@implementation JOMClassInspector

static NSMutableDictionary *inspectors__;

+ (instancetype)inspectorForClass:(Class)aClass
{
    NSString *key = NSStringFromClass(aClass);
    @synchronized (self) {
        if (!inspectors__) {
            inspectors__ = [NSMutableDictionary new];
        }
        if (!inspectors__[key]) {
            inspectors__[key] = [[self alloc] initWithClass:aClass];
        }
        return inspectors__[key];
    }
}

- (id)initWithClass:(Class)aClass
{
    if (self = [super init]) {
        self.aClass = aClass;
    }
    return self;
}

- (NSString *)descriptionForObject:(id)object withProperties:(NSArray *)properties
{
    NSMutableString *string = [NSMutableString new];
    [string appendFormat:@"<%@: %p", NSStringFromClass([object class]), object];
    for (JOMProperty *property in properties) {
        NSString *name = property.name;
        id value = [object valueForKey:name];
        [string appendFormat:@" %@=", name];
        if (property.isWeak && value) {
            [string appendFormat:@"<%@: %p>", NSStringFromClass([value class]), value];
        } else {
            [string appendFormat:@"%@", value];
        }
    }
    [string appendString:@">"];
    return string;
}

#pragma mark - Properties

- (NSArray *)nonWeakProperties
{
    if (!_nonWeakProperties){
        _nonWeakProperties = [self.allProperties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isWeak = NO"]];
    }
    return _nonWeakProperties;
}

- (NSArray *)weakProperties
{
    if (!_weakProperties){
        _weakProperties = [self.allProperties filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isWeak = YES"]];
    }
    return _weakProperties;
}

- (NSArray *)properties
{
    if (!_properties){
        NSMutableArray *properties = [NSMutableArray new];
        unsigned int numProperties = 0;
        objc_property_t *objc_properties = class_copyPropertyList(self.aClass, &numProperties);
        for (NSUInteger i=0; i<numProperties; i++) {
            objc_property_t objc_property = objc_properties[i];

            unsigned int numAttributes = 0;
            objc_property_attribute_t *objc_attributes = property_copyAttributeList(objc_property, &numAttributes);
            NSMutableDictionary *attributesDict = [NSMutableDictionary new];
            for (NSUInteger j=0; j<numAttributes; j++) {
                objc_property_attribute_t attribute = objc_attributes[j];
                NSString *key = [NSString stringWithCString:attribute.name encoding:NSUTF8StringEncoding];
                NSString *value = [NSString stringWithCString:attribute.value encoding:NSUTF8StringEncoding];
                attributesDict[key] = value;
            }
            free(objc_attributes);

            NSString *propertyName = [NSString stringWithUTF8String:property_getName(objc_property)];

            [properties addObject:[[JOMProperty alloc] initWithName:propertyName
                                                         attributes:attributesDict]];
        }
        free(objc_properties);
        _properties = properties;
    }
    return _properties;
}

- (NSArray *)allProperties
{
    NSArray *classProperties = self.properties;
    NSSet *classPropertyNames = [NSSet setWithArray:[classProperties valueForKey:@"name"]];
    NSMutableArray *properties = [NSMutableArray new];
    Class parentClass = class_getSuperclass(self.aClass);
    if (parentClass && parentClass != [NSObject class]) {
        for (JOMProperty *property in [[JOMClassInspector inspectorForClass:parentClass] allProperties]) {
            if (![classPropertyNames containsObject:property.name]) {
                [properties addObject:property];
            }
        }
    }
    [properties addObjectsFromArray:classProperties];
    return properties;
}

@end
