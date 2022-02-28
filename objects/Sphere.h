#pragma once
#include "Dot.h"
#include "Writable.h"
class Sphere: public Writable{
public:
	Sphere();
	Dot dot;
	double rad2;
	size_t sizeOf() const;
	void write(void* to);
};

