#include "ImageBMP.h"
ImageBMP::ImageBMP(size_t width, size_t height) :width(width), height(height) {
	full_len = (unsigned)(14 + 40 + (3 * width + (4 - (width * 3) % 4) % 4) * height);
	createBuf();
	genParams();
	size_t idx = 0;
	unsigned len = full_len - 6;
	char a[] = "BM";
	bwrite(buf, a, 1, 2, idx);
	bwrite(buf, &len, 4, 1, idx);
	char b[] = { 0, 0, 0, 0 };
	bwrite(buf, b, 1, 4, idx);
	unsigned offset = 14 + 40;//
	bwrite(buf, &offset, 4, 1, idx);

	unsigned head = 40;
	bwrite(buf, &head, 4, 1, idx);
	bwrite(buf, &width, 4, 1, idx);
	bwrite(buf, &height, 4, 1, idx);
	unsigned short planes = 1;
	bwrite(buf, &planes, 2, 1, idx);
	unsigned short bit_count = 24;
	bwrite(buf, &bit_count, 2, 1, idx);
	unsigned compression = 0;
	bwrite(buf, &compression, 4, 1, idx);
	unsigned size = 0;
	bwrite(buf, &size, 4, 1, idx);
	unsigned scale = 3780;
	bwrite(buf, &scale, 4, 1, idx);
	bwrite(buf, &scale, 4, 1, idx);
	bwrite(buf, &compression, 4, 1, idx);
	bwrite(buf, &compression, 4, 1, idx);
}
void ImageBMP::genParams() {
	line_len = (unsigned)(width * 3 + (4 - (width * 3) % 4) % 4);
}
ImageBMP::~ImageBMP() {
	free(buf);
}
void ImageBMP::createBuf() {
	buf = (char*)malloc(full_len);
}
int ImageBMP::readBMP(FILE* file) {
	char a[2];
	fread(a, 1, 2, file);
	if (a[0] != 'B' || a[1] != 'M') {
		printf("Not BMP file reading\n");
		return 1;
	}
	unsigned len;
	fread(&len, 4, 1, file);
	full_len = len + 6;
	createBuf();
	size_t idx = 0;
	bwrite(buf, a, 1, 2, idx);
	bwrite(buf, &len, 4, 1, idx);
	fread(&buf[6], 1, len, file);
	width = *(unsigned*)&buf[18];
	height = *(unsigned*)&buf[22];
	genParams();
}
ImageBMP::ImageBMP(FILE* file) {
	readBMP(file);
}
ImageBMP::ImageBMP(const char* filename) {
	FILE* f;
	fopen_s(&f, filename, "rb");
	if (f == NULL) {
		printf("BMP file not found\n");
		exit(1);
		return;
	}
	readBMP(f);
	fclose(f);
}
void ImageBMP::save(const char* filename) const {
	FILE* f;
	fopen_s(&f, filename, "wb");
	if (f == NULL) {
		printf("No file to save found\n");
		exit(1);
		return;
	}
	save(f);
	fclose(f);
}
void ImageBMP::save(FILE* file) const {
	fwrite(buf, 1, full_len, file);
}
void ImageBMP::set(unsigned x, unsigned y, unsigned rgb) {
	char a[4];
	*(unsigned*)a = rgb;
	char* b = &buf[start + (height - y - 1) * line_len + 3 * x];
	b[0] = a[0];
	b[1] = a[1];
	b[2] = a[2];
}
unsigned ImageBMP::get(unsigned x, unsigned y) const {
	char* b = &buf[start + (height - y - 1) * line_len + 3 * x];
	char a[4];
	a[0] = b[0];
	a[1] = b[1];
	a[2] = b[2];
	a[3] = 0;
	return *(unsigned*)a;
}
void ImageBMP::bwrite(char* to, const void* buf, size_t el_size, size_t el_count, size_t& idx) {
	char* buf2 = (char*)buf;
	for (size_t i = 0, m = el_size * el_count; i < m; ++i) {
		to[idx] = buf2[i];
		idx++;
	}
}
char* ImageBMP::getImageBuf() const {
	return &buf[start];
}