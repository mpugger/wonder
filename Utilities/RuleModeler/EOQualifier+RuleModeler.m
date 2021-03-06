/*
 EOQualifier+RuleModeler.m
 RuleModeler
 
 Created by davelopper on 2/10/07.


 Copyright (c) 2004-2007, Project WONDER <http://wonder.sourceforge.net/>
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification, 
 are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  * Neither the name of the Project WONDER nor the names of its contributors may
    be used to endorse or promote products derived from this software without
    specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "EOQualifier+RuleModeler.h"


@implementation NSObject(RMFormattedDescription)

- (NSString *)formattedDescription {
    return [self description];
}

@end

@implementation EOQualifier(RuleModeler)

- (NSString *)formattedDescription {
    return [self formattedDescriptionWithIndentLevel:0];
}

- (NSString *)formattedDescriptionWithIndentLevel:(unsigned)indentLevel {
    return [self description];
}

- (NSSet *)allKeyPaths {
    return [NSSet set];
}

- (NSSet *)allStringValues {
    return [NSSet set];
}

@end

@implementation EOAndQualifier(RuleModeler)

- (NSString *)formattedDescriptionWithIndentLevel:(unsigned)indentLevel {
    NSMutableString *ms;
    unsigned i, len;
    NSString *indentString;
    
    if ((len = [self->qualifiers count]) == 0)
        return nil;
    if (len == 1)
        return [[self->qualifiers objectAtIndex:0] formattedDescription];

    indentString = [NSString stringWithFormat:@"%*s", indentLevel, ""];
    ms = [NSMutableString stringWithCapacity:(len * 16)];
    [ms appendString:@"("];
    for (i = 0; i < len; i++) {
        if (i != 0) [ms appendFormat:@" and\n%@ ", indentString];        
        [ms appendString:[[self->qualifiers objectAtIndex:i] formattedDescriptionWithIndentLevel:indentLevel + 1]];
    }
    [ms appendFormat:@"\n%@)", indentString];
    return ms;
}

- (NSSet *)allKeyPaths {
    NSArray         *subQualifiersKeyPaths = [self->qualifiers valueForKey:@"allKeyPaths"]; // Array of sets
    NSMutableSet    *allKeyPaths = [NSMutableSet set];
    NSEnumerator    *anEnum = [subQualifiersKeyPaths objectEnumerator];
    NSSet           *eachSet;
    
    while(eachSet = [anEnum nextObject])
        [allKeyPaths unionSet:eachSet];
    
    return allKeyPaths;
}

- (NSSet *)allStringValues {
    NSArray         *subQualifiersStringValues = [self->qualifiers valueForKey:@"allStringValues"]; // Array of sets
    NSMutableSet    *allStringValues = [NSMutableSet set];
    NSEnumerator    *anEnum = [subQualifiersStringValues objectEnumerator];
    NSSet           *eachSet;
    
    while(eachSet = [anEnum nextObject])
        [allStringValues unionSet:eachSet];
    
    return allStringValues;
}

@end

@implementation EOOrQualifier(RuleModeler)

- (NSString *)formattedDescriptionWithIndentLevel:(unsigned)indentLevel {
    NSMutableString *ms;
    unsigned i, len;
    NSString *indentString;
    
    if ((len = [self->qualifiers count]) == 0)
        return nil;
    if (len == 1)
        return [[self->qualifiers objectAtIndex:0] formattedDescription];

    indentString = [NSString stringWithFormat:@"%*s", indentLevel, ""];
    ms = [NSMutableString stringWithCapacity:(len * 16)];
    [ms appendString:@"("];
    for (i = 0; i < len; i++) {
        if (i != 0) [ms appendFormat:@" or\n%@ ", indentString];        
        [ms appendString:[[self->qualifiers objectAtIndex:i] formattedDescriptionWithIndentLevel:indentLevel + 1]];
    }
    [ms appendFormat:@"\n%@)", indentString];
    return ms;
}

- (NSSet *)allKeyPaths {
    NSArray         *subQualifiersKeyPaths = [self->qualifiers valueForKey:@"allKeyPaths"]; // Array of sets
    NSMutableSet    *allKeyPaths = [NSMutableSet set];
    NSEnumerator    *anEnum = [subQualifiersKeyPaths objectEnumerator];
    NSSet           *eachSet;
    
    while(eachSet = [anEnum nextObject])
        [allKeyPaths unionSet:eachSet];
    
    return allKeyPaths;
}

- (NSSet *)allStringValues {
    NSArray         *subQualifiersStringValues = [self->qualifiers valueForKey:@"allStringValues"]; // Array of sets
    NSMutableSet    *allStringValues = [NSMutableSet set];
    NSEnumerator    *anEnum = [subQualifiersStringValues objectEnumerator];
    NSSet           *eachSet;
    
    while(eachSet = [anEnum nextObject])
        [allStringValues unionSet:eachSet];
    
    return allStringValues;
}

@end

@implementation EONotQualifier(RuleModeler)

- (NSString *)formattedDescriptionWithIndentLevel:(unsigned)indentLevel {
    NSString *qd;
    
    qd = [self->qualifier formattedDescriptionWithIndentLevel:indentLevel];
    
    if (([self->qualifier isKindOfClass:[EOKeyValueQualifier class]] || [self->qualifier isKindOfClass:[EOKeyComparisonQualifier class]]) && ![[self class] useParenthesesForComparisonQualifier])
        return [[@"not (" stringByAppendingString:qd] stringByAppendingString:@")"];
    else
        return [@"not " stringByAppendingString:qd];
}

- (NSSet *)allKeyPaths {
    return [self->qualifier allKeyPaths];
}

- (NSSet *)allStringValues {
    return [self->qualifier allStringValues];
}

@end

@implementation EOKeyValueQualifier(RuleModeler)

- (NSSet *)allKeyPaths {
    if (self->key)
        return [NSSet setWithObject:self->key];
    else
        return [NSSet set];
}

- (NSSet *)allStringValues {
    if ([self->value isKindOfClass:[NSString class]])
        return [NSSet setWithObject:self->value];
    else
        return [NSSet set];
}

@end

@implementation EOKeyComparisonQualifier(RuleModeler)

- (NSSet *)allKeyPaths {
    if (self->leftKey)
        return [NSSet setWithObjects:self->leftKey, self->rightKey, nil];
    else
        return [NSSet setWithObjects:self->rightKey, nil];
}

@end

