#ifndef XBITARRAY_255_H 
#define XBITARRAY_255_H 

#include <XVMem_platform.h> 

class XBitArray255
{
protected:
	UINT16 array[16];

public:
	XBitArray255();
	XBitArray255(UINT16 compacted[]);
	XBitArray255(BYTE items[]);	// zero-terminated
	XBitArray255(bool positionalBits[], BYTE cnt);
	virtual ~XBitArray255() {};

	bool SetBit(BYTE item);
	bool UnsetBit(BYTE item);
	void Add(XBitArray255& operand);
	void Subtract(XBitArray255& operand);

	UINT16* CreateCompactBitArray();	// up to size=17 UINT16[]	// most compact // min size: 16 bits; Typical: 32 bits <= size <= 64 bits
	BYTE GetCompactBitArraySize();
	BYTE GetCompactBitArray(UINT16 array[], BYTE maxCnt);
	BYTE* CreateByteArray();			// up to size=255 BYTE[]	// much less compact
	BYTE GetBoolArray(bool array[], BYTE maxCnt);	// up to size=255 bool[]	// least compact

	static BYTE CountBits(UINT16 bitSegment) {
		BYTE cnt = 0;
		do {
			if ((bitSegment & 0x1) != 0)
				cnt++;
			bitSegment >>= 1;
		}	while (bitSegment != 0);
		return cnt;
	}
};

#endif
