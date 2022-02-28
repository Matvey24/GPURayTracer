#include "Scene.h"
Scene::Scene() {}
size_t Scene::sizeOf() const{
	size_t s = sizeof(__int64);
	for (size_t i = 0; i < objs.size(); ++i) {
		s += sizeof(__int64) + objs[i]->sizeOf();
	}
	return s;
}
void Scene::write(void* to) {
	__int64* d = (__int64*)to;
	*d = objs.size();
	d = &d[1];
	for (size_t i = 0; i < objs.size(); ++i) {
		__int64 len = objs[i]->sizeOf();
		*d = len;
		d = &d[1];
		objs[i]->write(d);
		d = (__int64*)(((char*)d) + len);
	}
}