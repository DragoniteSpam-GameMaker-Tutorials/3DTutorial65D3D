function d3d_draw_sphere_simple(x, y, z, r, tex) {
    d3d_draw_ellipsoid_simple(x - r, y - r, z - r, x + r, y + r, z + r, tex);
}