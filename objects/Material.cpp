#include "Material.h"
union RGB {
	int rgb;
	unsigned char comps[4];
};
Material::Material(int rgb, double refl):type(MATERIAL_FILL), reflect(refl) {
	RGB col;
	col.rgb = rgb;
	diffuse.set(col.comps[2], col.comps[1], col.comps[0]);
	diffuse *= 1. / 255;
}
Material::Material(Vector3 rgb, double refl):type(MATERIAL_FILL), reflect(refl), diffuse(rgb){}
Material::Material(Vector3 rgb):type(MATERIAL_LIGHT), reflect(0), diffuse(rgb) {}
size_t Material::sizeOf() const {
	switch (type) {
	case MATERIAL_FILL:
		return 8 * (1 + 3 + 1);
	case MATERIAL_LIGHT:
		return 8 * (1 + 3);
	}
	return 0;
}
void Material::write(void* to) {
	double* dp = (double*)to;
	int i = 0;
	*(__int64*)&dp[i] = type;
	dp[++i] = diffuse.x;
	dp[++i] = diffuse.y;
	dp[++i] = diffuse.z;
	if (type == MATERIAL_FILL) {
		dp[++i] = reflect;
	}
}