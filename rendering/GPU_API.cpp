#include "GPU_API.h"
int readFile(const char* name, char** buf, size_t* size) {
	FILE* f;
	int ret;
	ret = fopen_s(&f, name, "rb");
	if (ret != 0)
		return ret;
	fseek(f, 0, SEEK_END);
	size_t s = ftell(f);
	fseek(f, 0, SEEK_SET);
	*buf = new char[s];
	size_t count = fread(*buf, 1, s, f);
	fclose(f);
	if (count != s) {
		delete[] * buf;
		return 1;
	}
	*size = s;
	return ret;
}
int GPU_API::init(const char** file_names, size_t file_count, const char* func_name) {
	cl_uint count;
	size_t count_s;
	cl_int ret;
	ret = clGetPlatformIDs(1, &pl_id, &count);
	if (count == 0 || ret != 0) {
		error = "Error with getting platform";
		return 1;
	}
	ret = clGetPlatformInfo(pl_id, CL_PLATFORM_VERSION, 100, plat_version, &count_s);
	if (ret != 0) {
		error = "Error getting platform version";
		return 1;
	}
	ret = clGetDeviceIDs(pl_id, CL_DEVICE_TYPE_GPU, 1, &dev_id, &count);
	if (ret != 0 || count == 0) {
		error = "No GPU found";
		return 1;
	}
	ret = clGetDeviceInfo(dev_id, CL_DEVICE_NAME, 100, dev_version, &count_s);
	if (ret != 0) {
		error = "Couldn't get device version";
		return 1;
	}
	context = clCreateContext(NULL, 1, &dev_id, NULL, NULL, &ret);
	if (ret != 0) {
		error = "Couldn't create context";
		return 1;
	}
	queue = clCreateCommandQueueWithProperties(context, dev_id, NULL, &ret);
	if (ret != 0) {
		error = "Couldn't create command queue";
		return 1;
	}
	size_t* prog_len = new size_t[file_count];
	char** program_text = new char*[file_count];
	for (size_t i = 0; i < file_count; ++i) {
		ret = readFile(file_names[i], &program_text[i], &prog_len[i]);
		if (ret != 0) {
			error = "Couldn't read file";
			for (size_t j = 0; j < i; ++j)
				delete[] program_text[j];
			delete[] program_text;
			delete[] prog_len;
			return 1;
		}
	}
	program = clCreateProgramWithSource(context, file_count, (const char**)program_text, prog_len, &ret);
	for (size_t j = 0; j < file_count; ++j)
		delete[] program_text[j];
	delete[] program_text;
	delete[] prog_len;
	if (ret != 0) {
		error = "Couldn't create program";
		return 1;
	}
	ret = clBuildProgram(program, 1, &dev_id, NULL, NULL, NULL);
	if (ret != 0) {
		error = "Couldn't build program";
		char* a = new char[8192];
		size_t size;
		clGetProgramBuildInfo(program, dev_id, CL_PROGRAM_BUILD_LOG, 8192, a, &size);
		std::cout << a << "\n";
		delete[] a;
		return 1;
	}
	kernel = clCreateKernel(program, func_name, &ret);
	if (ret != 0) {
		error = "Couldn't create kernel";
		return 1;
	}
	return 0;
}
void GPU_API::print_info() {
	const cl_device_info id[] = {
		CL_DEVICE_MAX_CLOCK_FREQUENCY,
		CL_DEVICE_MAX_COMPUTE_UNITS,
		CL_DEVICE_MAX_WORK_GROUP_SIZE
	};
	const char* str[] = {
		"CLOCK_FREQ",
		"UNITS",
		"MAX_WORK_GROOP_SIZE"};
	for (int i = 0; i < sizeof(id) / sizeof(int); ++i) {
		size_t val;
		unsigned int ret;
		size_t val_len;
		val = 0;
		ret = clGetDeviceInfo(dev_id, id[i], sizeof(size_t), &val, &val_len);
		std::cout << str[i] << ": ";
		if (ret != 0)
			std::cout << "Undefined\n";
		else
			std::cout << val << "\n";
	}
	size_t dims[3];
	size_t val_len;
	unsigned ret;
	ret = clGetDeviceInfo(dev_id, CL_DEVICE_MAX_WORK_ITEM_SIZES, sizeof(dims), dims, &val_len);
	std::cout << "MAX_WORK_ITEM_SIZES: ";
	if (ret != 0) {
		std::cout << "Undefined\n";
	}else{
		std::cout << "(" << dims[0] << ", " << dims[1] << ", " << dims[2] << ")\n";
	}
}
cl_mem GPU_API::createBuffer(cl_mem_flags flags, size_t mem_size, int& ret) {
	return clCreateBuffer(context, flags, mem_size, NULL, &ret);
}
int GPU_API::deleteBuffer(cl_mem mem) {
	return clReleaseMemObject(mem);
}
int GPU_API::writeBuffer(cl_mem vmem, void* cmem, size_t size) {
	return clEnqueueWriteBuffer(queue, vmem, CL_TRUE, 0, size, cmem, 0, NULL, NULL);
}
int GPU_API::readBuffer(cl_mem vmem, void* cmem, size_t size) {
	return clEnqueueReadBuffer(queue, vmem, CL_TRUE, 0, size, cmem, 0, NULL, NULL);
}
int GPU_API::setKernelArg(int num, size_t size, const void* mem) {
	return clSetKernelArg(kernel, num, size, mem);
}
int GPU_API::execute(int dims, const size_t size[]) {
	return clEnqueueNDRangeKernel(queue, kernel, dims, NULL, size, NULL, 0, NULL, NULL);
}
GPU_API::~GPU_API() {
	int ret;
	ret = clFlush(queue);                   // отчищаем очередь команд
	ret = clFinish(queue);                  // завершаем выполнение всех команд в очереди
	ret = clReleaseKernel(kernel);                  // удаляем кернель
	ret = clReleaseProgram(program);                // удаляем программу OpenCL
	ret = clReleaseCommandQueue(queue);     // удаляем очередь команд
	ret = clReleaseContext(context);
}