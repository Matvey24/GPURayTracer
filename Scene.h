#pragma once
#ifndef SCENE_H_
#define SCENE_H_
#include "objects/Writable.h"
#include <vector>
class Scene:public Writable
{
public:
	std::vector<Writable*> objs;
	Scene();
	size_t sizeOf() const;
	void write(void* to);
};

#endif