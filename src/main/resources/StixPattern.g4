grammar StixPattern;

pattern
  : observationExpressions EOF
  ;

observationExpressions
  : <assoc=left> observationExpressions FOLLOWEDBY observationExpressions
  | observationExpressionOr
  ;

observationExpressionOr
  : <assoc=left> observationExpressionOr OR observationExpressionOr
  | observationExpressionAnd
  ;

observationExpressionAnd
  : <assoc=left> observationExpressionAnd AND observationExpressionAnd
  | observationExpression
  ;

observationExpression
  : LBRACK comparisonExpression RBRACK        # observationExpressionSimple
  | LPAREN observationExpressions RPAREN      # observationExpressionCompound
  | observationExpression startStopQualifier  # observationExpressionStartStop
  | observationExpression withinQualifier     # observationExpressionWithin
  | observationExpression repeatedQualifier   # observationExpressionRepeated
  ;

comparisonExpression
  : <assoc=left> comparisonExpression OR comparisonExpression   # comparisonExpressionOred
  | comparisonExpressionAnd                                     # comparisonExpressionAnd_
  ;

comparisonExpressionAnd
  : <assoc=left> comparisonExpressionAnd AND comparisonExpressionAnd # comparisonExpressionAnded
  | propTest                                                         # comparisonExpressionAndPropTest
  ;

propTest
  : objectPath NOT? (EQ|NEQ) primitiveLiteral       # propTestEqual
  | objectPath NOT? (GT|LT|GE|LE) orderableLiteral  # propTestOrder
  | objectPath NOT? IN setLiteral                   # propTestSet
  | objectPath NOT? LIKE stringLiteral              # propTestLike
  | objectPath NOT? MATCHES stringLiteral           # propTestRegex
  | objectPath NOT? ISSUBSET stringLiteral          # propTestIsSubset
  | objectPath NOT? ISSUPERSET stringLiteral        # propTestIsSuperset
  | LPAREN comparisonExpression RPAREN              # propTestParen
  | EXISTS objectPath                               # propTestExists
  ;

orderingComparator:
  (GT|LT|GE|LE)
  ;

stringLiteral  // Add parse rule to make getting string literals easier
  : StringLiteral
  ;

startStopQualifier
  : START TimestampLiteral STOP TimestampLiteral
  ;

withinQualifier
  : WITHIN (IntPosLiteral|FloatPosLiteral) SECONDS
  ;

repeatedQualifier
  : REPEATS IntPosLiteral TIMES
  ;

objectPath
  : objectType COLON firstPathComponent objectPathComponent?
  ;

objectType
  : IdentifierWithoutHyphen
  | IdentifierWithHyphen
  ;

firstPathComponent
  : IdentifierWithoutHyphen
  | StringLiteral
  ;

objectPathComponent
  : <assoc=left> objectPathComponent objectPathComponent  # pathStep
  | '.' (IdentifierWithoutHyphen | StringLiteral)         # keyPathStep
  | LBRACK (IntPosLiteral|IntNegLiteral|ASTERISK) RBRACK  # indexPathStep
  ;

setLiteral
  : LPAREN RPAREN
  | LPAREN primitiveLiteral (COMMA primitiveLiteral)* RPAREN
  ;

primitiveLiteral
  : orderableLiteral
  | BoolLiteral
  ;

orderableLiteral
  : IntPosLiteral
  | IntNegLiteral
  | FloatPosLiteral
  | FloatNegLiteral
  | stringLiteral
  | BinaryLiteral
  | HexLiteral
  | TimestampLiteral
  ;

IntNegLiteral :
  '-' ('0' | [1-9] [0-9]*)
  ;

IntPosLiteral :
  '+'? ('0' | [1-9] [0-9]*)
  ;

FloatNegLiteral :
  '-' [0-9]* '.' [0-9]+
  ;

FloatPosLiteral :
  '+'? [0-9]* '.' [0-9]+
  ;

HexLiteral :
  'h' QUOTE TwoHexDigits* QUOTE
  ;

BinaryLiteral :
  'b' QUOTE
  ( Base64Char Base64Char Base64Char Base64Char )*
  ( (Base64Char Base64Char Base64Char Base64Char )
  | (Base64Char Base64Char Base64Char ) '='
  | (Base64Char Base64Char ) '=='
  )
  QUOTE
  ;

StringLiteral :
  QUOTE ( ~['\\] | '\\\'' | '\\\\' )* QUOTE
  ;

BoolLiteral :
  TRUE | FALSE
  ;

TimestampLiteral :
  't' QUOTE
  [0-9] [0-9] [0-9] [0-9] HYPHEN
  ( ('0' [1-9]) | ('1' [012]) ) HYPHEN
  ( ('0' [1-9]) | ([12] [0-9]) | ('3' [01]) )
  'T'
  ( ([01] [0-9]) | ('2' [0-3]) ) COLON
  [0-5] [0-9] COLON
  ([0-5] [0-9] | '60')
  (DOT [0-9]+)?
  'Z'
  QUOTE
  ;

//////////////////////////////////////////////
// Keywords

AND:  'AND' ;
OR:  'OR' ;
NOT:  'NOT' ;
FOLLOWEDBY: 'FOLLOWEDBY';
LIKE:  'LIKE' ;
MATCHES:  'MATCHES' ;
ISSUPERSET:  'ISSUPERSET' ;
ISSUBSET: 'ISSUBSET' ;
EXISTS:  'EXISTS' ;
LAST:  'LAST' ;
IN:  'IN' ;
START:  'START' ;
STOP:  'STOP' ;
SECONDS:  'SECONDS' ;
TRUE:  'true' ;
FALSE:  'false' ;
WITHIN:  'WITHIN' ;
REPEATS:  'REPEATS' ;
TIMES:  'TIMES' ;

// After keywords, so the lexer doesn't tokenize them as identifiers.
// Object types may have unquoted hyphens, but property names
// (in object paths) cannot.
IdentifierWithoutHyphen :
  [a-zA-Z_] [a-zA-Z0-9_]*
  ;

IdentifierWithHyphen :
  [a-zA-Z_] [a-zA-Z0-9_-]*
  ;

EQ        :   '=' | '==';
NEQ       :   '!=' | '<>';
LT        :   '<';
LE        :   '<=';
GT        :   '>';
GE        :   '>=';

QUOTE     : '\'';
COLON     : ':' ;
DOT       : '.' ;
COMMA     : ',' ;
RPAREN    : ')' ;
LPAREN    : '(' ;
RBRACK    : ']' ;
LBRACK    : '[' ;
PLUS      : '+' ;
HYPHEN    : MINUS ;
MINUS     : '-' ;
POWER_OP  : '^' ;
DIVIDE    : '/' ;
ASTERISK  : '*';

fragment HexDigit: [A-Fa-f0-9];
fragment TwoHexDigits: HexDigit HexDigit;
fragment Base64Char: [A-Za-z0-9+/];

// Whitespace and comments
//
WS  :  [ \t\r\n\u000B\u000C\u0085\u00a0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u2028\u2029\u202f\u205f\u3000]+ -> skip
    ;

COMMENT
    :   '/*' .*? '*/' -> skip
    ;

LINE_COMMENT
    :   '//' ~[\r\n]* -> skip
    ;

// Catch-all to prevent lexer from silently eating unusable characters.
InvalidCharacter
    : .
    ;