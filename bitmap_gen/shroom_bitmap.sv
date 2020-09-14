localparam  int OBJECT_HEIGHT_Y = 16;
localparam  int OBJECT_WIDTH_X = 16;

logic [0:OBJECT_WIDTH_X-1] [0:OBJECT_HEIGHT_Y-1] [8-1:0] object_colors = {
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hB6, 8'hB6, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'hFF, 8'h00, 8'h80, 8'hC4, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF },
{8'h00, 8'h80, 8'h80, 8'hC4, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'hB6, 8'hB6, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'hB6, 8'h00 },
{8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'hB6, 8'h00 },
{8'h00, 8'h92, 8'h92, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'hDB, 8'hB6, 8'h00 },
{8'h00, 8'h92, 8'h92, 8'h92, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hDB, 8'hDB, 8'hB6, 8'hC4, 8'h00 },
{8'h00, 8'h92, 8'h92, 8'h92, 8'h80, 8'hC4, 8'hB6, 8'hB6, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h00 },
{8'h00, 8'h92, 8'h92, 8'h92, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hC4, 8'hC4, 8'hC4, 8'h00 },
{8'hFF, 8'h00, 8'h92, 8'h00, 8'hCD, 8'hCD, 8'hDB, 8'hCD, 8'hCD, 8'hCD, 8'hDB, 8'hCD, 8'h00, 8'hC4, 8'h00, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'hCD, 8'hD6, 8'hD6, 8'h00, 8'hFA, 8'hFA, 8'hFA, 8'h00, 8'hFA, 8'hD6, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'hCD, 8'hD6, 8'hD6, 8'h92, 8'hFA, 8'hFA, 8'hFA, 8'h92, 8'hFA, 8'hCD, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'h00, 8'hCD, 8'hD6, 8'hD6, 8'hD6, 8'hFA, 8'hFA, 8'hD6, 8'hCD, 8'h00, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF }
};

wire [7:0] red_sig, green_sig, blue_sig;
assign red_sig     = {object_colors[offsetY][offsetX][7:5] , 5'd0};
assign green_sig   = {object_colors[offsetY][offsetX][4:2] , 5'd0};
assign blue_sig    = {object_colors[offsetY][offsetX][1:0] , 6'd0};


