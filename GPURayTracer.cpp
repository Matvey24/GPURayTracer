#include "Camera.h"
#include "Scene.h"
#include "objects/Objects.h"
#include "objects/Material.h"
int initGPU(GPU_API& api) {
    clock_t t = clock();
    const char* names[] = {
        "cl/math.cl",
        "cl/ImageBMP.cl",
        "cl/intersections.cl",
        "cl/figures.cl",
        "cl/simple.cl" 
    };
    int ret = api.init(names, sizeof(names) / sizeof(char*), "worker_main");
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
int init(GPU_API& api) {
    if (initGPU(api))
        return 1;
    api.print_device_info();
    api.print_kernel_info();
    std::cout << "\n";
    return 0;
}
void render(const char* file_name, Camera &c, Scene &scene) {
    size_t scene_size = scene.sizeOf();
    void* mem = malloc(scene_size);
    scene.write(mem);
    if (c.render(mem, scene_size) != 0) {
        std::cout << c.api.error << "\n";
    }
    std::cout << "buffers prepared in " << c.push_time << " millis\n";
    std::cout << "rendered in " << c.rend_time << " millis\n";
    std::cout << "copied from VRAM in " << c.poll_time << " millis\n";
    c.im.save(file_name);
    free(mem);
}
void default_scene() {
    GPU_API api;
    if (init(api))
        return;
    Camera c(548, 548, api);
    Scene scene;

    Material yel(0xffff01, 0.1);
    Material cyan(0x8181ff, 0.1);
    scene.maters.push_back(&yel);
    scene.maters.push_back(&cyan);

    // 
    MandelBulb sp;
    sp.dot.pos.set(7, 0, 0);
    sp.dot.mater = 1;
    sp.size = 1;
    //
    Rect floor;
    floor.dot.pos.set(0, -2.5, 0);
    floor.dot.mater = 0;
    floor.bd.set(100, 1, 100);
    scene.objs.push_back(&floor);
    scene.objs.push_back(&sp);

    //
    Matrix ma1, ma2;
    ma1.setRotZ(-M_PI / 7);
    ma2.setRotY(-0);
    c.rot.setRotY(Vector2(M_PI / 2));
    c.rot = ma2 * ma1 * c.rot;
    c.pos.set(5, 1, 0);
    
    render("images/img_simp.bmp", c, scene);
}
void carnellBox() {
    GPU_API api;
    if (init(api))
        return;
    Camera c(1280, 720, api);
    c.pos.set(0, 2, -8);
    //c.rot.setRotX(Vector2(M_PI / 10));
    Scene scene;
    
    Material light_mat(Vector3(16, 16, 16));
    Material floor_mat(0x0000ff, 0);
    Material up_mat(0xffff00, 0);

    scene.maters.push_back(&light_mat);
    scene.maters.push_back(&floor_mat);
    scene.maters.push_back(&up_mat);

    Rect light(0, 4, 0, 1, 0.1, 1);
    light.dot.mater = 0;

    Rect floor(0, -1, 0, 4, 1, 4);
    floor.dot.mater = 1;

    Rect up(0, 5, 0, 4, 1, 4);
    up.dot.mater = 2;

    scene.objs.push_back(&light);
    scene.objs.push_back(&floor);
    scene.objs.push_back(&up);

    render("images/img_simp.bmp", c, scene);
}
int main(int argc, char** argv)
{
    default_scene();
    return 0;
}