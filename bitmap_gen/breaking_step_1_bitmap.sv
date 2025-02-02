localparam  int OBJECT_HEIGHT_Y = 7;
localparam  int OBJECT_WIDTH_X = 60;

logic [0:OBJECT_WIDTH_X-1] [0:OBJECT_HEIGHT_Y-1] [8-1:0] object_colors = {
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'h00, 8'hE8, 8'h97, 8'hE8, 8'h49, 8'hE8, 8'hE8, 8'hE8, 8'h97, 8'h49, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'h49, 8'hE8, 8'h97, 8'hE8, 8'h49, 8'hE8, 8'h49, 8'h49, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'h97, 8'hE8, 8'hE8, 8'h49, 8'hE8, 8'h00, 8'hFF },
{8'h00, 8'hE8, 8'hE8, 8'h49, 8'hE8, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'h49, 8'hE8, 8'h49, 8'hE8, 8'hE8, 8'h49, 8'h97, 8'h49, 8'hE8, 8'h49, 8'hE8, 8'hE8, 8'h49, 8'h49, 8'h49, 8'hE8, 8'h49, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'h49, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'h49, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'h49, 8'h49, 8'h97, 8'h00 },
{8'h00, 8'h97, 8'h97, 8'h49, 8'h49, 8'h49, 8'h97, 8'h49, 8'h49, 8'h97, 8'h97, 8'h49, 8'h97, 8'h97, 8'h97, 8'h97, 8'h49, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h49, 8'h97, 8'h97, 8'h97, 8'h97, 8'h97, 8'h49, 8'h49, 8'h97, 8'h49, 8'h97, 8'h49, 8'h49, 8'h49, 8'h97, 8'h97, 8'h49, 8'h97, 8'h97, 8'h97, 8'h97, 8'h49, 8'h97, 8'h49, 8'h97, 8'h97, 8'h97, 8'h49, 8'h97, 8'h00 },
{8'h00, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'hE8, 8'h97, 8'h49, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'h49, 8'h97, 8'h49, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'h97, 8'hE8, 8'h49, 8'h49, 8'h49, 8'hE8, 8'h97, 8'h49, 8'hE8, 8'h49, 8'h49, 8'h49, 8'h97, 8'hE8, 8'hE8, 8'h00 },
{8'hFF, 8'h00, 8'hE8, 8'hE8, 8'hE8, 8'h97, 8'h49, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'hE8, 8'h97, 8'h49, 8'hE8, 8'h49, 8'h49, 8'hE8, 8'h49, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'h49, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h97, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h49, 8'h49, 8'hE8, 8'hE8, 8'hE8, 8'hE8, 8'h97, 8'hE8, 8'h00, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF }
};

wire [7:0] red_sig, green_sig, blue_sig;
assign red_sig     = {object_colors[offsetY][offsetX][7:5] , 5'd0};
assign green_sig   = {object_colors[offsetY][offsetX][4:2] , 5'd0};
assign blue_sig    = {object_colors[offsetY][offsetX][1:0] , 6'd0};


