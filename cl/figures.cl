#define OBJECT_SPHERE 1
#define OBJECT_RECT 2
#define OBJECT_RECT_NOROT 3
#define OBJECT_FRACTAL 4

#define MATERIAL_FILL 0
#define MATERIAL_LIGHT 1
#define MATERIAL_TEXTURE 2
#define DOT_FULL 14

struct SPoint{
	__local long* dot;
	double d;
	double info;
};
struct SurfacePoint{
	char reflects;
	double3 color;
	double3 pos;
	double3 norm;
	double reflect;
};
struct Scene{
	__local long* sc;
	struct ImageBMP texture;
};
double3 getVec(__local long* dat){
	return (double3)(
		*(__local double*)&dat[0], 
		*(__local double*)&dat[1], 
		*(__local double*)&dat[2]);
	//return (*(__local double3*)dat);
}
double3 DotGetPos(__local long* dat){
	return getVec(&dat[1]);
}
struct Matrix DotGetRot(__local long* dat){
	struct Matrix m;
	m.a1 = *(__local double*)&dat[4];
	m.a2 = *(__local double*)&dat[5];
	m.a3 = *(__local double*)&dat[6];
	m.b1 = *(__local double*)&dat[7];
	m.b2 = *(__local double*)&dat[8];
	m.b3 = *(__local double*)&dat[9];
	m.c1 = *(__local double*)&dat[10];
	m.c2 = *(__local double*)&dat[11];
	m.c3 = *(__local double*)&dat[12];
	return m;
}
struct SPoint sphInter(__local long* sphere, double3 pos, double3 dir){
	struct SPoint p;
	pos = DotGetPos(sphere) - pos;
	p.d = nasphInter(*(__local double*)&sphere[DOT_FULL], pos, dir);
	p.dot = sphere;
	return p;
}
struct SPoint rectInter(__local long* rect, double3 pos, double3 dir){
	struct Matrix m = DotGetRot(rect);
	pos = DotGetPos(rect) - pos;
	pos = Matrix_transform(m, pos);
	dir = Matrix_transform(m, dir);
	struct SPoint p;
	p.d = naRectInter(getVec(&rect[DOT_FULL]), pos, dir);
	p.dot = rect;
	return p;
}
struct SPoint rectNorotInter(__local long* rect, double3 pos, double3 dir){
	pos = DotGetPos(rect) - pos;
	struct SPoint p;
	p.d = naRectInter(getVec(&rect[DOT_FULL]), pos, dir);
	p.dot = rect;
	return p;
}
struct SPoint fractInter(__local long* mandelbulb, double3 pos, double3 dir){
	pos = DotGetPos(mandelbulb) - pos;
	//double size = *(__local double*)&mandelbulb[DOT_FULL];
	double dist = nasphInter(4, pos, dir);
	if(dist != dist){
		struct SPoint p;
		p.d = NAN;
		return p;
	}
	pos = -pos;
	struct Matrix m = DotGetRot(mandelbulb);
	pos = Matrix_transform(m, pos);
	dir = Matrix_transform(m, dir);

	//dist /= size;
	//pos /= size;

	struct SPoint p;
	double2 vec = naFractalInter(dist, pos, dir);
	p.d = vec.x;//*size
	p.dot = mandelbulb;
	p.info = vec.y;
	return p;
}

struct SurfacePoint intersect(double3 pos, double3 dir, struct Scene scene){
	long p = 0;
	long count = scene.sc[p];
	p++;
	struct SPoint near;
	struct SPoint cur;
	near.d = INFINITY;

	for(long i = 0; i < count; ++i){
		switch(scene.sc[p]){
		case OBJECT_SPHERE:
			cur = sphInter(&scene.sc[p], pos, dir);
			p += DOT_FULL + 1;
			break;
		case OBJECT_RECT:
			cur = rectInter(&scene.sc[p], pos, dir);
			p += DOT_FULL + 3;
			break;
		case OBJECT_RECT_NOROT:
			cur = rectNorotInter(&scene.sc[p], pos, dir);
			p += DOT_FULL + 3;
			break;
		case OBJECT_FRACTAL:
			cur = fractInter(&scene.sc[p], pos, dir);
			p += DOT_FULL + 1;
			break;
		default:
			cur.d = NAN;
			break;
		}
		if(cur.d < near.d)
			near = cur;
	}

	struct SurfacePoint surf;
	if(near.d == INFINITY){
		surf.reflects = false;
		surf.color = (double3)(1, 1, 1);
		return surf;
	}
	
	long mater_d = near.dot[13];
	struct Matrix m;

	switch(scene.sc[mater_d]){
	case MATERIAL_FILL:
		surf.color = getVec(&scene.sc[mater_d + 1]);
		surf.reflects = true;
		surf.reflect = *(__local double*)&scene.sc[mater_d + 4];
		break;
	case MATERIAL_LIGHT:
		surf.color = getVec(&scene.sc[mater_d + 1]);
		surf.reflects = false;
		return surf;
	case MATERIAL_TEXTURE:{
		double3 cur_pos = pos + (near.d * dir);
		cur_pos = cur_pos - DotGetPos(near.dot);
		m = DotGetRot(near.dot);
		cur_pos = Matrix_transform(m, cur_pos);
		surf.color = getPixel(scene.texture, (cur_pos.x - cur_pos.z) / 2, cur_pos.y);
		surf.reflects = true;
		surf.reflect = *(__local double*)&scene.sc[mater_d + 4];
		break;
	}
	default:
		surf.reflects = false;
		surf.color = (double3)(1, 0, 1);
		return surf;
	}

	double3 tmp;
	surf.pos = pos + (near.d * dir);
	surf.norm = surf.pos - DotGetPos(near.dot);
	double diff = 0.001;

	switch(*near.dot){
	case OBJECT_SPHERE:
		surf.norm = normalize(surf.norm);
		break;
	case OBJECT_RECT:
		m = DotGetRot(near.dot);
		surf.norm = Matrix_transform(m, surf.norm);
		tmp = getVec(&near.dot[DOT_FULL]);
		{
			double x = surf.norm.x / tmp.x, y = surf.norm.y / tmp.y, z = surf.norm.z / tmp.z;
			x *= x;
			y *= y;
			z *= z;
			char xz = x > z, xy = x > y, yz = y > z;
			surf.norm = (double3)(
				xz && xy,
				!xy && yz,
				!xz && !yz);
		}
		surf.norm = Matrix_transformBack(m, surf.norm);
		break;
	case OBJECT_RECT_NOROT:
		tmp = getVec(&near.dot[DOT_FULL]);
		{
			double x = surf.norm.x / tmp.x, y = surf.norm.y / tmp.y, z = surf.norm.z / tmp.z;
			x *= x;
			y *= y;
			z *= z;
			char xz = x > z, xy = x > y, yz = y > z;
			surf.norm = (double3)(
				xz && xy,
				!xy && yz,
				!xz && !yz);
		}
		break;
	case OBJECT_FRACTAL:
		m = DotGetRot(near.dot);
		surf.norm = Matrix_transform(m, surf.norm);
		double size = *(__local double*)&near.dot[DOT_FULL];
		surf.norm /= size;
		{
			double xp = naMandelBulbDEHalf(surf.norm + (double3)(diff, 0, 0));
			double xn = naMandelBulbDEHalf(surf.norm - (double3)(diff, 0, 0));
			double yp = naMandelBulbDEHalf(surf.norm + (double3)(0, diff, 0));
			double yn = naMandelBulbDEHalf(surf.norm - (double3)(0, diff, 0));
			double zp = naMandelBulbDEHalf(surf.norm + (double3)(0, 0, diff));
			double zn = naMandelBulbDEHalf(surf.norm - (double3)(0, 0, diff));
			surf.norm = (double3)(xp - xn, yp - yn, zp - zn) / (2 * diff);
		}
		surf.norm = Matrix_transformBack(m, surf.norm);
		surf.norm = normalize(surf.norm);
		break;
	default:
		surf.reflects = false;
		surf.color = (double3)(1, 0, 1);
		break;
	}
	return surf;
}