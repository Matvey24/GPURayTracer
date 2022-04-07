#pragma once
#ifndef CAMERA_H_
#define CAMERA_H_
#include "rendering/ImageBMP.h"
#include "rendering/GPU_API.h"
#include <time.h>
#include "objects/math/Matrix.h"
#include <vector>
class Camera
{
public:
	GPU_API& api;
	ImageBMP im;
	Vector3 pos;
	Matrix rot;
	std::vector<cl_mem> textures;
	size_t push_time = 0, rend_time = 0, poll_time = 0;
	Camera(int width, int height, GPU_API& api);
	int render(void* scene_cur, size_t scene_len);
	void addImage(const ImageBMP* image);
	void deleteImages();
};
struct SceneParam {
	cl_double3 cam_pos;
	unsigned im_width, im_height, im_llen;
	Matrix rot;
};
#endif