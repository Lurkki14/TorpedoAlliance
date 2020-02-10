textures = boost
in_textures = $(textures:=.xcf)
out_textures = $(textures:=.png)

gimp: ${in_textures}
	./xcf2png.sh ${in_textures}
	mv ${out_textures} ../textures
