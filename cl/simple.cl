struct SurfacePoint intersect(double3 pos, double3 dir, __local long* scene){
	long p = 0;
	long count = scene[p];
	p++;
	struct SPoint nearest;
	struct SPoint cur;
	nearest.d = INFINITY;

	for(long i = 0; i < count; ++i){
		long size = scene[p++];
		switch(scene[p]){
		case OBJECT_SPHERE:
			cur = sphInter(&scene[p], pos, dir);
			break;
		case OBJECT_RECT:
			cur = rectInter(&scene[p], pos, dir);
			break;	
		default:
			cur.d = NAN;
			break;
		}
		if(cur.d < nearest.d)
			nearest = cur;
		p += size;
	}
	if(nearest.d < INFINITY)
		return getPoint(pos, dir, nearest);
	struct SurfacePoint sp;
	sp.intersects = false;
	return sp;
}
#define DIFF 0.0001
double3 raytrace(double3 pos, double3 dir,
 struct RandomState* rand,
  __local long* scene, int reref){
	double3 color = (double3)(1, 1, 1);
	for(int i = 0; i < reref; ++i){
		struct SurfacePoint surf = intersect(pos, dir, scene);
		if(!surf.intersects)
			return color;
		double scl = d3_scl(dir, surf.norm);
		double refl = calcReflect(scl, surf.reflect);
		if(random(rand) > refl){//diffuse
			double cosphi = random(rand);
            double sinphi = sqrt(1 - cosphi * cosphi);
            double psi = random(rand) * 2 * M_PI;
            dir = (double3)(cosphi, sinphi * sin(psi), sinphi * cos(psi));
            double3 dir2 = d3_vec(surf.norm, (double3)(1, 0, 0));
            if(d3_len2(dir2) == 0)
            	dir2 = (double3)(0, 1, 0);
            else
            	dir2 /= d3_len(dir2);
            struct Matrix m = Matrix_setRotE(dir2, (double2)(surf.norm.x, sqrt(1 - surf.norm.x * surf.norm.x)));
            dir = Matrix_transformBack(m, dir);
            color = d3_sclv(color, surf.diffuse);
		}else{//reflect
			dir = dir - 2 * scl * surf.norm;
		}
		pos = surf.pos + DIFF * dir;
	}
	return (double3)(0, 0, 0);
}
double3 updateDiffuse(double3 pos, double3 norm,
	struct RandomState* rand,
	__local long* scene, int reref, int disc){
	
	double3 dir2 = d3_vec(norm, (double3)(1, 0, 0));
    if(d3_len2(dir2) == 0)
       	dir2 = (double3)(0, 1, 0);
    else
    	dir2 /= d3_len(dir2);
    
    struct Matrix m = Matrix_setRotE(dir2, (double2)(norm.x, sqrt(1 - norm.x * norm.x)));
    if(disc == 0)
    	disc = 1;
	int width = sqrt((float)disc);
	int height = disc / width;
	double scale = 1. / (width * height);
	double3 color = (double3)(0, 0, 0);

	for(int x = 0; x < width; ++x){
		for(int y = 0; y < height; ++y){
			double cosphi = (random(rand) + y) / height;
            double sinphi = sqrt(1 - cosphi * cosphi);
            double psi = (random(rand) + x) * 2 * M_PI / width;
            double3 dir = (double3)(cosphi, sinphi * sin(psi), sinphi * cos(psi));
            dir = Matrix_transformBack(m, dir);
            double3 pos2 = pos + DIFF * dir;
            color += scale * raytrace(pos2, dir, rand, scene, reref);
		}
	}
	return color;
}
double3 getColor(double3 pos, double3 dir,
	struct RandomState* rand,
	__local long* scene) {
	
	double3 color = (double3)(0, 0, 0);
	double refl_scale = 1;
	
	int disc = 1000;
	double refl_min = 1. / disc;
	int reref = 200;

	for(; reref >= 0; reref--){
		struct SurfacePoint surf = intersect(pos, dir, scene);
		if(!surf.intersects)
			return color + (double3)(refl_scale, refl_scale, refl_scale);

		double scl = d3_scl(dir, surf.norm);
		double refl = calcReflect(scl, surf.reflect);
		int discDiffuse = (1 - refl) * refl_scale / refl_min;
		double3 diffuse = updateDiffuse(
			surf.pos, surf.norm, rand, scene, reref, discDiffuse);
		color += (1 - refl) * refl_scale * d3_sclv(surf.diffuse, diffuse);
		
		refl_scale *= refl;
		if(refl_scale < refl_min)
			return color;

		dir = dir - 2 * scl * surf.norm;
		pos = surf.pos + DIFF * dir;
	}
	return color;
}
void mem_cpy(__constant long* scene_tmp, __local long* scene_ref){
		long p = 0;
		long count = scene_tmp[p];
		scene_ref[p] = count;
		p++;
		for(long i = 0; i < count; ++i){
			long size = scene_tmp[p];
			scene_ref[p] = size;
			p++;
			for(long j = 0; j < size; ++j){
				scene_ref[p] = scene_tmp[p];
				p++;
			}
		}
		
}
__kernel void worker_main(
	__constant struct SceneParam *param_p,
	__global char* data,
	__constant long* scene_val,
	__local long* scene_buf) {
	int x = get_global_id(0);
	int y = get_global_id(1);

	if(get_local_id(0) == 0)
		mem_cpy(scene_val, scene_buf);
	
	barrier(CLK_LOCAL_MEM_FENCE);

	struct SceneParam param = *param_p;
	struct ImageBMP img = Image_build(param, data);
	if(img.width <= x || img.height <= y)
		return;

	struct RandomState rand;
	init_taus(&rand, x * param.im_llen + y + 1237521);
	
	double FOV = 60;
	double table_offset = img.width / tan(FOV / 360 * M_PI) / 2;
	double3 dir = (double3)(x - img.width / 2., y - img.height / 2., table_offset);
	dir = Matrix_transform(param.rot, dir);
	dir /= d3_len(dir);

	double3 rgb = getColor(param.cam_pos, dir, &rand, scene_buf);
	setPixel(img, x, y, rgb);
}
