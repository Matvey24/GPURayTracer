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
struct ImageBMP ImageFromBMP(__global char* buf){
	struct ImageBMP img;
	img.buf = &buf[54];
	__global unsigned char* buff = (__global unsigned char*)buf;
	img.width = (buff[18]) + (buff[19] << 8) + (buff[20] << 16) + (buff[21] << 24);
	img.height = (buff[22]) + (buff[23] << 8) + (buff[24] << 16) + (buff[25] << 24);
	img.llen = (img.width * 3 + ((4 - (img.width * 3) & 3) & 3));
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
double3 getThePixel(struct ImageBMP img, int x, int y){
	__global unsigned char* c = (__global unsigned char*)&img.buf[y * img.llen + 3 * x];
	return (double3)(c[2], c[1], c[0]);
}
double3 getPixel(struct ImageBMP img, double x, double y){
	x *= 0.4;
	y *= 0.5;
	x += 0.55;
	y += 0.5;
	x *= img.width;
	y *= img.height;
	int xs = (int)x;
	int ys = (int)y;
	if(xs < 0 || ys < 0 || xs >= img.width || ys >= img.height)
		return (double3)(0, 0, 0);
	double dx = x - xs;
	double dy = y - ys;
	if(dx == 0 || dy == 0)
		return getThePixel(img, xs, ys) / 255;
	if(xs == img.width - 1 || ys == img.height - 1)
		return (double3)(0, 0, 0);
 	return ((getThePixel(img, xs, ys) * (1 - dx) 
 		+ getThePixel(img, xs + 1, ys) * dx) * (1 - dy)
 		 + (getThePixel(img, xs, ys + 1) * (1 - dx)
 		  + getThePixel(img, xs + 1, ys + 1) * dx) * dy) / 255;
}
