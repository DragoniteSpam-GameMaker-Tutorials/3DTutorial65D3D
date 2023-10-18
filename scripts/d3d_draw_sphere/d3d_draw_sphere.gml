function d3d_draw_sphere(x, y, z, r, tex, hrepeat = 1, vrepeat = 1, steps = 32, c = draw_get_colour(), a = draw_get_alpha()) {
    d3d_draw_ellipsoid(x - r, y - r, z - r, x + r, y + r, z + r, tex, hrepeat, vrepeat, steps, c, a);
}