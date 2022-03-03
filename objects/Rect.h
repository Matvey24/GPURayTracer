#pragma once
#include "Dot.h"
#include "Writable.h"
class Rect : public Writable {
public:
	Rect();
	Dot dot;
	Vector3 bd;
	size_t sizeOf() const;
	void write(void* to);
};

