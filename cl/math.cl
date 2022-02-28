struct Matrix{
	double a1, a2, a3, b1, b2, b3, c1, c2, c3;
};
double d_module(double a){
    if(a < 0)
        return -a;
    return a;
}
double2 d2_fromAng(double ang){
	return (double2)(cos(ang), sin(ang));
}
double d3_scl(double3 a, double3 b){
    return a.x * b.x + a.y * b.y + a.z * b.z;
}
double d3_len2(double3 vec){
    return vec.x * vec.x + vec.y * vec.y + vec.z * vec.z;
}
double d3_len(double3 vec){
	return sqrt(d3_len2(vec));
}
double3 Matrix_transform(struct Matrix mat, double3 vec){
	double x, y, z;
    x = mat.a1 * vec.x + mat.a2 * vec.y + mat.a3 * vec.z;
    y = mat.b1 * vec.x + mat.b2 * vec.y + mat.b3 * vec.z;
    z = mat.c1 * vec.x + mat.c2 * vec.y + mat.c3 * vec.z;
    return (double3)(x, y, z);
}
struct Matrix Matrix_mult(struct Matrix a, struct Matrix b){
	struct Matrix c;
    c.a1 = a.a1 * b.a1 + a.a2 * b.b1 + a.a3 * b.c1;
    c.a2 = a.a1 * b.a2 + a.a2 * b.b2 + a.a3 * b.c2;
    c.a3 = a.a1 * b.a3 + a.a2 * b.b3 + a.a3 * b.c3;
    c.b1 = a.b1 * b.a1 + a.b2 * b.b1 + a.b3 * b.c1;
    c.b2 = a.b1 * b.a2 + a.b2 * b.b2 + a.b3 * b.c2;
    c.b3 = a.b1 * b.a3 + a.b2 * b.b3 + a.b3 * b.c3;
    c.c1 = a.c1 * b.a1 + a.c2 * b.b1 + a.c3 * b.c1;
    c.c2 = a.c1 * b.a2 + a.c2 * b.b2 + a.c3 * b.c2;
    c.c3 = a.c1 * b.a3 + a.c2 * b.b3 + a.c3 * b.c3;
    return c;
}
struct Matrix Matrix_setRotE(double3 at, double2 ang){
	struct Matrix c;
	c.a1 = (1 - ang.x) * at.x * at.x + ang.x;
    c.a2 = (1 - ang.x) * at.x * at.y - ang.y * at.z;
    c.a3 = (1 - ang.x) * at.x * at.z + ang.y * at.y;
    c.b1 = (1 - ang.x) * at.y * at.x + ang.y * at.z;
    c.b2 = (1 - ang.x) * at.y * at.y + ang.x;
    c.b3 = (1 - ang.x) * at.y * at.z - ang.y * at.x;
    c.c1 = (1 - ang.x) * at.z * at.x - ang.y * at.y;
    c.c2 = (1 - ang.x) * at.z * at.y + ang.y * at.x;
    c.c3 = (1 - ang.x) * at.z * at.z + ang.x;
    return c;
}

struct Matrix Matrix_setRotOf(double3 ang){
	double l = d3_len(ang);
    double l1 = 1 / l;
    ang.x *= l1;
    ang.y *= l1;
    ang.z *= l1;
    double2 an = d2_fromAng(l);
    return Matrix_setRotE(ang, an);
}
