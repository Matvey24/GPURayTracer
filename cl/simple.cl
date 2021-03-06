double3 raytrace(double3 pos, double3 dir,
 struct RandomState* rand,
  struct Scene scene, int reref){
	double3 color = (double3)(1, 1, 1);
	for(int i = 0; i < reref; ++i){
		struct SurfacePoint surf = intersect(pos, dir, scene);
		if(!surf.reflects)
			return d3_sclv(color, surf.color);
		double scl = d3_scl(dir, surf.norm);
		if(scl > 0){
			scl = -scl;
			surf.norm = -surf.norm;
		}
		double refl = calcReflect(scl, surf.reflect);
		if(random(rand) > refl){//diffuse
			double cosphi = random(rand);
            double sinphi = sqrt(1 - cosphi * cosphi);
            double psi = random(rand) * 2 * M_PI;
            double cosp;
            double sinp = sincos(random(rand) * 2 * M_PI, &cosp);
            dir = (double3)(cosphi, sinphi * sinp, sinphi * cosp);
            if(d3_scl(dir, surf.norm) < 0)
            	dir = -dir;
            color = d3_sclv(color, surf.color);
		}else{//reflect
			dir = dir - 2 * scl * surf.norm;
		}
		pos = surf.pos + DIFF * dir;
	}
	return (double3)(0, 0, 0);
}
double3 updateDiffuse(double3 pos, double3 norm,
	struct RandomState* rand,
	struct Scene scene, int reref, int disc){
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
            double cosp;
            double sinp = sincos(psi, &cosp);
            double3 dir = (double3)(cosphi, sinphi * sinp, sinphi * cosp);
            if(d3_scl(dir, norm) < 0)
            	dir = -dir;
            double3 pos2 = pos + DIFF * dir;
            color += scale * raytrace(pos2, dir, rand, scene, reref);
		}
	}
	return color;
}
double3 getColor(double3 pos, double3 dir,
	struct RandomState* rand,
	struct Scene scene) {
	
	double3 color = (double3)(0, 0, 0);
	double refl_scale = 1;
	
	double refl_min = 1. / 1000;
	int reref = 30;

	for(; reref >= 0; reref--){
		struct SurfacePoint surf = intersect(pos, dir, scene);
		if(!surf.reflects)
			return color + refl_scale * surf.color;

		double scl = d3_scl(dir, surf.norm);
		if(scl > 0){
			scl = -scl;
			surf.norm = -surf.norm;
		}
		double refl = calcReflect(scl, surf.reflect);
		int discDiffuse = (1 - refl) * refl_scale / refl_min;
		double3 diffuse = updateDiffuse(
			surf.pos, surf.norm, rand, scene, reref, discDiffuse);
		color += (1 - refl) * refl_scale * d3_sclv(surf.color, diffuse);
		
		refl_scale *= refl;
		if(refl_scale < refl_min)
			return color;

		dir = dir - 2 * scl * surf.norm;
		pos = surf.pos + DIFF * dir;
	}
	return color;
}
double3 getColorNormal(double3 pos, double3 dir,
	struct RandomState* rand,
	struct Scene scene){
	struct SurfacePoint sp = intersect(pos, dir, scene);
	if(!sp.reflects)
		return (double3)(0, 0, 0);
	return (double3)(d_abs(sp.norm.x), d_abs(sp.norm.y), d_abs(sp.norm.z));
}
double3 getSimpleColor(double3 pos, double3 dir, struct RandomState* rand, struct Scene scene){
	double3 color = (double3)(0, 0, 0);
	double refl_scale = 1;
	
	int reref = 30;
	double refl_min = 0.001;
	for(; reref >= 0; reref--){
		struct SurfacePoint surf = intersect(pos, dir, scene);
		if(!surf.reflects)
			return color + refl_scale * surf.color;

		double scl = d3_scl(dir, surf.norm);
		if(scl > 0){
			scl = -scl;
			surf.norm = -surf.norm;
		}
		double refl = calcReflect(scl, surf.reflect);
		double3 dir2 = (double3)(-2, 5, -2);
		dir2 = normalize(dir2);
		struct SurfacePoint sp = intersect(surf.pos + DIFF * dir2, dir2, scene);
		
		if(!sp.reflects){
			double power = 0.7 * d3_scl(surf.norm, dir2);
			if(power < 0)
				power = -power;
			color += power * (1 - refl) * refl_scale * surf.color;
		}

		color += 0.2 * (1 - refl) * refl_scale * surf.color;
		
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
		for(; p < count; ++p)
			scene_ref[p] = scene_tmp[p];	
}
__kernel void worker_main(
	__constant struct SceneParam *param_p,
	__constant long* scene_val,
	__local long* scene_buf,
	__global char* data,
	__global char* texture) {
	int x = get_global_id(0);
	int y = get_global_id(1);
	

	if(get_local_id(0) == 0)
		mem_cpy(scene_val, scene_buf);
	
	barrier(CLK_LOCAL_MEM_FENCE);
	struct Scene scene;
	scene.sc = &scene_buf[1];
	scene.texture = ImageFromBMP(texture);

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
	dir = normalize(dir);
	double3 rgb = getSimpleColor(param.cam_pos, dir, &rand, scene);
	setPixel(img, x, y, rgb);
}
