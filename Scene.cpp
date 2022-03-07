#include "Scene.h"
Scene::Scene() {}

size_t Scene::sizeOf() const{
	size_t s = 3 * 8;
	for (size_t i = 0; i < objs.size(); ++i) {
		s += objs[i]->sizeOf();
	}
	for (size_t i = 0; i < maters.size(); ++i) {
		s += maters[i]->sizeOf();
	}
	return s;
}
void Scene::write(void* to) {
	__int64* d = (__int64*)to;
	size_t s = 2;
	for (size_t i = 0; i < objs.size(); ++i)
		s += objs[i]->sizeOf() / 8;
	size_t full_len = s;
	for (size_t i = 0; i < maters.size(); ++i)
		full_len += maters[i]->sizeOf() / 8;
	*d = full_len + 1;
	d = &d[1];
	*d = objs.size();
	d = &d[1];
	for (size_t i = 0; i < objs.size(); ++i) {
		__int64 len = objs[i]->sizeOf() / 8;
		objs[i]->write(d);

		size_t v = d[13];
		size_t off = s;
		for (size_t j = 0; j < v; ++j)
			off += maters[j]->sizeOf() / 8;
		d[13] = off;

		d = &d[len];
	}
	*d = maters.size();
	d = &d[1];
	for (size_t i = 0; i < maters.size(); ++i) {
		__int64 len = maters[i]->sizeOf() / 8;
		maters[i]->write(d);
		d = &d[len];
	}
}