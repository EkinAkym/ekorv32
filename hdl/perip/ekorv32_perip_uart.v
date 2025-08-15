//####################################################################################################################################//
//  Module Name  : ekorv32_perip_uart.v
//  Project      : EkoRV-32 
//  Author       : Ekin Akyildirim
//  Change Log   : Date | Designer Name | Version
//  Description  : Description   TODO!
//####################################################################################################################################//

//----------------------------------------------------------------------//
//============================== INCLUDES ==============================//
//----------------------------------------------------------------------//
`include "ekorv32_defines.vh"

//----------------------------------------------------------------------//
//================ MODULE PARAMETERS,INPUTS AND OUTPUTS ================//
//----------------------------------------------------------------------//
module ekorv32_perip_uart #(
    parameter clk_frequency_p = `CLOCK_FREQUENCY,
    parameter baudrate_p      = `UART_BAUDRATE,
    parameter stopbit_p       = `UART_TX_STOPBIT
    // TODO: Must be adjustable real-time (baudrate and stopbit)!
)(
    input clk_i,
    input rst_i,
    input rx_i,
    input tx_start_i,
    input [`BYTE1M1:`BYTE0] tx_data_i,
    output [`BYTE1M1:`BYTE0] rx_data_o,
    output tx_o,
    output rx_valid_o,
    output tx_valid_o
);
//----------------------------------------------------------------------//
//============================ LOCALPARAMS =============================//
//----------------------------------------------------------------------//
    localparam integer bittimerlim_lp = clk_frequency_p / baudrate_p;
    localparam integer stopnitlim_lp = clk_frequency_p / baudrate_p * stopbit_p;
//----------------------------------------------------------------------//
//============================= REGISTERS ==============================//
//----------------------------------------------------------------------//
    reg tx_reg;
    reg rx_valid_reg;
    reg tx_valid_reg;
    reg [`BYTE1M1:`BYTE0] rx_data_reg;
    reg [`BYTE1M1:`BYTE0] tx_data_reg;
    reg [`A15:`A0] tx_bit_timer_reg;
    reg [`A2:`A0] tx_bit_cnt_reg;
    reg [`A15:`A0] rx_bit_timer_reg;
    reg [`A2:`A0] rx_bit_cnt_reg;
//----------------------------------------------------------------------//
//=============================== WIRES ================================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//=========================== STATE MACHINE ============================//
//----------------------------------------------------------------------//
    reg [`A1:`A0] tx_state_reg;
    reg [`A1:`A0] rx_state_reg;
//----------------------------------------------------------------------//
//=========================== INSTANTIATIONS ===========================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================== PROCESS ===============================//
//----------------------------------------------------------------------//

//-- TX PROCESS --//
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            tx_state_reg <= `UART_ST_IDLE
            tx_reg <= `RV1B1;
            tx_valid_reg <= `RV1B0;
            tx_data_reg  <= `A0;
            tx_bit_timer_reg <= `A0;
            tx_bit_cnt_reg   <= `A0;
        end else begin
        case(state_reg)
            `UART_TX_ST_IDLE: begin
                tx_reg <= `TX_STOP_COND;
                tx_valid_reg <= `RV1B0;
                tx_bit_cnt_reg   <= `A0;
                if(tx_start_i == `RV1B1) begin
                    tx_state_reg <= `UART_TX_ST_START;
                    tx_reg <= `TX_START_COND;
                    tx_data_reg <= tx_data_i;
                end
            end
            `UART_TX_ST_START: begin
                if (tx_bit_timer_reg == bittimerlim_lp - `A1) begin
                    tx_state_reg <= `UART_TX_ST_DATA;
                    tx_reg <= tx_data_reg[tx_bit_cnt_reg];
                    tx_bit_timer_reg <= `A0;
                    tx_bit_cnt_reg <= tx_bit_cnt_reg + `A1;
                end else begin
                    tx_bit_timer_reg <= tx_bit_timer_reg + `A1;
                end
            end
            `UART_TX_ST_DATA: begin
                if ( tx_bit_cnt_reg == `BYTE1) begin
                    if (tx_bit_timer_reg == bittimerlim_lp - `A1) begin
                        tx_bit_cnt_reg <= `A0;
                        state_reg <= `UART_TX_ST_STOP;
                        tx_o <= `RV1B1;
                        tx_bit_timer_reg <= `A0;
                    end else begin
                        tx_bit_timer_reg <= tx_bit_timer_reg + `A1;
                    end
                end else begin
                    if (tx_bit_timer_reg == bittimerlim_lp - `A1) begin
                        tx_bit_cnt_reg <= tx_bit_cnt_reg + `A1;
                        tx_o <= tx_data_reg[tx_bit_cnt_reg];
                        tx_bit_timer_reg <= `A0;
                    end else begin
                        tx_bit_timer_reg <= tx_bit_timer_reg + `A1;
                    end
                end 
            end
            `UART_TX_ST_STOP: begin
                if (tx_bit_cnt_reg == stopnitlim_lp - `A1) begin
                    tx_state_reg <= `UART_TX_ST_IDLE;
                    tx_valid_reg <= `RV1B1;
                    tx_bit_timer_reg <= `A0;
                end else begin
                    tx_bit_timer_reg <= tx_bit_timer_reg + `A1;
                end
            end
        endcase
        end
    end 

//-- RX PROCESS --//
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            rx_state_reg <= `UART_RX_ST_IDLE
            rx_valid_reg <= `RV1B0;
            rx_data_reg  <= `A0;
            rx_bit_timer_reg <= `A0;
            rx_bit_cnt_reg <= `A0;
        end else begin
        case(state_reg)
            `UART_RX_ST_IDLE: begin
                rx_bit_timer_reg <= `A0;
                rx_bit_cnt_reg <= `A0;
                rx_valid_reg <= `RV1B0;
                if(rx_i == `RX_START_COND ) begin
                    state_reg <= `UART_RX_ST_START;
                end
            end
            `UART_RX_ST_START: begin
                if(rx_bit_timer_reg == (bittimerlim_lp / `A2) - `A1) begin
                    rx_state_reg <= `UART_RX_ST_DATA:;
                    rx_bit_timer_reg <= `A0;
                end else begin
                    rx_bit_timer_reg <= rx_bit_timer_reg + `A1;
                end
            end
            `UART_RX_ST_DATA: begin
                if (rx_bit_timer_reg == bittimerlim_lp - `A1) begin
                    rx_data_reg[rx_bit_cnt_reg] <= rx_i;
                    if(rx_bit_cnt_reg == `BYTE1M1) begin
                        rx_state_reg <= `UART_RX_ST_STOP;
                        rx_bit_cnt_reg <= `A0;
                    end else begin
                        rx_bit_cnt_reg <= rx_bit_cnt_reg +`A1;
                    end
                    rx_bit_timer_reg <= `A0;
                end else begin
                    rx_bit_timer_reg <= rx_bit_timer_reg + `A1;
                end
            end
            `UART_RX_ST_STOP: begin
                if (rx_bit_timer_reg == bittimerlim_lp - `A1) begin
                    rx_state_reg <= `UART_RX_ST_IDLE;
                    rx_bit_timer_reg <= `A0;
                    rx_valid_reg <= `RV1B1;
                end else begin
                    rx_bit_timer_reg <= rx_bit_timer_reg + `A1;
                end
            end
        endcase
        end
    end 
//----------------------------------------------------------------------//
//============================== ASSIGNS ===============================//
//----------------------------------------------------------------------//
    assign rx_data_o = rx_data_reg;
    assign tx_o = tx_reg;
    assign rx_valid_o = rx_valid_reg;
    assign tx_valid_o = tx_valid_reg;

endmodule
//----------------------------------------------------------------------//
//=============================== NOTES ================================//
//----------------------------------------------------------------------//

//####################################################################################################################################//