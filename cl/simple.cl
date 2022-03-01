struct SurfacePoint intersect(double3 pos, double3 dir, __global char* scene){
	long count = getLong(scene);
	scene += 8;
	struct SPoint nearest;
	nearest.d = INFINITY;
	for(long i = 0; i < count; ++i){
		long size = getLong(scene);
		scene += 8;
		struct SPoint cur;
		switch(getLong(scene)){
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

double3 getColor(double3 pos, double3 dir, struct RandomState* rand, __global char* scene) {
	dir /= d3_len(dir);
	double3 color = (double3)(0, 0, 0);
	double3 inter = (double3)(1, 1, 1);
	double scale = 1;
	for(int i = 0; i < 1000; ++i){
		struct SurfacePoint sp = intersect(pos, dir, scene);
		if(!sp.intersects){
			color += inter;
			break;
		}else{
			sp.norm /= d3_len(sp.norm);
			double refl = calcReflect(dir, sp.norm, sp.reflect);
			if((1 - random(rand)) > refl){//diffuse
				scale *= 1 - refl;
				double cosphi = random(rand);
                double sinphi = sqrt(1 - cosphi * cosphi);
                double psi = random(rand) * 2 * M_PI;
                dir = (double3)(cosphi, sinphi * sin(psi), sinphi * cos(psi));
                double3 dir2 = d3_vec(sp.norm, (double3)(1, 0, 0));
                struct Matrix m = Matrix_setRotE(dir2, (double2)(sp.norm.x, -sqrt(1 - sp.norm.x * sp.norm.x)));
                Matrix_transform(m, dir);
                inter = (double3)(inter.x * sp.diffuse.x, inter.y * sp.diffuse.y, inter.z * sp.diffuse.z);
			}else{//reflect
				dir = reflect(dir, sp.norm);
				inter *= refl;
			}
			if(d3_len2(inter) < 0.001){
				break;
			}
			pos = sp.pos;
			pos += 0.00001 * dir;
		}
	}
	return color;
}

__kernel void worker_main(__global struct SceneParam *param_p, __global char* data, __global char* scene) {
	int x = get_global_id(0);
	int y = get_global_id(1);
	struct RandomState rand;
	struct SceneParam param = *param_p;
	init_taus(&rand, x * param.im_llen + y + 1237521);
	struct ImageBMP img = Image_build(param, data);
	double FOV = 60;
	double table_offset = img.width / tan(FOV / 360 * M_PI) / 2;

	int disc = 1;
	double3 rgb = (double3)(0, 0, 0);
	for(int i = 0; i < disc; ++i){
		for(int j = 0; j < disc; ++j){
			double3 dir = (double3)(
				(x + i / (double)disc) - img.width / 2.,
				(y + j / (double)disc) - img.height / 2.,
				table_offset
			);
			dir = Matrix_transform(param.rot, dir);
			rgb += getColor(param.cam_pos, dir, &rand, scene);
		}
	}
	rgb /= disc * disc;
	setPixel(img, x, y, rgb);
}
