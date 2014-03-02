// protocols
#import "HYDMapper.h"
#import "HYDAccessor.h"
#import "HYDCollection.h"
#import "HYDMutableCollection.h"

// helpers
#import "HYDError.h"
#import "HYDConstants.h"

// formatters
#import "HYDDotNetDateFormatter.h"
#import "HYDURLFormatter.h"
#import "HYDUUIDFormatter.h"

// value transformers
#import "HYDSnakeToCamelCaseValueTransformer.h"
#import "HYDIdentityValueTransformer.h"
#import "HYDBlockValueTransformer.h"
#import "HYDReversedValueTransformer.h"

// accessors
#import "HYDDefaultAccessor.h"
#import "HYDKeyAccessor.h"
#import "HYDKeyPathAccessor.h"

// container mappers - mappers that require other child mappers to operate
#import "HYDCollectionMapper.h"
#import "HYDTypedMapper.h"
#import "HYDObjectMapper.h"
#import "HYDNonFatalMapper.h"
#import "HYDNotNullMapper.h"
#import "HYDFirstMapper.h"

// standalone mappers - mappers that don't have to rely on another mapper to function
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDEnumMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDValueTransformerMapper.h"
#import "HYDReversedValueTransformerMapper.h"

// mappers composed from a set of classes from above
#import "HYDOptionalMapper.h"
#import "HYDNumberToStringMapper.h"
#import "HYDStringToNumberMapper.h"
#import "HYDDateToStringMapper.h"
#import "HYDStringToDateMapper.h"
#import "HYDURLToStringMapper.h"
#import "HYDStringToURLMapper.h"
#import "HYDUUIDToString.h"
#import "HYDStringToUUIDMapper.h"

// facade mappers - mappers that provide easy interfaces to the simple ones above
#import "HYDReflectiveMapper.h"

// "Escape-Hatch" mappers - Avoid using these when possible.
//
// These mappers expose implementation requirements that HYDMapper requires.
// When using these mappers, you are also responsible for error handling.
//
// In exchange for more code to write, you have more flexibility.
#import "HYDPostProcessingMapper.h"
#import "HYDBlockMapper.h"

