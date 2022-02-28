#pragma once
#ifndef GPU_API_
#define GPU_API_
#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif
#include <iostream>
class GPU_API
{
public:
	const char* error;
	cl_platform_id pl_id;
	cl_device_id dev_id;
	char plat_version[100];
	char dev_version[100];
	
	cl_context context;

	cl_program program;
	cl_kernel kernel;

	cl_command_queue queue;
	~GPU_API();
	int init(const char** file_names, size_t file_count, const char* func_name);
	cl_mem createBuffer(cl_mem_flags flags, size_t mem_size, int &ret);
	int deleteBuffer(cl_mem mem);
	int writeBuffer(cl_mem vmem, void* cmem, size_t size);
	int readBuffer(cl_mem vmem, void* cmem, size_t size);
	int setKernelArg(int num, size_t size, const void* mm);
	int execute(int dims, const size_t size[]);
};	


#endif