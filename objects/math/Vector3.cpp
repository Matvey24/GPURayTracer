#include "Vector3.h"
void Vector3::set(Vector3 oth) {
	x = oth.x;
	y = oth.y;
	z = oth.z;
}
void Vector3::set(const double x, const double y, const double z) {
	this->x = x;
	this->y = y;
	this->z = z;
}
double Vector3::len2() const {
	return x * x + y * y + z * z;
}
double Vector3::len() const {
	return sqrt(len2());
}
double Vector3::scl(Vector3 oth) const {
	return x * oth.x + y * oth.y + z * oth.z;
}
void Vector3::norm() {
	double len = this->len();
	x /= len;
	y /= len;
	z /= len;
}
void Vector3::mult(Vector3 oth) {
	x *= oth.x;
	y *= oth.y;
	z *= oth.z;
}
bool Vector3::isZero() {
	return x == 0 && y == 0 && z == 0;
}
const Vector3 operator-(const Vector3& a) {
	return Vector3(-a.x, -a.y, -a.z);
}
Vector3 operator+(Vector3 a, Vector3 b) {
	return Vector3(a.x + b.x, a.y + b.y, a.z + b.z);
}
Vector3 operator-(Vector3 a, Vector3 b) {
	return Vector3(a.x - b.x, a.y - b.y, a.z - b.z);
}
Vector3& operator+=(Vector3& a, Vector3 b) {
	a.x += b.x;
	a.y += b.y;
	a.z += b.z;
	return a;
}
Vector3& operator-=(Vector3& a, Vector3 b) {
	a.x -= b.x;
	a.y -= b.y;
	a.z -= b.z;
	return a;
}
Vector3 operator*(Vector3 a, Vector3 b) {
	return Vector3(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x);
}
Vector3 operator*(Vector3 a, double b) {
	return Vector3(a.x * b, a.y * b, a.z * b);
}
Vector3& operator*=(Vector3& a, double b) {
	a.x *= b;
	a.y *= b;
	a.z *= b;
	return a;
}
Vector3& operator*=(Vector3& a, Vector3 b) {
	a.x = a.y * b.z - a.z * b.y;
	a.y = a.z * b.x - a.x * b.z;
	a.z = a.x * b.y - a.y * b.x;
	return a;
}
double operator>>(Vector3 a, Vector3 b) {
	double x = a.x - b.x;
	double y = a.y - b.y;
	double z = a.z - b.z;
	return sqrt(x * x + y * y + z * z);
}