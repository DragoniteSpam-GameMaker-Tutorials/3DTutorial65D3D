function d3d_draw_floor_simple(x1, y1, x2, y2, z, tex) {
    static vertex = Drago3D_Internals.Vertex;
    static format = Drago3D_Internals.format;
    
    static vb = undefined;
    
    if (vb == undefined) {
        vb = vertex_create_buffer();
        vertex_begin(vb, format);
        
        var cx1 = -0.5;
        var cy1 = -0.5;
        var cx2 = 0.5;
        var cy2 = 0.5;
        var cz = 0;
        
        vertex(vb, cx1, cy1, cz, 0, 0, 1, 0, 0, c_white, 1);
        vertex(vb, cx1, cy2, cz, 0, 0, 1, 0, 1, c_white, 1);
        vertex(vb, cx2, cy2, cz, 0, 0, 1, 1, 1, c_white, 1);
        vertex(vb, cx2, cy2, cz, 0, 0, 1, 1, 1, c_white, 1);
        vertex(vb, cx2, cy1, cz, 0, 0, 1, 1, 0, c_white, 1);
        vertex(vb, cx1, cy1, cz, 0, 0, 1, 0, 0, c_white, 1);
        
        vertex_end(vb);
        vertex_freeze(vb);
    }
    
    var sx = x2 - x1;
    var sy = y2 - y1;
    var cx = mean(x1, x2);
    var cy = mean(y1, y2);
    var transform = matrix_build(cx, cy, z, 0, 0, 0, sx, sy, 1);
    var current = matrix_get(matrix_world);
    matrix_set(matrix_world, matrix_multiply(transform, current));
    
    vertex_submit(vb, pr_trianglelist, tex);
    
    matrix_set(matrix_world, current);
}