#pragma once
#include "Dot.h"
#include "Writable.h"
class Rect : public Writable {
public:
	Rect();
	Rect(double x, double y, double z, double w, double h, double d);
	Dot dot;
	Vector3 bd;
	size_t sizeOf() const;
	void write(void* to);
};

