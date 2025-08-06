//####################################################################################################################################//
//  Module Name  : ekorv32_core_mem_ctrl_unit.v
//  Project      : EkoRV-32 
//  Author       : Ekin Akyildirim
//  Change Log   : 07.06.2025 | E.Akyildirim | v1.0
//  Description  : EkoRV-32 Memory Controller Module.
//####################################################################################################################################//

//----------------------------------------------------------------------//
//============================== INCLUDES ==============================//
//----------------------------------------------------------------------//
`include "ekorv32_defines.vh"

//----------------------------------------------------------------------//
//================ MODULE PARAMETERS,INPUTS AND OUTPUTS ================//
//----------------------------------------------------------------------//
module ekorv32_core_mem_ctrl_unit (
    input clk_i,
    input rst_i,

    // Memory Controller Ports
    input [`RVLENM1:`RVLEN0] mem_ctrl_addr_i,
    input [`RVLENM1:`RVLEN0] mem_ctrl_data_i,
    input [`MEM_CTRL1:`MEM_CTRL0] mem_ctrl_byte_en_i,
    input mem_ctrl_sign_extend_i,
    input mem_ctrl_execute_i,
    input mem_ctrl_we_i,
    output mem_ctrl_data_ready_o,
    output mem_ctrl_ready_o,
    output [`RVLENM1:`RVLEN0] mem_ctrl_data_o,

    // Memory Ports
    input [`RVLENM1:`RVLEN0] mem_data_i,
    input mem_ready_i,
    input mem_data_ready_i,
    output mem_en_o,
    output mem_we_o,
    output [`A11:`A0] mem_addr_o,
    output [`RVLENM1:`RVLEN0] mem_data_o
);
//----------------------------------------------------------------------//
//============================ LOCALPARAMS =============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================= REGISTERS ==============================//
//----------------------------------------------------------------------//
    reg [`A11:`A0] mem_addr_reg;
    reg [`RVLENM1:`RVLEN0] mem_data_reg;
    reg mem_en_reg;
    reg mem_we_reg;
    reg mem_ctrl_data_ready_reg;
    reg mem_ctrl_ready_reg;
    reg [`RVLENM1:`RVLEN0] mem_ctrl_data_reg;
//----------------------------------------------------------------------//
//=============================== WIRES ================================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//=========================== STATE MACHINE ============================//
//----------------------------------------------------------------------//
   reg [`A1:`A0] stg_reg;
//----------------------------------------------------------------------//
//=========================== INSTANTIATIONS ===========================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================== PROCESS ===============================//
//----------------------------------------------------------------------//
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            mem_addr_reg <= `A0;
            mem_data_reg <= `A0;
            mem_en_reg <= `RV1B0;
            mem_we_reg <= `RV1B0;
            mem_ctrl_data_ready_reg <= `RV1B0;
            mem_ctrl_ready_reg <= `RV1B0;
            mem_ctrl_data_reg <= `A0;
            stg_reg <= `A0;
        end else begin
            case (stg_reg)
            `MEM_IDLE: begin
                if((mem_ctrl_execute_i == `RV1B1) && (mem_ready_i == `RV1B1)) begin
                    mem_we_reg <= mem_ctrl_we_i;
                    mem_data_reg <= mem_ctrl_data_i;
                    mem_addr_reg <= mem_ctrl_addr_i[`A13:`A2];
                    mem_en_reg <= `RV1B1;
                    mem_ctrl_data_ready_reg <= `RV1B0;
                    if(mem_ctrl_we_i == `RV1B0) begin
                        stg_reg <= `MEM_READ;
                    end else begin
                        stg_reg <= `MEM_WRITE;
                    end
                end
            end
            `MEM_READ: begin
                mem_en_reg <= `RV1B0;
                if(mem_data_ready_i) begin
                    mem_ctrl_data_ready_reg <= `RV1B1;
                    if(mem_ctrl_sign_extend_i == `RV1B1) begin
                        if (mem_ctrl_byte_en_i == `MEM_SIZE_B) begin
                            mem_ctrl_data_reg <= {{`BYTE3{mem_data_i[`BYTE1M1]}}, mem_data_i[`BYTE1M1:`RVLEN0]};
                        end else if (mem_ctrl_byte_en_i == `MEM_SIZE_H) begin
                            mem_ctrl_data_reg <= {{`BYTE2{mem_data_i[`BYTE2M1]}}, mem_data_i[`BYTE2M1:`RVLEN0]};
                        end else if (mem_ctrl_byte_en_i == `MEM_SIZE_W) begin
                            mem_ctrl_data_reg <= mem_data_i;
                        end
                    end else begin
                        mem_ctrl_data_reg <= mem_data_i;
                    end
                    stg_reg <= `MEM_WRITE;
                end
            end
            `MEM_WRITE: begin
                mem_en_reg <= `RV1B0;
                stg_reg <= `MEM_IDLE;
                mem_ctrl_data_ready_reg <= `RV1B0;
            end
            endcase
        end
    end 
//----------------------------------------------------------------------//
//============================== ASSIGNS ===============================//
//----------------------------------------------------------------------//
    assign mem_ctrl_data_o = mem_ctrl_data_reg;
    assign mem_ctrl_data_ready_o = mem_ctrl_data_ready_reg;
    assign mem_ctrl_ready_o = (stg_reg == `MEM_IDLE) ? (mem_ready_i & ~mem_ctrl_execute_i) : `RV1B0;
    assign mem_en_o = mem_en_reg;
    assign mem_data_o = mem_data_reg;
    assign mem_addr_o = mem_addr_reg;
    assign mem_we_o = mem_we_reg;
endmodule
//----------------------------------------------------------------------//
//=============================== NOTES ================================//
//----------------------------------------------------------------------//

//####################################################################################################################################//