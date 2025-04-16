#ifndef ENCODING_5_BIT_H 
#define ENCODING_5_BIT_H 

#include <XVMem_platform.h> 

UINT32 EncodePOS(const char* input7charsMaxWithHyphen); // input string must be ascii (max 6 chars; or 7 with hyphen in position 1 through 3)
char* DecodePOS(UINT32 encoding);

// These are for Hash64 functionality and related methods taking UINT64
const UINT64 UseFiveBitEncodingOrThreeBitHash = 0x8000000000000000; // hi-order bit marks hash hash-algorithm; helps determine is if hash can be decoded
const UINT64 ThreeBitHashLengthMarker         = 0x7000000000000000; // represents strlen()-12 [1 to 15 means possbible support for strlen() 13 to 27]
const UINT64 ThreeBitHashLengthLowBit		  = 0x1000000000000000; // [represents 1 / strlen() == 13]
const UINT64 ThreeBitHashVowelCounts          = 0x0FFC000000000000; 
const UINT64 ThreeBitHashACountLowBit         = 0x0400000000000000; 
const UINT64 ThreeBitHashECountLowBit         = 0x0100000000000000; 
const UINT64 ThreeBitHashICountLowBit         = 0x0040000000000000; 
const UINT64 ThreeBitHashOCountLowBit         = 0x0010000000000000; 
const UINT64 ThreeBitHashUCountLowBit         = 0x0004000000000000; 
const UINT64 ThreeBitEncodedConsonants        = 0x0003FFFFFFFFFFFF; 
const UINT64 ThreeBitEncodedFirstConsonant    = 0x0000800000000000; 
const UINT64 FiveBitEncodedLetters            = 0x00FFFFFFFFFFFFFF; 
const UINT64 FiveBitEncodedFirstLetter        = 0x0008000000000000; 
const UINT64 ThreeBitEncodingMarkers		  = ThreeBitHashLengthMarker | ThreeBitHashVowelCounts; // These will be zero if 5-bit-encoding is utilized (when zero, hash is decodable)
UINT64 Hash64(const char* nullTerminatedHyphensRemoved); // input string must be ascii lowercase with hyphens-removed (reliability in question when string exceeds length 10
const char* getHashedString(UINT64 hash);
UINT64 Encode(const char* c, bool normalize); // input string must be ascii and cannot exceed 8 and cannot set 0x80000000
UINT64 Encode(const char* c); // input string must be ascii and cannot exceed 8 and cannot set 0x80000000
int Decode(UINT64 hash, char* buffer, int len);

#endif
