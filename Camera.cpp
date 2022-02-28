#include "Camera.h"
Camera::Camera(int width, int height, GPU_API& api) 
	:api(api), im(width, height) {}
void Camera::render(void* scene_cur, size_t scene_len) {
    size_t t = clock();
    int ret;
    SceneParam param;
    param.im_width = im.width;
    param.im_height = im.height;
    param.im_llen = im.line_len;
    param.cam_pos.x = pos.x;
    param.cam_pos.y = pos.y;
    param.cam_pos.z = pos.z;
    param.rot = rot;
    cl_mem param_mem = api.createBuffer(CL_MEM_READ_ONLY, sizeof(SceneParam), ret);
    api.writeBuffer(param_mem, &param, sizeof(SceneParam));
    api.setKernelArg(0, sizeof(cl_mem), &param_mem);

    cl_mem img_mem = api.createBuffer(CL_MEM_WRITE_ONLY, im.full_len - im.start, ret);
    api.setKernelArg(1, sizeof(cl_mem), &img_mem);

    cl_mem scene_mem = api.createBuffer(CL_MEM_READ_ONLY, scene_len, ret);
    api.writeBuffer(scene_mem, scene_cur, scene_len);
    api.setKernelArg(2, sizeof(cl_mem), &scene_mem);

    size_t t2 = clock();
    push_time = t2 - t;
    t = t2;
    size_t size[] = { im.width, im.height };
    api.execute(2, size);
    t2 = clock();
    rend_time = t2 - t;
    t = t2;
    api.readBuffer(img_mem, im.getImageBuf(), im.full_len - im.start);
    api.deleteBuffer(param_mem);
    api.deleteBuffer(img_mem);
    api.deleteBuffer(scene_mem);
    t2 = clock();
    poll_time = t2 - t;
}