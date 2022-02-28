#pragma once
#ifndef IMAGE_BMP_
#define IMAGE_BMP_
#include<stdlib.h>
#include<stdio.h>
class ImageBMP
{
public:
	size_t width, height;
	unsigned line_len;
	unsigned full_len;
	unsigned start = 54;
	char* buf;
public:
	ImageBMP(FILE* file);
	ImageBMP(const char* filename);
	ImageBMP(size_t width, size_t height);
	void save(FILE* f) const;
	void save(const char* filename) const ;
	void set(unsigned x, unsigned y, unsigned rgb);
	unsigned get(unsigned x, unsigned y) const;
	char* getImageBuf() const;
	~ImageBMP();
private:
	void bwrite(char* to, const void* buf, size_t el_size, size_t el_count, size_t& idx);
	void createBuf();
	inline void genParams();
	int readBMP(FILE* file);
};

#endif