#pragma once
#ifndef CAMERA_H_
#define CAMERA_H_
#include "rendering/ImageBMP.h"
#include "rendering/GPU_API.h"
#include <time.h>
#include "objects/math/Matrix.h"
class Camera
{
private:
	GPU_API& api;
public:
	ImageBMP im;
	Vector3 pos;
	Matrix rot;
	size_t push_time = 0, rend_time = 0, poll_time = 0;
	Camera(int width, int height, GPU_API& api);
	int render(void* scene_cur, size_t scene_len);
	
};
struct SceneParam {
	cl_double3 cam_pos;
	unsigned im_width, im_height, im_llen;
	Matrix rot;
};
#endif