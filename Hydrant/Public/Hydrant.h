// protocols
#import "HYDMapper.h"
#import "HYDAccessor.h"
#import "HYDCollection.h"
#import "HYDMutableCollection.h"

// helpers
#import "HYDDefaultAccessor.h"
#import "HYDError.h"
#import "HYDConstants.h"

// formatters
#import "HYDDotNetDateFormatter.h"
#import "HYDURLFormatter.h"
#import "HYDUUIDFormatter.h"

// value transformers
#import "HYDUnderscoreToLowerCamelCaseTransformer.h"

// accessors
#import "HYDKeyAccessor.h"
#import "HYDKeyPathAccessor.h"

// container mappers
#import "HYDCollectionMapper.h"
#import "HYDTypedMapper.h"
#import "HYDObjectMapper.h"
#import "HYDNonFatalMapper.h"
#import "HYDNotNullMapper.h"
#import "HYDFirstMapper.h"

// standalone mappers
#import "HYDStringToObjectFormatterMapper.h"
#import "HYDObjectToStringFormatterMapper.h"
#import "HYDEnumMapper.h"
#import "HYDIdentityMapper.h"
#import "HYDValueTransformerMapper.h"
#import "HYDReversedValueTransformerMapper.h"

// mappers composed of other mappers or "abstracts" boilerplate
#import "HYDOptionalMapper.h"
#import "HYDReflectiveMapper.h"

// "Escape-Hatch" mappers - Avoid using these when possible.
//
// These mappers expose implementation requirements that HYDMapper requires.
// When using these mappers, you are also responsible for error handling.
//
// In exchange for more code to write, you have more flexibility.
#import "HYDPostProcessingMapper.h"
#import "HYDBlockMapper.h"

