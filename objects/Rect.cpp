#include "Rect.h"
Rect::Rect() :dot(OBJECT_RECT), bd(1, 1, 1) {}
Rect::Rect(double x, double y, double z, double w, double h, double d) : dot(OBJECT_RECT_NOROT), bd(w, h, d) {
	dot.pos.set(x, y, z);
}
size_t Rect::sizeOf() const {
	return dot.sizeOf() + 3 * sizeof(__int64);
}
void Rect::write(void* to) {
	dot.write(to);
	to = (void*)((char*)to + dot.sizeOf());
	double* m = (double*)to;
	int p = 0;
	m[p++] = bd.x;
	m[p++] = bd.y;
	m[p++] = bd.z;
}