#define OBJECT_SPHERE 1
struct Material{
	double3 diffuse;
	//double reflect;
};
#define DOT_FULL (17*8)
//struct Dot{
//	long type;
//	double3 pos;
//	double3 diffuse;
//	double reflective;
//	struct Matrix rot;
//};

struct SPoint{
	__global char* dot;
	double d;
};
struct SurfacePoint{
	char intersects;
	double3 pos;
	double3 norm;
	double3 diffuse;
	double reflect;
};
double3 getVec(__global char* dat){
	return (double4)(*(__global double4*)dat).xyz;
}
long getLong(__global char* dat){
	return *(__global long*)dat;
}
double3 DotGetPos(__global char* dat){
	return getVec(dat + 8);
}
double3 DotGetDiffuse(__global char* dat){
	return getVec(dat + 32);
}
double DotGetReflect(__global char* dat){
	return *(__global double*)(dat + 56);
}
struct Matrix DotGetRot(__global char* dat){
	struct Matrix m = *(__global struct Matrix*)(dat + 64);
	return m;//TODO
}

struct SPoint sphInter(__global char* sphere, double3 pos, double3 dir){
	struct SPoint p;
	p.d = nasphInter(DotGetPos(sphere), *(__global double*)(sphere + DOT_FULL), pos, dir);
	p.dot = sphere;
	return p;
}

struct SurfacePoint getPoint(double3 pos, double3 dir, struct SPoint p){
	long type = *(__global long*)p.dot;
	struct SurfacePoint sp;
	sp.intersects = true;
	sp.pos = pos + (p.d * dir);
	switch(type){
	case OBJECT_SPHERE:
		sp.norm = sp.pos - DotGetPos(p.dot);
		break;
	default:
		sp.norm = sp.pos - DotGetPos(p.dot);
		break;
	}
	sp.diffuse = DotGetDiffuse(p.dot);
	sp.reflect = DotGetReflect(p.dot);
	return sp;
}