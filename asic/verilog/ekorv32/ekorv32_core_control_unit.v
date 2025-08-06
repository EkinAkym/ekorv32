//####################################################################################################################################//
//  Module Name  : ekorv32_core_control_unit.v
//  Project      : EkoRV-32 
//  Author       : Ekin Akyildirim
//  Change Log   : 07.06.2025 | E.Akyildirim | v1.0
//  Description  : EkoRV-32 Core control unit.
//####################################################################################################################################//

//----------------------------------------------------------------------//
//============================== INCLUDES ==============================//
//----------------------------------------------------------------------//
`include "ekorv32_defines.vh"

//----------------------------------------------------------------------//
//================ MODULE PARAMETERS,INPUTS AND OUTPUTS ================//
//----------------------------------------------------------------------//
module ekorv32_core_control_unit (
    input clk_i,
    input rst_i,

    // ALU Control
    input alu_busy_i,
    input [`RVLENM1:`RVLEN0] alu_result_i,
    input alu_branch_int_i,
    input alu_rd_we_i,
    output alu_en_o,

    // Instruction Decoder Control
    input [`ALU_OP:`RVLEN0] id_alu_op_i,
    input [`MEM_OP:`RVLEN0] id_mem_op_i,
    output [`RVLENM1:`RVLEN0] id_inst_data_o,
    output id_decode_en_o,

    // Memory Control
    input mem_ctrl_ready_i,
    input mem_ctrl_data_ready_i,
    input [`RVLENM1:`RVLEN0] mem_ctrl_data_i,
    output [`RVLENM1:`RVLEN0] mem_ctrl_addr_o,
    output mem_ctrl_we_o,
    output mem_ctrl_execute_o,
    output [`MEM_CTRL1:`MEM_CTRL0] mem_ctrl_byte_en_o,
    output mem_ctrl_sign_extend_o,
    output [`RVLENM1:`RVLEN0] mem_ctrl_data_o,

    // PC Control
    input [`RVLENM1:`RVLEN0] pc_i,
    output [`PC_OP_LENM:`PC_OP_LENL] pc_op_o,

    // Register File Control
    input [`RVLENM1:`RVLEN0] rf_rs_data_i,
    output rf_rd_wb_en_o,
    output rf_en_o,
    output [`RVLENM1:`RVLEN0] rf_rd_data_o
);
//----------------------------------------------------------------------//
//============================ LOCALPARAMS =============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================= REGISTERS ==============================//
//----------------------------------------------------------------------//
    reg [`MEM_CTRL1:`MEM_CTRL0] mem_cycle_cnt_reg;
    reg mem_ctrl_execute_reg;
    reg [`RVLENM1:`RVLEN0] inst_decoder_data_reg;
    reg alu_en_reg;
    reg memory_en_reg;
    reg decode_en_reg;
    reg pc_en_reg;
    reg wbe_reg;
    reg [`A1:`A0] alu_cycle_reg;
//----------------------------------------------------------------------//
//=============================== WIRES ================================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//=========================== STATE MACHINE ============================//
//----------------------------------------------------------------------//
    reg [`A2:`A0] state_reg = `INSTRUCTION_FETCH;
//----------------------------------------------------------------------//
//=========================== INSTANTIATIONS ===========================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================== PROCESS ===============================//
//----------------------------------------------------------------------//
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            alu_en_reg <= `RV1B0;
            memory_en_reg <= `RV1B0;
            mem_ctrl_execute_reg <= `RV1B0;
            decode_en_reg <= `RV1B0;
            pc_en_reg <= `RV1B0;
            wbe_reg <= `RV1B0;
            alu_cycle_reg <= `A0;
            inst_decoder_data_reg <= `A0;
            mem_cycle_cnt_reg <= `A0;
        end else begin
            case(state_reg)
            `INSTRUCTION_FETCH: begin
                wbe_reg <= `RV1B0;
                pc_en_reg <= `RV1B0;
                if(mem_ctrl_ready_i && (mem_cycle_cnt_reg == `A0)) begin
                    mem_ctrl_execute_reg <= `RV1B1;
                    mem_cycle_cnt_reg <= `A1;
                end else if (mem_cycle_cnt_reg == `A1) begin
                    mem_ctrl_execute_reg <= `RV1B0;
                    mem_cycle_cnt_reg <= `A2;
                end else if (mem_cycle_cnt_reg == `A2) begin
                    if(mem_ctrl_data_ready_i) begin
                        mem_cycle_cnt_reg <= `A0;
                        inst_decoder_data_reg <= mem_ctrl_data_i;
                        state_reg <= `INSTRUCTION_DECODE;
                    end
                end
            end
            `INSTRUCTION_DECODE: begin
                if(mem_cycle_cnt_reg == `A0) begin
                    decode_en_reg <= `RV1B1;
                    mem_cycle_cnt_reg <= `A1;
                end else if (mem_cycle_cnt_reg == `A1) begin
                    state_reg <= `EXECUTE;
                    mem_cycle_cnt_reg <= `A0;
                end
            end
            `EXECUTE: begin
                decode_en_reg <= `RV1B0;
                if(alu_cycle_reg == `A0) begin
                    alu_cycle_reg <= `A1;
                    alu_en_reg <= `RV1B1;
                end else if (alu_cycle_reg == `A1) begin
                    alu_cycle_reg <= `A2;
                end else if (alu_cycle_reg == `A2) begin
                    if(alu_busy_i == `RV1B0) begin
                        alu_cycle_reg <= `A0;
                        if((id_alu_op_i[`ALU_OP:`ALU_OPLP2] == `OPCODE_STORE) || (id_alu_op_i[`ALU_OP:`ALU_OPLP2] == `OPCODE_LOAD)) begin
                            state_reg <= `MEMORY;
                        end else begin
                            state_reg <= `WRITEBACK;
                        end
                    end
                end
            end
            `MEMORY: begin
                alu_en_reg <= `RV1B0;
                if(mem_ctrl_ready_i && (mem_cycle_cnt_reg == `A0)) begin
                    memory_en_reg <= `RV1B1;
                    mem_ctrl_execute_reg <= `RV1B1;
                    mem_cycle_cnt_reg <= `A1;
                end else if (mem_cycle_cnt_reg == `A1) begin
                    mem_ctrl_execute_reg <= `RV1B0;
                    if(id_alu_op_i[`ALU_OP:`ALU_OPLP2] == `OPCODE_STORE) begin
                        mem_cycle_cnt_reg <= `A0;
                        state_reg <= `WRITEBACK;
                    end else begin
                        if(mem_ctrl_data_ready_i == `RV1B1) begin
                            mem_cycle_cnt_reg <= `A0;
                            state_reg <= `WRITEBACK;
                        end
                    end
                end
            end
            `WRITEBACK: begin
                alu_en_reg <= `RV1B0;
                wbe_reg <= `RV1B1;
                pc_en_reg <= `RV1B1;
                memory_en_reg <= `RV1B0;
                state_reg <= `INSTRUCTION_FETCH;
            end
            endcase
        end
    end
//----------------------------------------------------------------------//
//============================== ASSIGNS ===============================//
//----------------------------------------------------------------------//

    // Register File Control
    assign rf_rd_wb_en_o = wbe_reg & alu_rd_we_i;
    assign rf_en_o = decode_en_reg | wbe_reg;
    assign rf_rd_data_o = (id_mem_op_i[`MEM_CTRL4:`MEM_CTRL3] == `MEM_CTRL_SE) ? mem_ctrl_data_i : (id_alu_op_i[`ALU_OP:`ALU_OPLP2] == `OPCODE_STORE) ? rf_rs_data_i : alu_result_i;

    // Program Counter Unit Control
    assign pc_op_o = (alu_branch_int_i && pc_en_reg) ? `PC_OP_ASSIGN : (!alu_branch_int_i && pc_en_reg) ? `PC_OP_INC : `PC_OP_NO_OP;

    // Memory Controller Control
    assign mem_ctrl_addr_o = memory_en_reg ? alu_result_i : pc_i;
    assign mem_ctrl_byte_en_o = memory_en_reg ? id_mem_op_i[`MEM_CTRL1:`MEM_CTRL0] : `MEM_CTRL_BE;
    assign mem_ctrl_sign_extend_o = ~id_mem_op_i[`MEM_CTRL2];
    assign mem_ctrl_execute_o = mem_ctrl_execute_reg;
    assign mem_ctrl_data_o = rf_rs_data_i;
    assign mem_ctrl_we_o = memory_en_reg && (id_mem_op_i[`MEM_CTRL4:`MEM_CTRL3] == `MEM_CTRL_WE) ? `RV1B1 : `RV1B0;

    // Instruction Decoder Control
    assign id_inst_data_o = inst_decoder_data_reg;
    assign id_decode_en_o = decode_en_reg;

    // ALU Control
    assign alu_en_o = alu_en_reg;

endmodule
//----------------------------------------------------------------------//
//=============================== NOTES ================================//
//----------------------------------------------------------------------//

//####################################################################################################################################//