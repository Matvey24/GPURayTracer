#include "Camera.h"
#include "Scene.h"
#include "objects/Objects.h"
int initGPU(GPU_API& api) {
    clock_t t = clock();
    const char* names[] = {
        "cl/math.cl",
        "cl/ImageBMP.cl",
        "cl/intersections.cl",
        "cl/figures.cl",
        "cl/simple.cl" };
    int ret = api.init(names, sizeof(names) / sizeof(char*), "main");
    t = clock() - t;
    std::cout << "GPU initialisation finished in " << t << " millis\n\n";
    if (ret != 0) {
        std::cout << api.error << "\n";
        return 1;
    }
    else {
        std::cout << api.plat_version << "\n" << api.dev_version << "\n\n";
        return 0;
    }
}
void default_scene() {
    GPU_API api;
    if (initGPU(api))
        return;
    Camera c(1920, 1080, api);
    Scene scene;
    //
    Sphere sp;
    sp.dot.pos.set(0, 0, 4);
    sp.dot.color.set(1, 0, 0);
    sp.rad2 = 1;
    scene.objs.push_back(&sp);
    //
    Sphere floor;
    floor.dot.pos.set(0, -100, 0);
    floor.dot.color.set(0, 1, 1);
    floor.rad2 = 99. * 99;
    scene.objs.push_back(&floor);
    //
    c.rot.setRotY(Vector2(M_PI / 8));

    size_t scene_size = scene.sizeOf();
    void* mem = malloc(scene_size);
    scene.write(mem);
    c.render(mem, scene_size);
    std::cout << "buffers prepared in " << c.push_time << " millis\n";
    std::cout << "rendered in " << c.rend_time << " millis\n";
    std::cout << "copied from VRAM in " << c.poll_time << " millis\n";
    c.im.save("images/img0.bmp");
    free(mem);
}
int main(int argc, char** argv)
{
    default_scene();
    return 0;
}