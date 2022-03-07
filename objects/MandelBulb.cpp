#include "MandelBulb.h"
MandelBulb::MandelBulb() :dot(OBJECT_MANDELBULB), size(1) {}
size_t MandelBulb::sizeOf() const {
	return dot.sizeOf() + sizeof(__int64);
}
void MandelBulb::write(void* to) {
	dot.write(to);
	to = (void*)((char*)to + dot.sizeOf());
	*(double*)to = size;
}