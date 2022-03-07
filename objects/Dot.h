#pragma once
#include "math/Matrix.h"
#include "Types.h"
class Dot
{
public:
	unsigned long type;
	Vector3 pos;
	Matrix rot;
	unsigned long mater;
	Dot(unsigned long type);
	size_t sizeOf() const;
	void write(void* to);
};

