#include "Vector2.h"
Vector2::Vector2(const double ang) {
	angle(ang);
}
void Vector2::set(Vector2 oth) {
	x = oth.x;
	y = oth.y;
}
void Vector2::set(double x, double y) {
	this->x = x;
	this->y = y;
}
void Vector2::angle(double angle) {
	x = cos(angle);
	y = sin(angle);
}
double Vector2::len2() const {
	return x * x + y * y;
}
double Vector2::len() const {
	return hypot(x, y);
}
double Vector2::scl(Vector2 oth) const{
	return x * oth.x + y * oth.y;
}
double Vector2::vec(Vector2 oth) const{
	return x * oth.y - y * oth.x;
}
void Vector2::rotateBack(Vector2 ang) {
	double x = this->x * ang.x + this->y * ang.y;
	double y = this->y * ang.x - this->x * ang.y;
	this->x = x;
	this->y = y;
}
void Vector2::rotate(Vector2 ang) {
	double x = this->x * ang.x - this->y * ang.y;
	double y = this->y * ang.x + this->x * ang.y;
	this->x = x;
	this->y = y;
}
void Vector2::norm() {
	double len = this->len();
	x /= len;
	y /= len;
}
const Vector2 operator-(const Vector2& a) {
	return Vector2(-a.x, -a.y);
}
Vector2 operator+(Vector2 a, Vector2 b) {
	return Vector2(a.x + b.x, a.y + b.y);
}
Vector2 operator-(Vector2 a, Vector2 b) {
	return Vector2(a.x - b.x, a.y - b.y);
}
Vector2& operator+=(Vector2& a, Vector2 b) {
	a.x += b.x;
	a.y += b.y;
	return a;
}
Vector2& operator-=(Vector2& a, Vector2 b) {
	a.x -= b.x;
	a.y -= b.y;
	return a;
}
Vector2 operator*(Vector2 a, double b) {
	return Vector2(a.x * b, a.y * b);
}
Vector2& operator*=(Vector2& a, double b) {
	a.x *= b;
	a.y *= b;
	return a;
}
double operator>>(Vector2 a, Vector2 b) {
	return hypot(a.x - b.x, a.y - b.y);
}
