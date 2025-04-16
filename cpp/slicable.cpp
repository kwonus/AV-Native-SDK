#include <slicable.h>

slicable::slicable(const char* raw, UINT32 maxLen)
	: len{ raw != NULL ? 1 + (int)Strnlen(raw, maxLen > 0 ? (int)maxLen : 4096) : -1 }
	, owner{ true }
{
	this->input = (char*) malloc(len+1);
	Strncpy(this->input, raw != NULL ? raw : "", (int)this->len);
	this->slice = len >= 0 ? (char*)malloc(len + 1) : NULL;
	if (this->slice != NULL)
		Strncpy(this->slice, raw, (int)this->len);
}

slicable::slicable(slicable& str, UINT32 start, UINT32 cnt) // substring/slice
: len{ (str.slice != NULL && start < int(this->len) && start + (int) cnt < int(this->len + 1)) ? (int) cnt : (int) -1 }
, owner{ false }
{
	if (this->len >= 0) {
		this->input = str.input + start;
		this->slice = str.slice + start;
		this->slice[cnt] = '\0';
	}
	else {
		this->input = str.input;
		this->slice = NULL;
	}
}

std::vector<slicable*> slicable::split(slicable& str, char delimiter) // substrings/slices
{
	std::vector<slicable*> results;

	if (str.len >= 0) {
		UINT32 previous = 0;
		for (UINT32 i = 0; i < int(str.len); i++)
			if (str.input[i] == delimiter) {
				if (previous < i)	// eliminate empty items
					results.push_back(new slicable(str, previous, i - previous));
				previous = i + 1;
			}
	}
	return results;
}
slicable::~slicable()
{
	if (owner) {
		free(this->input);
		if (this->slice != NULL)
			free(this->slice);
	}
}