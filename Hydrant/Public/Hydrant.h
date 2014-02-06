// protocols
#import "HYDMapper.h"
#import "HYDCollection.h"
#import "HYDMutableCollection.h"

// helpers
#import "HYDError.h"
#import "HYDConstants.h"

// formatters
#import "HYDDotNetDateFormatter.h"
#import "HYDURLFormatter.h"
#import "HYDUUIDFormatter.h"

// container mappers
#import "HYDCollectionMapper.h"
#import "HYDTypedMapper.h"
#import "HYDKeyValueMapper.h"
#import "HYDKeyValuePathMapper.h"
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

// mappers composed of other mappers
#import "HYDOptionalMapper.h"

// "Escape-Hatch" mappers - Avoid using these when possible.
//
// These mappers expose implementation requirements that HYDMapper requires.
// When using these mappers, you are also responsible for error handling.
#import "HYDPostProcessingMapper.h"
#import "HYDBlockMapper.h"