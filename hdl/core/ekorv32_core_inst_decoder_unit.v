//####################################################################################################################################//
//  Module Name  : ekorv32_core_inst_decoder_unit.v
//  Project      : EkoRV-32 
//  Author       : Ekin Akyildirim
//  Change Log   : 07.06.2025 | E.Akyildirim | v1.0
//  Description  : EkoRV-32 Core Instruction Decoder unit.
//####################################################################################################################################//

//----------------------------------------------------------------------//
//============================== INCLUDES ==============================//
//----------------------------------------------------------------------//
`include "ekorv32_defines.vh"

//----------------------------------------------------------------------//
//================ MODULE PARAMETERS,INPUTS AND OUTPUTS ================//
//----------------------------------------------------------------------//
module ekorv32_core_inst_decoder_unit (
    input clk_i,
    input rst_i,
    input en_i,
    input [`RVLENM1:`RVLEN0] inst_i,
    output [`SELECTION:`RVLEN0] sel_rs1_o,
    output [`SELECTION:`RVLEN0] sel_rs2_o,
    output [`SELECTION:`RVLEN0] sel_rd_o,
    output [`RVLENM1:`RVLEN0] imm_o,
    output rd_we_o,
    output [`ALU_OP:`RVLEN0] alu_op_o,
    output [`ALU_FUNC:`RVLEN0] alu_func_o,
    output [`MEM_OP:`RVLEN0] mem_op_o
    // TODO!
);
//----------------------------------------------------------------------//
//============================ LOCALPARAMS =============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================= REGISTERS ==============================//
//----------------------------------------------------------------------//
    reg [`SELECTION:`RVLEN0] sel_rs1_reg;
    reg [`SELECTION:`RVLEN0] sel_rs2_reg;
    reg [`SELECTION:`RVLEN0] sel_rd_reg;
    reg [`RVLENM1:`RVLEN0] imm_reg;
    reg rd_we_reg;
    reg [`ALU_OP:`RVLEN0] alu_op_reg;
    reg [`ALU_FUNC:`RVLEN0] alu_func_reg;
    reg [`MEM_OP:`RVLEN0] mem_op_reg;
//----------------------------------------------------------------------//
//=============================== WIRES ================================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//=========================== STATE MACHINE ============================//
//----------------------------------------------------------------------//
  
//----------------------------------------------------------------------//
//=========================== INSTANTIATIONS ===========================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================== PROCESS ===============================//
//----------------------------------------------------------------------//
always @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        sel_rs1_reg <= `A0;
        sel_rs2_reg <= `A0;
        sel_rd_reg  <= `A0;
        imm_reg  <= `A0;
        alu_op_reg  <= `A0;
        alu_func_reg  <= `A0;
        mem_op_reg  <= `A0;
        rd_we_reg <= `RV1B0;
    end else begin
        if(en_i) begin
            sel_rd_reg <= inst_i[`RD_MSB:`RD_LSB];
            sel_rs1_reg <= inst_i[`RS1_MSB:`RS1_LSB];
            sel_rs2_reg <= inst_i[`RS2_MSB:`RS2_LSB];
            alu_op_reg <= inst_i[`OPCODE_MSB:`OPCODE_LSB];
            alu_func_reg <= {`RV6B0, inst_i[`FUNC7_MSB:`FUNC7_LSB], inst_i[`FUNC3_MSB:`FUNC3_LSB]};
        case(inst_i[`OPCODE_MSB:`OPCODE_LSBP2])
            `OPCODE_LUI: begin
                rd_we_reg <= `RV1B1;
                mem_op_reg <= `A0;
                imm_reg <= {inst_i[`IMM_XU_MSB:`IMM_XU_LSB], `RV12B0};
            end
            `OPCODE_AUIPC: begin
                rd_we_reg <= `RV1B1;
                mem_op_reg <= `A0;
                imm_reg <= {inst_i[`IMM_XU_MSB:`IMM_XU_LSB], `RV12B0};
            end
            `OPCODE_JAL: begin
                mem_op_reg <= `A0;
                if(inst_i[`RD_MSB:`RD_LSB] == `A0) begin
                    rd_we_reg <= `RV1B0;
                end else begin
                    rd_we_reg <= `RV1B1;
                end
                if (inst_i[`IMM_XU_MSB] == `A1) begin
                    imm_reg <= {`RV12B1, inst_i[`IMM_JAL_MMSB:`IMM_JAL_MLSB], inst_i[`IMM_JAL_MB], inst_i[`IMM_JAL_LMSB:`IMM_JAL_LLSB], `RV1B0};
                end else begin
                    imm_reg <= {`RV12B0, inst_i[`IMM_JAL_MMSB:`IMM_JAL_MLSB], inst_i[`IMM_JAL_MB], inst_i[`IMM_JAL_LMSB:`IMM_JAL_LLSB], `RV1B0};
                end
            end
            `OPCODE_JALR: begin
                mem_op_reg <= `A0;
                if(inst_i[`RD_MSB:`RD_LSB] == `A0) begin
                    rd_we_reg <= `RV1B0;
                end else begin
                    rd_we_reg <= `RV1B1;
                end
                if (inst_i[`IMM_XU_MSB] == `A1) begin
                    imm_reg <= {`RV16B1, `RV4B1, inst_i[`IMM_XI_MSB:`IMM_XI_LSB]};
                end else begin
                    imm_reg <= {`RV16B0, `RV4B0, inst_i[`IMM_XI_MSB:`IMM_XI_LSB]};
                end
            end
            `OPCODE_OP_IMM: begin
                rd_we_reg <= `RV1B1;
                mem_op_reg <= `A0;
                if(inst_i[`IMM_XU_MSB] == `RV1B1) begin
                    imm_reg <= {`RV16B1, `RV4B1, inst_i[`IMM_XI_MSB:`IMM_XI_LSB]};
                end else begin
                    imm_reg <= {`RV16B0, `RV4B0, inst_i[`IMM_XI_MSB:`IMM_XI_LSB]};
                end
            end
            `OPCODE_OP: begin
                rd_we_reg <= `RV1B1;
                mem_op_reg <= `A0;
            end
            `OPCODE_LOAD: begin
                if(inst_i[`A1:`A0] == `RV2B1) begin
                    rd_we_reg <= `RV1B1;
                    mem_op_reg <= {`RV1B1, `RV1B0, inst_i[`FUNC3_MSB:`FUNC3_LSB]};
                    if(inst_i[`IMM_XU_MSB] == `RV1B1) begin
                        imm_reg <= {`RV16B1, `RV4B1, inst_i[`IMM_XI_MSB:`IMM_XI_LSB]};
                    end else begin
                        imm_reg <= {`RV16B0, `RV4B0, inst_i[`IMM_XI_MSB:`IMM_XI_LSB]};
                    end
                end else begin
                    mem_op_reg <= `A0;
                    rd_we_reg <= `RV1B0;
                    imm_reg <= {inst_i[`IMM_XI_MSB:`IMM_SXL_LSB], `RV7B0};
                end
            end
            `OPCODE_STORE: begin
                rd_we_reg <= `RV1B0;
                mem_op_reg <= {`RV2B1, inst_i[`FUNC3_MSB:`FUNC3_LSB]};
                if(inst_i[`IMM_XU_MSB] == `RV1B1) begin
                    imm_reg <= {`RV16B1, `RV4B1, inst_i[`IMM_SXM_MSB:`IMM_SXM_LSB], inst_i[`IMM_SXL_MSB:`IMM_SXL_LSB]};
                end else begin
                    imm_reg <= {`RV16B0, `RV4B0, inst_i[`IMM_SXM_MSB:`IMM_SXM_LSB], inst_i[`IMM_SXL_MSB:`IMM_SXL_LSB]};
                end
            end
            `OPCODE_BRANCH: begin
                rd_we_reg <= `RV1B0;
                mem_op_reg <= `A0;
                if(inst_i[`IMM_XU_MSB] == `RV1B1) begin
                    imm_reg <= {`RV16B1, `RV4B1, inst_i[`IMM_BRANCH_7], inst_i[`IMM_BRANCH_MMSB:`IMM_BRANCH_MLSB], inst_i[`IMM_BRANCH_LMSB:`IMM_BRANCH_LLSB], `RV1B0};
                end else begin
                    imm_reg <= {`RV16B0, `RV4B0, inst_i[`IMM_BRANCH_7], inst_i[`IMM_BRANCH_MMSB:`IMM_BRANCH_MLSB], inst_i[`IMM_BRANCH_LMSB:`IMM_BRANCH_LLSB], `RV1B0};
                end
            end
            `OPCODE_MISCMEM: begin
                rd_we_reg <= `RV1B0;
                mem_op_reg <= `A0;
                imm_reg <= inst_i;
            end
            `OPCODE_SYSTEM: begin
                //TODO!
            end
            default: begin
                mem_op_reg <= `A0;
                rd_we_reg <= `RV1B0;
                imm_reg <= {(inst_i[`IMM_XI_MSB:`IMM_SXL_LSB]), `RV7B1};
            end
        endcase
        end
    end
end
//----------------------------------------------------------------------//
//============================== ASSIGNS ===============================//
//----------------------------------------------------------------------//

    assign sel_rs1_o  = sel_rs1_reg;
    assign sel_rs2_o  = sel_rs2_reg;
    assign sel_rd_o   = sel_rd_reg;
    assign rd_we_o    = rd_we_reg;
    assign imm_o      = imm_reg;
    assign alu_func_o = alu_func_reg;
    assign alu_op_o   = alu_op_reg;
    assign mem_op_o   = mem_op_reg;

endmodule
//----------------------------------------------------------------------//
//=============================== NOTES ================================//
//----------------------------------------------------------------------//

//####################################################################################################################################//