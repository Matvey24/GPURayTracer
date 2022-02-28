#pragma once
#include<math.h>
#include <corecrt_math_defines.h>
#include <corecrt_math.h>
class Vector2
{
public:
	double x = 0, y = 0;
	Vector2() {}
	Vector2(const Vector2& oth) :x(oth.x), y(oth.y){}
	Vector2(const double x, const double y): x(x), y(y) {}
	Vector2(const double angle);
	void set(Vector2 oth);
	void set(const double x, const double y);
	void angle(double angle);
	double len2() const;
	double len() const;
	double scl(Vector2 oth) const;
	double vec(Vector2 oth) const;
	void rotateBack(Vector2 ang);
	void rotate(Vector2 ang);
	void norm();
	friend const Vector2 operator-(const Vector2& a);
};
Vector2 operator+(Vector2 a, Vector2 b);
Vector2 operator-(Vector2 a, Vector2 b);
Vector2& operator+=(Vector2& a, Vector2 b);
Vector2& operator-=(Vector2& a, Vector2 b);
Vector2 operator*(Vector2 a, double b);
Vector2& operator*=(Vector2& a, double b);
double operator>>(Vector2 a, Vector2 b);