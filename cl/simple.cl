
struct SurfacePoint intersect(double3 pos, double3 dir, __global char* scene){
	long count = *(long*)scene;
	scene += 8;
	struct SPoint nearest;
	nearest.d = INFINITY;
	for(long i = 0; i < count; ++i){
		long size = *(long*)scene;
		scene += 8;
		struct SPoint cur;
		switch(*(long*)scene){
		case OBJECT_SPHERE:
			cur = sphInter(scene, pos, dir);
			break;
		default:
			cur.d = NAN;
			break;
		}
		if(cur.d < nearest.d)
			nearest = cur;
		scene += size;
	}
	if(nearest.d < INFINITY)
		return getPoint(pos, dir, nearest);
	struct SurfacePoint sp;
	sp.intersects = false;
	return sp;
}
double3 getColor(double3 pos, double3 dir, __global char* scene) {
	dir /= d3_len(dir);
	struct SurfacePoint sp = intersect(pos, dir, scene);
	if(!sp.intersects)
		return (double3)(1, 1, 1);
	sp.norm /= d3_len(sp.norm);
	double scl = d3_scl(dir, sp.norm);
	return d_module(scl) * sp.diffuse;
}
__kernel void main(__global struct SceneParam *param_p, __global char* data, __global char* scene) {
	int x = get_global_id(0);
	int y = get_global_id(1);
	struct SceneParam param = *param_p;
	struct ImageBMP img = Image_build(param, data);
	double FOV = 60;
	double3 cam_pos = param.cam_pos;
	double3 ray_dir = (double3)(
		x - img.width / 2.,
		y - img.height / 2.,
		img.width / tan(FOV / 360 * M_PI) / 2);
	ray_dir = Matrix_transform(param.rot, ray_dir);
	double3 rgb = getColor(cam_pos, ray_dir, scene);
	setPixel(img, x, y, rgb);
}
