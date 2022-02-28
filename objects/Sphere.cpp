#include "Sphere.h"
Sphere::Sphere():dot(OBJECT_SPHERE), rad2(1) {}
size_t Sphere::sizeOf() const {
	return dot.sizeOf() + sizeof(__int64);
}
void Sphere::write(void* to) {
	dot.write(to);
	to = (void*)((char*)to + dot.sizeOf());
	*(double*)to = rad2;
}