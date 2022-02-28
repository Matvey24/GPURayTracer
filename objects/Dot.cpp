#include "Dot.h"
Dot::Dot(unsigned long type):type(type){}
size_t Dot::sizeOf() const {
	return sizeof(double) * (1 + 3 + 3 + 9);
}
void Dot::write(void* to) {
	double* dp = (double*)to;
	int i = -1;
	*(__int64*)&dp[++i] = type;
	dp[++i] = pos.x;
	dp[++i] = pos.y;
	dp[++i] = pos.z;
	dp[++i] = color.x;
	dp[++i] = color.y;
	dp[++i] = color.z;
	dp[++i] = rot.a1;
	dp[++i] = rot.a2;
	dp[++i] = rot.a3;
	dp[++i] = rot.b1;
	dp[++i] = rot.b2;
	dp[++i] = rot.b3;
	dp[++i] = rot.c1;
	dp[++i] = rot.c2;
	dp[++i] = rot.c3;
}