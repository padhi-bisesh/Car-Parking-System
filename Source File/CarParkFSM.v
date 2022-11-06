module CarParkFSM #(parameter w_pass = 4)(
    input clk,rst,
    input entrance_front,
    input entrance_back,
    input exit,
    input [w_pass-1:0] USER,PASSWORD,

    output reg LED_RED,
    output reg LED_GREEN,
    output reg [2:0] STATE,

    output [2:0] SPOTS_AVAILABLE
);
parameter cred_USER = 3'b011;
parameter cred_PASSWORD = 3'b101;

parameter IDLE = 3'b000;
parameter WAIT_PASSWORD = 3'b001;
parameter RIGHT_PASSWORD = 3'b010;
parameter WRONG_PASSWORD = 3'b011;
parameter STOP = 3'b100;

reg [2:0] curr_state,next_state;

reg [2:0] car_count;
reg incr_count;
reg decr_count;

reg [9:0] wait_timer;

wire correct_credentials;
assign correct_credentials = ((USER == cred_USER) && (PASSWORD == cred_PASSWORD));

assign SPOTS_AVAILABLE = (4 - car_count);

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        curr_state <= IDLE;
    end
    else begin
        curr_state <= next_state;
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        car_count <= 0;
    end
    else if (incr_count && decr_count) begin
        car_count <= car_count;
    end
    else if (incr_count) begin
        car_count <= (car_count < 4) ? (car_count + 1) : car_count;
    end
    else if (decr_count) begin
        car_count <= (car_count > 0) ? (car_count - 1) : car_count;
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        wait_timer <= 0;
    end
    else begin
        if(curr_state == WAIT_PASSWORD) begin
            wait_timer <= wait_timer + 1;
        end
        else begin 
            wait_timer <= 0;
        end
    end
end

always @(*) begin
    case(curr_state)
        IDLE : begin
            if(entrance_front && car_count < 4) begin
                next_state <= WAIT_PASSWORD;
            end
            else next_state <= IDLE;
        end
        WAIT_PASSWORD : begin
            if (wait_timer < 5) begin
                if(correct_credentials) begin
                    next_state <= RIGHT_PASSWORD;
                end
                else begin
                    next_state <= WAIT_PASSWORD;
                end
            end
            else begin
                if(correct_credentials) begin
                    next_state <= RIGHT_PASSWORD;
                end
                else begin
                    next_state <= WRONG_PASSWORD;
                end
            end
        end

        RIGHT_PASSWORD : begin
            if(entrance_front && entrance_back) begin
                next_state <= STOP;
            end
            else if ((~entrance_front) && entrance_back) begin
                next_state <= IDLE;
            end
        end

        WRONG_PASSWORD : begin
            if(correct_credentials) begin
                next_state <= RIGHT_PASSWORD;
            end
            else begin
                next_state <= WRONG_PASSWORD;
            end
        end

        STOP : begin
            if(correct_credentials && car_count<3) begin
                next_state <= RIGHT_PASSWORD;
            end
            else begin
                next_state <= STOP;
            end
        end
    endcase
end

always @(*) begin
    LED_GREEN = 0;
    LED_RED = 0;
    incr_count = 0;
    decr_count = 0;
    STATE = IDLE;
    if(exit) begin
        decr_count = 1;
    end
    case(curr_state)
    IDLE : begin
        if(entrance_front == 1 && car_count == 4) begin
            LED_RED = 1;
        end
        STATE = IDLE;
    end
    WAIT_PASSWORD : begin
        LED_RED = 1;
        if(correct_credentials) begin
            incr_count = 1;
        end
        STATE = WAIT_PASSWORD;
    end
    RIGHT_PASSWORD : begin
        LED_GREEN = 1;
        STATE = RIGHT_PASSWORD;
    end
    WRONG_PASSWORD : begin
        LED_RED = 1;
        if(correct_credentials) begin
            incr_count = 1;
        end
        STATE = WRONG_PASSWORD;
    end
    STOP : begin
        LED_RED = 1;
        if(correct_credentials) begin
            incr_count = 1;
        end
        STATE = STOP;
    end
    endcase   
end
endmodule