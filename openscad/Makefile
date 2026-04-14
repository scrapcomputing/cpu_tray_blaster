# CPU Tray Blaster
#                                                             by Scrap Computing
#
# Usage: openscad=<path/to/openscad> make <target>
# Where: <path/to/openscad>: is the path to the OpenSCAD binary
#        <target>: is of the form <socket>_<grid size>.stl, where
#                  <socket> is one of the socket names listed in `params.json`
#                  <grid size> is <X>x<Y> where <X> and <Y> are grid dimensions
#                  Target `all` will generate 2x2 stls for all sockets.
#
# Example1: openscad=<path/to/openscad> make all
# Example2: openscad=<path/to/openscad> make socket3_2x2.stl
#
# The output stls are in the `stl/` directory.
#
ifndef out_dir
	out_dir=stl
endif
$(shell mkdir -p $(out_dir))


%.stl: cpu_tray_blaster.scad
ifndef openscad
	@echo "Error: Please specify the path to openscad."
	@echo "For example:"
	@echo "$$ openscad=/path/to/openscad make ..."
	@echo ""
	@exit 1
endif
# Extract the socket name from the target name.
	$(eval socket=$(basename $(word 1, $(subst _, ,$@))))
# Extract the grid size <grid_x>x<grid_y> from the target name.
ifndef grid
	$(eval grid=$(basename $(word 2, $(subst _, ,$@))))
endif
	$(eval grid_x=$(word 1, $(subst x, ,$(grid))))
	$(eval grid_y=$(word 2, $(subst x, ,$(grid))))
	@echo "socket=$(socket) grid_x=$(grid_x) grid_y=$(grid_y)"
# Create the output filename.
	$(eval filename=$(socket)_$(grid_x)x$(grid_y).stl)
# Run openscad to generate the stl.
	$(openscad) $< -P $(socket) -p params.json -o $(out_dir)/$(filename) -D grid_x=$(grid_x) -D grid_y=$(grid_y)

.phony: all clean

all: \
	socket3_2x2.stl \
	socket4_2x2.stl \
	socket7_2x2.stl \
	socket370_2x2.stl \
	socketA_2x2.stl \
	socket478_2x2.stl \
	socketAM_2x2.stl \
	socketCore_2x2.stl \
	socket1366_2x2.stl \
	socket2011_2x2.stl \
	socketG34_2x2.stl \

all: $(all_2x2_stl)

clean:
	rm -f $(out_dir)/*.stl
