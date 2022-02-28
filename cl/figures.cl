#define OBJECT_SPHERE 1
struct Material{
	double3 diffuse;
	//double reflect;
};
struct Dot{
	long type;
	double3 pos;
	double3 diffuse;
	struct Matrix rot;
};
struct Sphere{
	struct Dot dot;
	double rad2;
};

struct SPoint{
	__global char* dot;
	double d;
};
struct SurfacePoint{
	char intersects;
	double3 pos;
	double3 norm;
	double3 diffuse;
};
double3 getVec(__global char* dat){
	return (double3)(*(__global double*)(dat), *(__global double*)(dat + 8), *(__global double*)(dat + 16));
}
struct SPoint sphInter(__global char* sphere, double3 pos, double3 dir){
	struct SPoint p;
	p.d = nasphInter(getVec(sphere + 8), *(__global double*)(sphere + 16 * 8), pos, dir);
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
		sp.norm = sp.pos - getVec(p.dot + 8);
		break;
	default:
		sp.norm = sp.pos - getVec(p.dot + 8);
		break;
	}
	sp.diffuse = getVec(p.dot + 32);
	return sp;
}