#pragma once
class Writable {
public:
	virtual size_t sizeOf() const = 0;
	virtual void write(void* arr) = 0;
};