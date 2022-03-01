#pragma once
#include "math/Matrix.h"
#include "Types.h"
class Dot
{
public:
	unsigned long type;
	Vector3 pos;
	Vector3 color;
	double reflect;
	Matrix rot;
	Dot(unsigned long type);
	size_t sizeOf() const;
	void write(void* to);
};

