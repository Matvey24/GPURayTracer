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
double calcReflect(double sclDirNorm, double ref){
    ref = 1 - ref;
    double cosfi = d_module(sclDirNorm);
    double sinfi = sqrt(1 - cosfi * cosfi);
    double sinpsi = ref * sinfi;
    double cospsi = sqrt(1 - sinpsi * sinpsi);
    double rpe = (cosfi - ref*cospsi)/(cosfi + ref*cospsi);
    double rpa = (ref*cosfi - cospsi)/(ref*cosfi +cospsi);
    return sqrt((rpe * rpe + rpa * rpa) / 2);
}
double nasphInter(double rad2,
 double3 pos, double3 dir){
	double k1 = d3_len2(dir);
	double k2 = d3_scl(pos, dir);
    double k3 = d3_len2(pos) - rad2;
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
double naRectInter(double3 bd, double3 p, double3 d){
    if ((d.x == 0 && d_module(p.x) > bd.x)
        || (d.y == 0 && d_module(p.y) > bd.y)
        || (d.z == 0 && d_module(p.z) > bd.z))
        return NAN;
    //p = -p;
    double s1, s2, s3, e1, e2, e3;
    double t1 = (p.x + bd.x) / d.x;
    double t2 = (p.x - bd.x) / d.x;
    s1 = min(t1, t2);
    e1 = max(t1, t2);
    t1 = (p.y + bd.y) / d.y;
    t2 = (p.y - bd.y) / d.y;
    s2 = min(t1, t2);
    e2 = max(t1, t2);
    t1 = (p.z + bd.z) / d.z;
    t2 = (p.z - bd.z) / d.z;
    s3 = min(t1, t2);
    e3 = max(t1, t2);
    t1 = max(max(s1, s2), s3);
    t2 = min(min(e1, e2), e3);
    if (t1 > t2 || t2 < 0)
        return NAN;
    return t1;
}
