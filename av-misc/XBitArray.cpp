#include <XVMem_platform.h>
#include <locale>
#include <string>

#include <unordered_map>
#include <XBitArray.h>

XBitArray255::XBitArray255() {
	for (auto a = 0; a < 16; a++)
		array[a] = 0;
}

XBitArray255::XBitArray255(UINT16 compacted[]) {
	BYTE cnt = 0;
	BYTE a = 0;
	UINT16 bit = 1;

	do {
		if ((compacted[0] & bit) != 0)
			array[a] = compacted[++cnt];
		else
			array[a] = 0;
		a++;
		bit <<= 1;
	}	while (bit != 0);

	for (/**/; a < 16; a++)
		array[a] = 0;
}

XBitArray255::XBitArray255(BYTE items[]) {
	for (auto a = 0; a < 16; a++)
		array[a] = 0;
	if (items != NULL) {
		for (BYTE* position = items; *position; position++)
			SetBit(*position);
	}
}

XBitArray255::XBitArray255(bool positionalBits[], BYTE cnt) {
	for (auto a = 0; a < 16; a++)
		array[a] = 0;
	if (positionalBits != NULL && cnt > 0 && cnt <= 255) {
		BYTE i = 1;
		for (bool* position = positionalBits; i <= 255; position++, i++)
			if (*position)
				SetBit(i);
			else
				UnsetBit(i);
	}
}

bool XBitArray255::SetBit(BYTE item) {
	if (item > 0) {
		BYTE index = (item-1) / 16;
		BYTE local = (item-1) % 16;

		UINT16 loc = 1;
		if (local > 0)
			loc <<= local;
		this->array[index] |= loc;

		return true;
	}
	return false;
}

bool XBitArray255::UnsetBit(BYTE item) {
	if (item > 0) {
		BYTE index = (item - 1) / 16;
		BYTE local = (item - 1) % 16;

		UINT16 loc = 1;
		if (local > 0)
			loc <<= local;
		this->array[index] ^= loc;

		return true;
	}
	return false;
}

void XBitArray255::Add(XBitArray255& operand) {
	for (int i = 0; i < 16; i++) {
		this->array[i] |= operand.array[i];
	}
}
void XBitArray255::Subtract(XBitArray255& operand) {
	UINT16 bit = 1;
	for (int i = 0; i < 16; i++) {
		if (this->array[i] != 0) {
			auto negation = UINT16(0xFFFF ^ operand.array[i]);
			this->array[i] &= negation;
		}
		bit <<= 1;
	}
}

BYTE XBitArray255::GetCompactBitArraySize() {			// up to size=255 BYTE[]	// much less compact
	BYTE countSegments = 1;
	for (auto s = 0; s < 16; s++)
		if (this->array[s] != 0)
			countSegments++;

	return countSegments;
}

UINT16* XBitArray255::CreateCompactBitArray() {	// up to size=17 UINT16[]	// most compact
	int countSegments = 1;
	for (auto s = 0; s < 16; s++)
		if (this->array[s] != 0)
			countSegments++;

	auto result = (UINT16*) malloc((countSegments) * sizeof(UINT16));
	result[0] = 0;
	BYTE cnt = 1;
	UINT16 dir = 0x1;
	for (auto index = 0; index < 16; index++) {
		if (this->array[index] != 0) {
			result[cnt++] = this->array[index];
			result[0] |= dir;
		}
		dir <<= 1;
	}

	return result;
}

BYTE XBitArray255::GetCompactBitArray(UINT16 result[], BYTE maxCnt) {			// up to size=255 BYTE[]	// much less compact
	int countSegments = 1;
	for (auto s = 0; s < 16; s++)
		if (this->array[s] != 0)
			countSegments++;

	result[0] = 0;

	BYTE cnt = 0;
	UINT16 dir = 0x1;
	for (auto index = 0; index < 16; index++) {
		if (this->array[index] != 0) {
			result[++cnt] = this->array[index];
			result[0] |= dir;
		}
		dir <<= 1;
	}
	return countSegments;
}

BYTE* XBitArray255::CreateByteArray() {			// up to size=255 BYTE[]	// much less compact
	BYTE cnt = 0;
	for (auto index = 0; index < 16; index++)
		if (this->array[index] != 0)
			cnt += CountBits(this->array[index]);

	auto result = (BYTE*)malloc(1 + cnt * sizeof(BYTE));
	result[cnt] = 0;
	BYTE baseline = 0;
	BYTE idx = 0;
	for (auto index = 0; index < 16; index++) {
		for (UINT16 bit = 0x1; bit != 0; bit <<= 1) {
			if ((this->array[index] & bit) != 0) {
				BYTE value = 1 + baseline;
				result[idx++] = value;
			}
			baseline++;
		}
	}
	return result;
}

BYTE XBitArray255::GetBoolArray(bool result[], BYTE maxCnt) {// up to size=255 bool[]	// least compact
	BYTE cnt = 0;
	BYTE baseline = 0;
	for (auto index = 0; index < 16; index++) {
		if (this->array[index] != 0) {
			for (UINT16 bit = 1; bit != 0; bit <<= 1) {
				bool on = ((this->array[index] & bit) != 0);
				if (on)
					cnt = baseline + 1;
				if (baseline < maxCnt) {
					array[baseline] = on;
				}
			}
			baseline++;
		}
	}
	return cnt;
}