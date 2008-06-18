#import <Foundation/NSEnumerator.h>
#import <Foundation/NSString.h>
#import <stddef.h>

@interface RKLMatchEnumerator : NSEnumerator {
  NSString   *string;
  NSString   *regex;
  NSUInteger  location;
}

- (id)initWithString:(NSString *)initString regex:(NSString *)initRegex;

@end

@interface NSString (RegexKitLiteEnumeratorAdditions)
- (NSEnumerator *)matchEnumeratorWithRegex:(NSString *)regexString;
@end
