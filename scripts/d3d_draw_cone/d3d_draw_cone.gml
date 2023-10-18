function d3d_draw_cone(x1, y1, z1, x2, y2, z2, tex, hrepeat, vrepeat, closed, steps, c = draw_get_colour(), a = draw_get_alpha()) {
    static vertex = Drago3D_Internals.Vertex;
    static format = Drago3D_Internals.format;
    
    static cache = { };
    static cache_bottom = { };
    static archive = ds_priority_create();
    
    static r = 0.5;
    static nr = -r;
    
    steps = clamp(steps, 3, 128);
    
    var color_word = c | floor(a * 255) << 16;
    var key = string("{0} {1} {2} {3}", string_format(hrepeat, 1, 4), string(vrepeat, 1, 4), steps, color_word);
    
    var oldrep = gpu_get_texrepeat();
    gpu_set_texrepeat(true);
    
    var vb = cache[$ key];
    if (vb == undefined) {
        vb = vertex_create_buffer();
        vertex_begin(vb, format);
        
        // Create sin and cos tables
        var cc = array_create(steps + 1);
        var ss = array_create(steps + 1);
        var hsteps = hrepeat / steps;
        
        for(var i = 0; i <= steps; i++) {
        	var rad = (i * 2.0 * pi) / steps;
        	cc[i] = cos(rad);
        	ss[i] = sin(rad);
        }
        
        var rows = floor((steps + 1) / 2);
        var vrows = vrepeat / rows;
        
        for(var i = 0; i <= steps; i++) {
            var cci = cc[i];
            var ssi = ss[i];
        	vertex(vb, 0, 0, r, 0, 0, 1, hsteps * i, vrepeat, c, a);
        	vertex(vb, cci * r, ssi * r, nr, cci , ssi ,0 , hsteps * i, 0, c, a);
        }
        
        vertex_end(vb);
        vertex_freeze(vb);
        
        vb = { vb: vb, key: key };
        cache[$ key] = vb;
        ds_priority_add(archive, vb, current_time);
    }
    
    ds_priority_change_priority(archive, vb, current_time);
    
    var sx = x2 - x1;
    var sy = y2 - y1;
    var sz = z2 - z1;
    var cx = mean(x1, x2);
    var cy = mean(y1, y2);
    var cz = mean(z1, z2);
    var transform = matrix_build(cx, cy, cz, 0, 0, 0, sx, sy, sz);
    var current = matrix_get(matrix_world);
    matrix_set(matrix_world, matrix_multiply(transform, current));
    vertex_submit(vb.vb, pr_trianglestrip, tex);
    
    if (closed) {
        var cc = array_create(steps + 1);
        var ss = array_create(steps + 1);
        
        for(var i = 0; i <= steps; i++) {
        	var rad = (i * 2.0 * pi) / steps;
        	cc[i] = cos(rad);
        	ss[i] = sin(rad);
        }
        
        var hsteps = hrepeat / steps;
        vb = cache_bottom[$ key];
        if (vb == undefined) {
            vb = vertex_create_buffer();
            vertex_begin(vb, format);
            
            for(var i = steps; i > 0; i--) {
                var cci = cc[i] / 2;
                var ssi = ss[i] / 2;
                var cci2 = cc[i - 1] / 2;
                var ssi2 = ss[i - 1] / 2;
                vertex(vb, 0, 0, 0, 0, 0, 1, 0.5, 0.5, c, a);
            	vertex(vb, cci, ssi, 0, 0, 0, -1, 0.5 + cci * hrepeat, 0.5 + ssi * vrepeat, c, a);
            	vertex(vb, cci2, ssi2, 0, 0, 0, -1, 0.5 + cci2 * hrepeat, 0.5 + ssi2 * vrepeat, c, a);
            }
        	
            vertex_end(vb);
            vertex_freeze(vb);
            
            vb = { vb: vb, key: key };
            cache_bottom[$ key] = vb;
            ds_priority_add(archive, vb, current_time);
        }
        
        ds_priority_change_priority(archive, vb, current_time);
        
        transform = matrix_build(cx, cy, z1, 0, 0, 0, sx, sy, 1);
        matrix_set(matrix_world, matrix_multiply(transform, current));
        vertex_submit(vb.vb, pr_trianglelist, tex);
    }
    
    matrix_set(matrix_world, current);
    gpu_set_texrepeat(oldrep);
    
    Drago3D_Internals.Unarchive(archive, cache);
    Drago3D_Internals.Unarchive(archive, cache_bottom);
}