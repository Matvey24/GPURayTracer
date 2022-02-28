#pragma once
#include "Vector2.h"
class Vector3
{
public:
	double x = 0, y = 0, z = 0;
	Vector3(){}
	Vector3(const Vector3& oth) :x(oth.x), y(oth.y), z(oth.z){}
	Vector3(const double x, const double y, const double z) :x(x), y(y), z(z) {}
	void set(Vector3 oth);
	void set(const double x, const double y, const double z);
	double len2() const;
	double len() const;
	double scl(Vector3 oth) const;
	void mult(Vector3 oth);
	void norm();
	bool isZero();
	friend const Vector3 operator-(const Vector3& a);
};
Vector3 operator+(Vector3 a, Vector3 b);
Vector3 operator-(Vector3 a, Vector3 b);
Vector3& operator+=(Vector3& a, Vector3 b);
Vector3& operator-=(Vector3& a, Vector3 b);
Vector3 operator*(Vector3 a, double b);
Vector3 operator*(Vector3 a, Vector3 b);
Vector3& operator*=(Vector3& a, double b);
Vector3& operator*=(Vector3& a, Vector3 b);
double operator>>(Vector3 a, Vector3 b);
