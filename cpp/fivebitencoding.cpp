#include <XVMem_platform.h>
#include <algorithm> 
#include <functional> 
#include <cctype>
#include <locale>
#include <string>

#include <unordered_map>
#include <fivebitencoding.h>

using namespace std;

static std::unordered_map<UINT64, const char*>  hashToString;

const char* getHashedString(UINT64 hash) {
	return hashToString.count(hash) != 0 ? hashToString.at(hash) : NULL;
}

// trim from start (in place)
static inline void ltrim(std::string& str) {
	size_t startpos = str.find_first_not_of(" \t");
	if (string::npos != startpos)
	{
		str = str.substr(startpos);
	}
}

// trim from end (in place)
static inline void rtrim(std::string& str) {
	size_t endpos = str.find_last_not_of(" \t");
	size_t startpos = str.find_first_not_of(" \t");
	if (std::string::npos != endpos)
	{
		str = str.substr(0, endpos + 1);
		str = str.substr(startpos);
	}
	else {
		str.erase(std::remove(std::begin(str), std::end(str), ' '), std::end(str));
	}
}

// trim from both ends (in place)
static inline void trim(std::string& s) {
	ltrim(s);
	rtrim(s);
}

// trim from start (copying)
static inline std::string ltrim_copy(std::string s) {
	ltrim(s);
	return s;
}

// trim from end (copying)
static inline std::string rtrim_copy(std::string s) {
	rtrim(s);
	return s;
}

// trim from both ends (copying)
static inline std::string trim_copy(std::string s) {
	trim(s);
	return s;
}

// For Part-of-Speech:
UINT32 EncodePOS(const char* input7charsMaxWithHyphen) { // input string must be ascii
	auto len = strlen(input7charsMaxWithHyphen);
	if (len < 1 || len > 7)
		return 0;
	auto encoded = (UINT32)0x0;
	auto input = trim_copy(input7charsMaxWithHyphen);
	len = input.length();
	if (len < 1 || len > 7)
		return 0;

	auto hyphen = (UINT32) input.find_first_of("-");
	if (hyphen > 0 && hyphen <= 3)
		hyphen <<= 30;
	else if (len > 6)	// 6 characters max if a compliant hyphen is not part of the string
		return 0;
	else
		hyphen = (UINT32)0x0;

	int c = 0;
	char buffer[6];	// 6x 5bit characters
	for (auto i = 0; i < len; i++) {
		auto b = (BYTE)input[i];
		switch (b) {
			case '-':
				continue;
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
				b -= (BYTE)('0');
				b += (BYTE)(27);
		}
		buffer[c++] = tolower((char) b);
	}
	auto position = (UINT32)0x02000000;
	for (auto i = 0; i < 6 - len; i++) {
		position >>= 5;
	}
	for (auto i = 0; i < len; i++) {
		char letter = char(buffer[i] & 0x1F);
		if (letter == 0)
			break;

		encoded |= (UINT32)letter * position;
		position >>= 5;
	}
	return (UINT32)(encoded | hyphen);
}

//  For Part-of-Speech:
char* DecodePOS(UINT32 encoding) {
	char buffer[7];	// 6x 5bit characters + 2bits for hyphen position = 32 bits;

	auto hyphen = (UINT32)(encoding & 0xC0000000);
	if (hyphen > 0)
		hyphen >>= 30;

	auto index = 0;
	for (auto mask = (UINT32) (0x1F << 25); mask >= 0x1F; mask >>= 5) {
		auto digit = encoding & mask >> (5 * (5 - index));
		if (digit == 0)
			continue;
		BYTE b = (BYTE)digit;
		if (b <= 26)
			b |= 0x60;
		else {
			b -= (BYTE) 27;
			b += (BYTE) '0';
		}
		if (hyphen == index)
			buffer[index++] = '-';
		buffer[index++] = (char) b;
	}
	char* decoded = (char*)malloc((index+1) * sizeof(char));
	for (int i = 0; i < index; i++)
		decoded[i] = buffer[i];
	decoded[index] = 0;
	return decoded;
}
// input string must be ascii lowercase; hyphens are ignored
// - reliability in question when string exceeds length 8 or 12:
// - size <= 8: Entire ascii character set, but ONLY ascii [0x7F]
// - size <= 12: Lowercase-ascii-lettes-only [a-z] preserved using 5-bit encoding
// - size <= 16: values for Digital-AV lexicon ALWAYS hash uniquely using 3-bit encoding, but algorithm tuned for that lexicon
// - size >= 17: NOT TESTED on strings larger than 16! Validate on your daya or collisions handled in your custom code
UINT64 Hash64(const char* token) { 
	if (token == NULL)
		return -1;

	while (*token == ' ' || *token == '\t')
		token++;

	auto len = strlen(token);
	if (len <= 8) {
		UINT64 hash = Encode(token);
		if ((hash & UseFiveBitEncodingOrThreeBitHash) == 0)
			return hash;
	}
	UINT64 hash = UseFiveBitEncodingOrThreeBitHash; // hi-order bit set marks 5-bit or 3-bit encoding

	int ignore = 0; // e.g. hyphens
	for (auto i = 0; i < len; i++) {
		auto c = tolower(token[i]);
		if (c < 'a' || c > 'z')
			ignore++;
	}
	if (len-ignore <= 12)	// 5-bit-encoding
	{
		char buffer[12];	// 12x 5-bit characters
		ignore = 0;
		for (auto i = 0; i < len; i++) {
			auto c = tolower(token[i]);
			if (c >= 'a' && c <= 'z')
				buffer[i-ignore] = c;
			else
				ignore++;
		}
		auto position = FiveBitEncodedFirstLetter;
		len -= ignore;
		for (auto i = 0; i < len; i++) {
			char letter = buffer[i] & 0x1F;
			if (letter == 0)
				break;

			hash |= (UINT64)letter * position;
			position >>= 5;
		}
	}
	else // 3-bit hashes
	{
		UINT64 A, E, I, O, U;
		A = E = I = O = U = 0;

		BYTE buffer[16];	// 16x 3bit hashes
		ignore = 0;

		for (auto i = 0; i < len; i++) {
			if (i - ignore >= 16)
				break;
			auto c = tolower(token[i]);
			switch (c) {
					// vowel = 1;
				case 'a':	if (A < 3) A++;
							buffer[i - ignore] = 0;
							continue;
				case 'e':	if (E < 3) E++;
							buffer[i - ignore] = 0;
							continue;
				case 'i':	if (I < 3) I++;
							buffer[i - ignore] = 0;
							continue;
				case 'o':	if (O < 3) O++;
							buffer[i - ignore] = 0;
							continue;
				case 'u':	if (U < 3) U++;
							buffer[i - ignore] = 0;
							continue;
				case 'b':
				case 'd':
				case 'f':
				case 'g':
				case 'p':	buffer[i - ignore] = 2;
							continue;

				case 'h':
				case 'y':
				case 'r':
				case 'j':
				case 'l':	buffer[i - ignore] = 3;
							continue;
				case 'w':
				case 'v':
				case 'm':
				case 'n':	buffer[i - ignore] = 4;
							continue;
				case 'x':
				case 'z':	buffer[i - ignore] = 5;
							continue;
				case 'q':
				case 'k':
				case 'c':	buffer[i - ignore] = 6;
							continue;
				case 't':	buffer[i - ignore] = 7;
							continue;
				case 's':	buffer[i - ignore] = 1;
							continue;
				default:	ignore++;
			}
		}
		len -= ignore;
		if (len > 16)
			len = 16;

		hash += (A * ThreeBitHashACountLowBit);
		hash += (E * ThreeBitHashECountLowBit);
		hash += (I * ThreeBitHashICountLowBit);
		hash += (O * ThreeBitHashOCountLowBit);
		hash += (U * ThreeBitHashUCountLowBit);

		auto position = ThreeBitEncodedFirstConsonant;
		for (auto i = 0; i < len; i++) {
			BYTE letter = buffer[i] & 0x07;
			hash |= (UINT64)letter * position;
			position >>= 3;
		}
		if (hashToString.count(hash) != 0) {	// don't allow collisions // validate!!!
			const char* previous = hashToString.at(hash);
			int t, p;
			for (t = p = 0; token[t] != 0 && previous[p] != 0; t++, p++) {
				while (token[t] == '-')
					if (token[++t] == 0)
						return 0;
				while (previous[p] == '-')
					if (previous[++p] == 0)
						return 0;
				if (tolower(token[t]) != tolower(previous[p]))
					return 0;
			}
		}
		else hashToString.insert({ hash, token });
	}
	return hash;
}
UINT64 Encode(const char* c, bool normalize) { // input string must be ascii and cannot exceed 8
	UINT64 hash = 0;
	char* chash = (char*)&hash;

	int len = strlen(c);
	if (len > 0)
	{
		for (int i = 0; i < sizeof(UINT64) && *c != char(0); i++) // sizeof(UINT64) == 8
			*chash++ = (normalize ? tolower(*c++) : *c++);
	}
	return hash;
}
UINT64 Encode(const char* c) { // input string must be ascii and cannot exceed 8
	return Encode(c, true);
}
int fivebitencodedStrlen(UINT64 hash) {
	if ((hash & UseFiveBitEncodingOrThreeBitHash) == 0)
		return -1;
	if ((hash & ThreeBitHashLengthMarker) != 0)
		return -1;

	UINT64 bits = 0x1F * FiveBitEncodedFirstLetter;
	for (auto i = 0; i < 12; i++)
		if ((hash & bits) == 0)
			return i;

	return 12;
}
int threebitencodedStrlen(UINT64 hash) {
	if ((hash & UseFiveBitEncodingOrThreeBitHash) == 0)
		return -1;
	if ((hash & ThreeBitHashLengthMarker) != 0)
		return -1;

	auto len = ThreeBitHashLengthMarker & hash;
	len /= ThreeBitHashLengthLowBit;

	return (int) len;
}
int DecodeFiveBitHash(UINT64 hash, char* buffer, int len) {
	if (buffer == NULL || len < 1)
	{
		return -1;
	}
	if ((hash & UseFiveBitEncodingOrThreeBitHash) == 0)
	{
		*buffer = 0;
		return -1;
	}
	int clen = fivebitencodedStrlen(hash);

	if (clen+1 > len)
		return 0-(1+clen);

	auto position = FiveBitEncodedFirstLetter;
	for (auto i = 0; i < clen; i++) {
		UINT64 letter = (hash & (position * 0x1F)) / position;
		*buffer++ = 'a' + (char) (letter - 1);
		position >>= 5;
	}
	*buffer = 0;

	return 1 + clen;
}
int DecodeAscii(UINT64 hash, char* buffer, int len) {
	if ((hash & UseFiveBitEncodingOrThreeBitHash) != 0)
		return 0;

	char* chash = (char*)&hash;
	//	bytes are left-justified
	//
	int clen = (chash[7] == 0) ? strlen(chash) : 8;
	if (buffer != NULL && len >= clen+1) {
		int i;
		for (i = 0; i < clen; i++)
			*buffer++ = *chash++;
		*buffer = 0;
		return clen+1;
	}
	return 0 - (clen+1);
}
const char* LookupThreebitBitHash(UINT64 hash) {
	if (hashToString.count(hash) != 0)
		return hashToString.at(hash);

	return NULL;
}
// Return strlen+1 if successful
// Return (0-strlen+1) if unsuccessful (ussually len is not long enough)
// Return 0 if not decodable or null
int Decode(UINT64 hash, char* buffer, int len) {
	if ((hash & UseFiveBitEncodingOrThreeBitHash) == 0)
		return DecodeAscii(hash, buffer, len);

	if ((hash & ThreeBitHashLengthMarker) == 0)
		return DecodeFiveBitHash(hash, buffer, len);

	const char* result = LookupThreebitBitHash(hash);
	int actual = result != NULL ? 1 + Strnlen(result, len) : 0;
	if (buffer != NULL && len >= 1) {
		if (result != NULL) {
			if (actual < len) {
				Strncpy(buffer, result, actual);
				return actual;
			}
			*buffer = 0;
			return 0 - actual;
		}
		else {
			*buffer = 0;
			return 0;
		}
	}
	else return 0 - actual;
}

// These are no longer used [created for Z-08 / deprecated in Z-14 ]
#ifdef Z08
UINT16* Encode(char* input3charsMax, int maxSegments) { // input string must be ascii
	auto encoded = (UINT16*)NULL;
	auto ld = strlen(input3charsMax);
	if (ld < 1 || ld > 7) {
		return encoded;
	}
	auto last = ld / 3;
	if (ld % 3 == 0)
		last--;
	int le = last + 1;
	if (le > maxSegments)
		return encoded;

	encoded = (UINT16 *) malloc(le * sizeof(UINT16));
	auto i = 0;
	for (i = 0; i < last; i++) {
		encoded[i] = 0x8000; // overflow-bit
	}
	encoded[last] = 0x0000; // termination flag (no overflow)

	auto onsetLen = ld - (3 * last);
	auto start = 3 - onsetLen;
	auto position = (UINT16)(0x0400);
	if (onsetLen < 3)
		position >>= start * 5;

	i = -1;

	for (auto s = 0; s < le; s++) {
		for (auto z = start; z < 3; z++) {
			i++;
			auto b = (BYTE) tolower(input3charsMax[i]);
			switch (b) {
				case '-':
					b = (BYTE)(27); break;
				case '\'':
					b = (BYTE)(28); break;
				case ',':
					b = (BYTE)(29); break;
				case '.':
				case '!':
					b = (BYTE)(30); break;// no room at the inn
				case '?':
					b = (BYTE)(31); break;
				default:
					b &= (BYTE)(0x1F); break;
			}

			if (b == (BYTE) 0)
				break;

			encoded[s] |= (UINT16) (b * position);
			position >>= 5;
		}
		start = 0;
		position = 0x400;
	}
	return encoded;
}

char* Decode(UINT16* encoded) {
	if (encoded != NULL || encoded[0] != 0) {
		char buffer[128];
		UINT16 mask = 0x1F;
		int c = 0;

		for (auto s = 0; /**/; s++) {
			UINT16 segment = encoded[s];
			for (auto bit = (UINT16)(0x01 << 10); bit > 0; bit >>= 5) {
				UINT16 masked = segment & (bit * mask);
				auto digit = (BYTE)(masked / bit);

				if (digit == 0)
					continue;

				if (digit <= 26) {
					digit |= 0x60;
					buffer[c++] = (char)digit;
				}
				else {
					switch (digit) {
					case 27:
						buffer[c++] = ('-'); break;
					case 28:
						buffer[c++] = ('\''); break;
					case 29:
						buffer[c++] = (','); break;
					case 30:
						buffer[c++] = ('.'); break;
					case 31:
						buffer[c++] = ('?'); break;
					}
				}
			}
			if ((segment & 0x8000) == 0)
				break; // this is okay; overflow not set ... we're done even though the array may be bigger
		}
		char* decoded = (char*)malloc((c + 1) * sizeof(char));
		for (int i = 0; i < c; i++)
			decoded[i] = buffer[i];
		decoded[c] = (char) 0;
		return decoded;
	}
}
UINT16 ArrayLen(UINT16* encoded) {
	UINT16 len = 0;
	if (encoded != NULL) {
		len = 1;
		for (auto segment = encoded; *segment & 0x8000 != 0; segment++)
			len++;
	}
	return len;
}
#endif
