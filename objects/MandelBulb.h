#pragma once
#include "Dot.h"
#include "Writable.h"
class MandelBulb : public Writable {
public:
	MandelBulb();
	Dot dot;
	double size;
	size_t sizeOf() const;
	void write(void* to);
};

