shader_type canvas_item;

uniform float progress : hint_range(0, 1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//if ((UV.x < progress) || (UV.x > progress + 0.1)) {
	if (!((UV.x + UV.y > (2.0 * progress)) && (UV.x + UV.y < (2.0 * progress) + 0.05))) {
		discard;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
