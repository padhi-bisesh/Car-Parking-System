module CarParkFSMTestbench;
parameter w_pass = 4;
reg clk;
reg rst;
reg entrance_front;
reg entrance_back;
reg exit;
reg [w_pass-1:0] USER,PASSWORD;

output LED_RED;
output LED_GREEN;
output [2:0] STATE;
output [2:0] SPOTS_AVAILABLE;

CarParkFSM DUT (
    .clk(clk),
    .rst(rst),
    .entrance_front(entrance_front),
    .entrance_back(entrance_back),
    .exit(exit),
    .USER(USER),
    .PASSWORD(PASSWORD),
    .LED_RED(LED_RED),
    .LED_GREEN(LED_GREEN),
    .STATE(STATE),
    .SPOTS_AVAILABLE(SPOTS_AVAILABLE)
);

always #5 clk = ~ clk;

initial begin
    clk= 1;
    rst = 1;
    #1 rst = 0;
    #1 rst = 1;
    USER = 0;
    PASSWORD = 0;
    entrance_front = 0;
    entrance_back = 0;
end

initial begin
    $dumpfile("CarParkFSMTestbench.vcd");
    $dumpvars(0,CarParkFSMTestbench);
    
    #2
    #0
    entrance_front = 1; #10 entrance_front = 1; USER = 3; PASSWORD = 5; #40 entrance_front = 0; entrance_back = 1; #10 entrance_back = 0;

    #10
    entrance_front = 1; #10 entrance_front = 1; USER = 3; PASSWORD = 2; #10 PASSWORD = 3; #10 PASSWORD = 4; #10 PASSWORD = 5; #40 entrance_front = 0; entrance_back = 1; #10 entrance_back = 0;

    #10
    entrance_front = 1; #10 entrance_front = 1; USER = 3; PASSWORD = 5; #40 entrance_front = 0; entrance_back = 1; #10 entrance_back = 0;

    #10
    entrance_front = 1; #10 entrance_front = 1; USER = 3; PASSWORD = 5; #40 entrance_front = 0; entrance_back = 1; #10 entrance_back = 0;

    #10
    entrance_front = 1;

    #30
    exit = 1; #10 exit = 0; USER = 3; PASSWORD = 5; #40 entrance_front = 0; entrance_back = 1; #10 entrance_back = 0;

    #100;
    $finish;
end
endmodule