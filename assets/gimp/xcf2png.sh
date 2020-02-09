#!/bin/sh

gimp -i --batch-interpreter=python-fu-eval -b - << EOF
import gimpfu

def convert(filename):
        img = pdb.gimp_file_load(filename, filename)
        new_name = filename.rsplit(".",1)[0] + ".png"
        layer = pdb.gimp_image_merge_visible_layers(img, 1)

        pdb.gimp_file_save(img, layer, new_name, new_name)
        pdb.gimp_image_delete(img)

$(for arg in $@; do echo convert\(\'$arg\'\); done)

pdb.gimp_quit(1)
EOF
