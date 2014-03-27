#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import <objc/runtime.h>


@interface HYDClassInspector ()

@property (strong, nonatomic) Class aClass;
@property (strong, nonatomic, readwrite) NSArray *properties;
@property (strong, nonatomic, readwrite) NSArray *allProperties;

@end


@implementation HYDClassInspector

static NSCache *inspectors__;

+ (void)initialize
{
    inspectors__ = [NSCache new];
}

+ (instancetype)inspectorForClass:(Class)aClass
{
    NSString *key = NSStringFromClass(aClass);
    HYDClassInspector *inspector = [inspectors__ objectForKey:key];
    if (!inspector) {
        inspector = [[self alloc] initWithClass:aClass];
        [inspectors__ setObject:inspector forKey:key];
    }
    return inspector;
}

+ (void)clearInstanceCache
{
    [inspectors__ removeAllObjects];
}

- (id)initWithClass:(Class)aClass
{
    if (self = [super init]) {
        self.aClass = aClass;
    }
    return self;
}

#pragma mark - Properties

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

            [properties addObject:[[HYDProperty alloc] initWithName:propertyName
                                                         attributes:attributesDict]];
        }
        free(objc_properties);
        _properties = properties;
    }
    return _properties;
}

- (NSArray *)allProperties
{
    if (!_allProperties) {
        NSArray *classProperties = self.properties;
        NSSet *classPropertyNames = [NSSet setWithArray:[classProperties valueForKey:@"name"]];
        NSMutableArray *properties = [NSMutableArray new];
        Class parentClass = class_getSuperclass(self.aClass);
        if (parentClass && parentClass != [NSObject class]) {
            for (HYDProperty *property in [[HYDClassInspector inspectorForClass:parentClass] allProperties]) {
                if (![classPropertyNames containsObject:property.name]) {
                    [properties addObject:property];
                }
            }
        }
        [properties addObjectsFromArray:classProperties];
        return properties;
        _allProperties = properties;
    }
    return _allProperties;
}

@end
