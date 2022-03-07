struct ImageBMP{
	__global char* buf;
	unsigned width, height;
	unsigned llen;
};
struct SceneParam{
	double3 cam_pos;
	unsigned im_width, im_height, im_llen;
	struct Matrix rot;
};

struct ImageBMP Image_build(struct SceneParam param, __global char* buf){
	struct ImageBMP img;
	img.width = param.im_width;
	img.height = param.im_height;
	img.llen = param.im_llen;
	img.buf = buf;
	return img;
}
void setPixel(struct ImageBMP img, int x, int y, double3 col) {
	col *= 255;
	if (col.x > 255)
		col.x = 255;
	if(col.x < 0)
		col.x = 0;
	if (col.y > 255)
		col.y = 255;
	if(col.y < 0)
		col.y = 0;
	if (col.z > 255)
		col.z = 255;
	if(col.z < 0)
		col.z = 0;
	long index = y * img.llen + 3 * x;
	img.buf[index] = (unsigned char)col.z;
	img.buf[index + 1] = (unsigned char)col.y;
	img.buf[index + 2] = (unsigned char)col.x;
}
