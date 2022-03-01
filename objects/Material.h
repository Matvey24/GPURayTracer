#pragma once
#ifndef MATERIAL_H_
#define MATERIAL_H_
#include "math/Matrix.h"
struct Material {
	Vector3 diffuse;
	double reflect;
};
#endif