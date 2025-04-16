#pragma once
#include <XVMem_platform.h>
#include <vector>

const UINT32 ParsableDefaultMaxLen = 4096;
class slicable
{
public:
	slicable(const char* raw, UINT32 maxLen = ParsableDefaultMaxLen);
	slicable(slicable& str, UINT32 begin, UINT32 end); // substring/slice
	std::vector<slicable*> split(slicable& str, char delimiter); // substrings/slices

	virtual ~slicable();
	const int len;

	inline operator const char* () const { return this->input; }

protected:
	char* input;
	char* slice;
	const bool owner;

	//	Use this carefully, because calling the destructor on the owner will invalidate memory of all copies
	slicable(const slicable& str) : len{ str.len }, owner { false }
	{
		this->input = str.input;
		this->slice = str.slice;
	}
};