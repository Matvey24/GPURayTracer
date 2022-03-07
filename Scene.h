#pragma once
#ifndef SCENE_H_
#define SCENE_H_
#include "objects/Writable.h"
#include "objects/Dot.h"
#include "objects/Material.h"
#include <vector>
class Scene:public Writable
{
public:
	std::vector<Writable*> objs;
	std::vector<Material*> maters;
	Scene();
	size_t sizeOf() const;
	void write(void* to);
};

#endif