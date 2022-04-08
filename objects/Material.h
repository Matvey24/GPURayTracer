#pragma once
#ifndef MATERIAL_H_
#define MATERIAL_H_
#include "math/Matrix.h"
#include "Writable.h"
#define MATERIAL_FILL 0
#define MATERIAL_LIGHT 1
#define MATERIAL_TEXTURE 2
class Material: public Writable {
public:
	long type;
	Vector3 diffuse;
	double reflect;
	Material(int rgb, double refl);
	Material(Vector3 rgb, double refl);
	Material(Vector3 rgb);
	size_t sizeOf() const;
	void write(void* to);
};
#endif