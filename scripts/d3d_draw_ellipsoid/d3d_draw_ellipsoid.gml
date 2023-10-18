function d3d_draw_ellipsoid(x1, y1, z1, x2, y2, z2, tex, hrepeat, vrepeat, steps, c = draw_get_colour(), a = draw_get_alpha()) {
    static vertex = Drago3D_Internals.Vertex;
    static format = Drago3D_Internals.format;
    
    static cache = { };
    static archive = ds_priority_create();
    
    steps = clamp(steps, 3, 128);
    
    var color_word = c | floor(a * 255) << 16;
    var key = string("{0} {1} {2} {3}", string_format(hrepeat, 1, 4), string(vrepeat, 1, 4), steps, color_word);
    
    var oldrep = gpu_get_texrepeat();
    gpu_set_texrepeat(true);
    
    var vb = cache[$ key];
    if (vb == undefined) {
        vb = vertex_create_buffer();
        vertex_begin(vb, format);
        
        static r = 0.5;
        
        // Create sin and cos tables
        var cc = array_create(steps + 1);
        var ss = array_create(steps + 1);
        
        for(var i = 0; i <= steps; i++) {
        	var rad = (i * 2.0 * pi) / steps;
        	cc[i] = cos(rad);
        	ss[i] = sin(rad);
        }
        
        var rows = floor((steps + 1) / 2);
        var vrows = vrepeat / rows;
        
        for(var j = 0; j < rows; j++) {
            var jvr1 = j * vrows;
            var jvr2 = (j + 1) * vrows;
            
        	var row1rad = (j * pi) / rows;
        	var row2rad = ((j + 1) * pi) / rows;
        	var rh1 = cos(row1rad);
        	var rd1 = sin(row1rad);
        	var rh2 = cos(row2rad);
        	var rd2 = sin(row2rad);
            
            var rrd1 = r * rd1;
            var rrd2 = r * rd2;
            var rrh1 = r * rh1;
            var rrh2 = r * rh2;
	        
        	for(var i = 0; i <= steps; i++) {
                var f = i / steps * hrepeat;
                var cci = cc[i];
                var ssi = ss[i];
        		vertex(vb, rrd1 * cci, rrd1 * ssi, rrh1, rd1 * cci, rd1 * ssi, rh1, f, jvr1, c, a);
        		vertex(vb, rrd2 * cci, rrd2 * ssi, rrh2, rd2 * cci, rd2 * ssi, rh2, f, jvr2, c, a);
        	}
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
    
    matrix_set(matrix_world, current);
    gpu_set_texrepeat(oldrep);
    
    Drago3D_Internals.Unarchive(archive, cache, 100);
}