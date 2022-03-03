#define OBJECT_SPHERE 1
#define OBJECT_RECT 2
struct Material{
	double3 diffuse;
	//double reflect;
};
#define DOT_FULL 17

struct SPoint{
	__local long* dot;
	double d;
};
struct SurfacePoint{
	char intersects;
	double3 pos;
	double3 norm;
	double3 diffuse;
	double reflect;
};
double3 getVec(__local long* dat){
	return (double3)(
		*(__local double*)&dat[0], 
		*(__local double*)&dat[1], 
		*(__local double*)&dat[2]);
}
double3 DotGetPos(__local long* dat){
	return getVec(&dat[1]);
}
double3 DotGetDiffuse(__local long* dat){
	return getVec(&dat[4]);
}
double DotGetReflect(__local long* dat){
	return *(__local double*)&dat[7];
}
struct Matrix DotGetRot(__local long* dat){
	struct Matrix m;
	m.a1 = *(__local double*)&dat[8];
	m.a2 = *(__local double*)&dat[9];
	m.a3 = *(__local double*)&dat[10];
	m.b1 = *(__local double*)&dat[11];
	m.b2 = *(__local double*)&dat[12];
	m.b3 = *(__local double*)&dat[13];
	m.c1 = *(__local double*)&dat[14];
	m.c2 = *(__local double*)&dat[15];
	m.c3 = *(__local double*)&dat[16];
	return m;
}

struct SPoint sphInter(__local long* sphere, double3 pos, double3 dir){
	struct SPoint p;
	p.d = nasphInter(*(__local double*)&sphere[DOT_FULL], DotGetPos(sphere) - pos, dir);
	p.dot = sphere;
	return p;
}
struct SPoint rectInter(__local long* rect, double3 pos, double3 dir){
	struct Matrix m = DotGetRot(rect);
	pos = Matrix_transform(m, pos);
	dir = Matrix_transform(m, dir);
	struct SPoint p;
	p.d = naRectInter(getVec(&rect[DOT_FULL]), DotGetPos(rect) - pos, dir);
	p.dot = rect;
	return p;
}
struct SurfacePoint getPoint(double3 pos, double3 dir, struct SPoint p){
	struct Matrix m;
	struct SurfacePoint sp;
	sp.intersects = true;
	sp.pos = pos + (p.d * dir);
	sp.norm = sp.pos - DotGetPos(p.dot);
	switch(*p.dot){
	case OBJECT_SPHERE:
		sp.norm /= d3_len(sp.norm);
		break;
	case OBJECT_RECT:
		m = DotGetRot(p.dot);
		sp.norm = Matrix_transform(m, sp.norm);
		double3 bd = getVec(&p.dot[DOT_FULL]);
		double x = sp.norm.x / bd.x, y = sp.norm.y / bd.y, z = sp.norm.z / bd.z;
		x *= x;
		y *= y;
		z *= z;
		char xz = x > z, xy = x > y, yz = y > z;
		sp.norm = (double3)(
			xz && xy,
			!xy && yz,
			!xz && !yz);
		break;
	default:
		sp.norm /= d3_len(sp.norm);
		break;
	}
	sp.diffuse = DotGetDiffuse(p.dot);
	sp.reflect = DotGetReflect(p.dot);
	return sp;
}