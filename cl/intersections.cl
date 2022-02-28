double getDist(double t1, double t2){
	if (t1 < 0 && t2 < 0)
        return NAN;
    if (t1 > t2) {
        double t = t1;
        t1 = t2;
        t2 = t;
    }
    if (t1 < 0)
        return t2;
    return t1;
}
double nasphInter(double3 center, double rad2,
 double3 pos, double3 dir){
	double3 tmp = center - pos;
	double k1 = d3_len2(dir);
	double k2 = d3_scl(tmp, dir);
    double k3 = d3_len2(tmp) - rad2;
    double disk = k2 * k2 - k1 * k3;
    if (disk < 0)
        return NAN;
    if (disk == 0) {
        double t = k2 / k1;
        if (t < 0)
            return NAN;
        return t;
    }
    else {
        disk = sqrt(disk);
        return getDist(
            (k2 + disk) / k1,
            (k2 - disk) / k1);
    }
}
double nahalvInter(double3 center, struct Matrix rot,
double3 pos, double3 dir){
	double3 p = Matrix_transform(rot, center - pos);
	double3 d = Matrix_transform(rot, dir);
	if (d.x == 0) {
		if (p.x < 0)
			return INFINITY;
		return NAN;
	}
	double t1 = p.x / d.x;
	double t2 = INFINITY * d.x;
	return getDist(t1, t2);
}
