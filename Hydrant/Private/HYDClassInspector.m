#import "HYDClassInspector.h"
#import "HYDProperty.h"
#import <objc/runtime.h>


@interface HYDClassInspector ()

@property (strong, nonatomic) Class aClass;
@property (strong, nonatomic, readwrite) NSArray *properties;
@property (strong, nonatomic, readwrite) NSArray *allProperties;

@end


@implementation HYDClassInspector

static NSMutableDictionary *inspectors__;
static dispatch_queue_t singletonQueue__;

+ (void)initialize
{
    static BOOL wasInitialized;
    if (!wasInitialized) {
        singletonQueue__ = dispatch_queue_create("net.jeffhui.hydrant.singleton", DISPATCH_QUEUE_SERIAL);
        inspectors__ = [NSMutableDictionary dictionary];
        wasInitialized = YES;
    }
}

+ (instancetype)inspectorForClass:(Class)aClass
{
    NSString *key = NSStringFromClass(aClass);
    __block HYDClassInspector *inspector = nil;
    dispatch_sync(singletonQueue__, ^{
        inspector = inspectors__[key];
        if (!inspector) {
            inspectors__[key] = inspector = [[self alloc] initWithClass:aClass];
        }
    });
    return inspector;
}

+ (void)clearInstanceCache
{
    dispatch_sync(singletonQueue__, ^{
        [inspectors__ removeAllObjects];
    });
}

- (id)initWithClass:(Class)aClass
{
    if (self = [super init]) {
        self.aClass = aClass;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<HYDClassInspector: %p for %@>", self, NSStringFromClass(self.aClass)];
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
        _allProperties = properties;
    }
    return _allProperties;
}

@end
