//####################################################################################################################################//
//  Module Name  : ekorv32_core_alu_rv32im_unit
//  Project      : EkoRV-32
//  Author       : Ekin Akyildirim
//  Change Log   : 07.06.2025 | E.Akyildirim | v1.0
//  Description  : EkoRV-32 Core Arithmetic Logic Unit.
//####################################################################################################################################//

//----------------------------------------------------------------------//
//============================== INCLUDES ==============================//
//----------------------------------------------------------------------//
`include "ekorv32_defines.vh"

//----------------------------------------------------------------------//
//================ MODULE PARAMETERS,INPUTS AND OUTPUTS ================//
//----------------------------------------------------------------------//
module ekorv32_core_alu_rv32im_unit (
    input clk_i,
    input rst_i,
    input en_i,
    input [`RVLENM1:`RVLEN0] data_rs1_i,
    input [`RVLENM1:`RVLEN0] data_rs2_i,
    input rd_we_i,
    input [`ALU_OPM2:`RVLEN0] alu_op_i,
    input [`ALU_FUNC:`RVLEN0] alu_func_i,
    input [`RVLENM1:`RVLEN0] pc_i,
    input [`RVLENM1:`RVLEN0] imm_i,
    output [`RVLENM1:`RVLEN0] rv32_result_o,
    output [`RVLENM1:`RVLEN0] branch_trg_o,
    output rd_we_o,
    output busy_o,
    output [`RVLENM1:`RVLEN0] lpc_o,
    output branch_int_o
);
//----------------------------------------------------------------------//
//============================ LOCALPARAMS =============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================= REGISTERS ==============================//
//----------------------------------------------------------------------//

    reg [`RVLENM1:`RVLEN0] branch_trg_reg;
    reg branch_int_reg;
    reg rd_we_reg;
    reg lpc_reg;
    reg busy_reg;
    reg [`RVLEN2M1:`RVLEN0] rv64_result_reg;

    reg [`RVLEN2M1:`RVLEN0] rv64_uresult_reg;
    reg [`RVLEN2M1:`RVLEN0] rv64_sresult_reg;

    reg div_en_reg;
    reg [`RVLENM1:`RVLEN0] div_divd_reg;
    reg [`RVLENM1:`RVLEN0] div_divr_reg;
    reg [`A1:`A0] div_delay_reg;

    reg mul_en_reg;
    reg [`RVLENM1:`RVLEN0] mul_mul1_reg;
    reg [`RVLENM1:`RVLEN0] mul_mul2_reg;
    reg [`A1:`A0] mul_delay_reg;

//----------------------------------------------------------------------//
//=============================== WIRES ================================//
//----------------------------------------------------------------------//

    wire [`RVLENM1:`RVLEN0] div_sres_w;
    wire [`RVLENM1:`RVLEN0] div_srem_w;
    wire [`RVLENM1:`RVLEN0] div_ures_w;
    wire [`RVLENM1:`RVLEN0] div_urem_w;
    wire div_done_w;
    wire div_div_by_zero_int_w;

    wire [`RVLEN2M1:`RVLEN0] mul_sres_w;
    wire [`RVLEN2M1:`RVLEN0] mul_ures_w;
    wire mul_done_w;
//----------------------------------------------------------------------//
//=========================== STATE MACHINE ============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//=========================== INSTANTIATIONS ===========================//
//----------------------------------------------------------------------//
    ekorv32_core_alu_div32_unit ekorv32_core_alu_div32_unit(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(div_en_reg),
        .divd_i(div_divd_reg),
        .divr_i(div_divr_reg),
        .sres_o(div_sres_w),
        .srem_o(div_srem_w),
        .ures_o(div_ures_w),
        .urem_o(div_urem_w),
        .done_o(div_done_w),
        .div_by_zero_int_o(div_div_by_zero_int_w)
    );

    ekorv32_core_alu_mul32_unit ekorv32_core_alu_mul32_unit(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(mul_en_reg),
        .mul1_i(mul_mul1_reg),
        .mul2_i(mul_mul2_reg),
        .sres_o(mul_sres_w),
        .ures_o(mul_ures_w),
        .done_o(mul_done_w)
    );

//--------------------)--------------------------------------------------//
//============================== PROCESS ===============================//
//----------------------------------------------------------------------//

    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            div_en_reg <= `RV1B0;
            div_divd_reg <= `A0;
            div_divr_reg <= `A0;
            mul_en_reg <= `RV1B0;
            mul_mul1_reg <= `A0;
            mul_mul2_reg <= `A0;
            lpc_reg <= `RV1B0;
            branch_int_reg <= `RV1B0;
            branch_trg_reg <= `A0;
            rv64_sresult_reg <= `A0;
            rv64_uresult_reg <= `A0;
            rv64_result_reg <= `A0;
            mul_delay_reg <= `A0;
            div_delay_reg <= `A0;
            busy_reg <= `RV1B0;
            rd_we_reg <= `RV1B0;
        end else begin
            if(en_i == `RV1B1) begin
                lpc_reg <= pc_i;
                rd_we_reg <= rd_we_i;
                case (alu_op_i)
                    `OPCODE_OP_IMM: begin
                        busy_reg <= `RV1B0;
                        branch_int_reg <= `RV1B0;
                        case(alu_func_i[`ALU_FUNC3_MSB:`ALU_FUNC3_LSB])
                            `F3_OPIMM_ADDI: begin
                                rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(data_rs1_i) + $signed(imm_i);
                            end
                            `F3_OPIMM_ANDI: begin
                                rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i & imm_i;
                            end
                            `F3_OPIMM_ORI: begin
                                rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i | imm_i;
                            end
                            `F3_OPIMM_XORI: begin
                                rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i ^ imm_i;
                            end
                            `F3_OPIMM_SLTI: begin
                                if ($signed(data_rs1_i) < $signed(imm_i)) begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= `A1;
                                end else begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= `A0;
                                end
                            end
                              `F3_OPIMM_SLTIU: begin
                                if (data_rs1_i < imm_i) begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= `A1;
                                end else begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= `A0;
                                end
                            end
                            `F3_OPIMM_SRLI: begin
                                case(alu_func_i[`ALU_FUNC7_MSB:`ALU_FUNC7_LSB])
                                    `F7_OPIMM_SRLI: begin
                                         rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i >> imm_i[`A4:`A0];
                                    end
                                    `F7_OPIMM_SRAI: begin
                                        rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(data_rs1_i) >>> imm_i[`A4:`A0];
                                    end
                                endcase
                            end
                            `F3_OPIMM_SLLI: begin
                                rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i << imm_i[`A4:`A0];
                            end
                        endcase
                    end
                    `OPCODE_OP: begin
                        branch_int_reg <= `RV1B0;
                        if(alu_func_i[`ALU_FUNC7_MSB:`ALU_FUNC7_LSB] == `F7_OP_M_EXT) begin
                            if(alu_func_i[`ALU_FUNC3_MSB] == `RV1B0) begin
                                if(mul_delay_reg == `A0) begin
                                    busy_reg <= `RV1B1;
                                    mul_mul1_reg <= data_rs1_i;
                                    mul_mul2_reg <= data_rs2_i;
                                    mul_en_reg <= `RV1B1;
                                    mul_delay_reg <= mul_delay_reg + `A1;
                                end else if (mul_delay_reg == `A1) begin
                                    mul_en_reg <= `RV1B0;
                                    mul_delay_reg <= mul_delay_reg + `A1;
                                end else if (mul_delay_reg == `A2) begin
                                    if(mul_done_w == `RV1B1) begin
                                        rv64_sresult_reg <= mul_sres_w;
                                        rv64_uresult_reg <= mul_ures_w;
                                        mul_delay_reg <= mul_delay_reg + `A1;
                                    end
                                end else begin
                                    if(alu_func_i[`ALU_FUNC3_MSB:`ALU_FUNC3_LSB] == `F3_OP_M_MUL) begin
                                        rv64_result_reg[`RVLENM1:`RVLEN0] <= rv64_sresult_reg[`RVLENM1:`RVLEN0];
                                    end else if (alu_func_i[`ALU_FUNC3_MSB:`ALU_FUNC3_LSB] == `F3_OP_M_MULH) begin
                                        rv64_result_reg[`RVLENM1:`RVLEN0] <= rv64_uresult_reg[`RVLEN2M1:`RVLEN];
                                    end else if (alu_func_i[`ALU_FUNC3_MSB:`ALU_FUNC3_LSB] == `F3_OP_M_MULHU) begin
                                        rv64_result_reg[`RVLENM1:`RVLEN0] <= mul_ures_w[`RVLEN2M1:`RVLEN];
                                    end else begin
                                        rv64_result_reg[`RVLENM1:`RVLEN0] <= rv64_sresult_reg[`RVLEN2M1:`RVLEN];
                                    end
                                    mul_delay_reg <= `A0;
                                    busy_reg <= `RV1B0;
                                end
                            end else begin
                                if(div_delay_reg == `A0) begin
                                    busy_reg <= `RV1B1;
                                    div_divd_reg <= data_rs1_i;
                                    div_divr_reg <= data_rs2_i;
                                    div_en_reg <= `RV1B1;
                                    div_delay_reg <= div_delay_reg + `A1;
                                end else if (div_delay_reg == `A1) begin
                                    div_en_reg <= `RV1B0;
                                    div_delay_reg <= div_delay_reg + `A1;
                                end else if (div_delay_reg == `A2) begin
                                    if((div_done_w == `RV1B1) && (div_div_by_zero_int_w == `RV1B0)) begin
                                        rv64_sresult_reg[`RVLENM1:`RVLEN0] <= div_sres_w;
                                        rv64_uresult_reg[`RVLENM1:`RVLEN0] <= div_ures_w;
                                        rv64_sresult_reg[`RVLEN2M1:`RVLEN] <= div_srem_w;
                                        rv64_uresult_reg[`RVLEN2M1:`RVLEN] <= div_urem_w;
                                        div_delay_reg <= div_delay_reg + `A1;
                                    end else if ((div_done_w == `RV1B1) && (div_div_by_zero_int_w == `RV1B1)) begin
                                        rv64_sresult_reg <= `A0;
                                        rv64_uresult_reg <= `A0;
                                        div_delay_reg <= div_delay_reg + `A1;
                                    end
                                end else begin
                                    if(alu_func_i[`ALU_FUNC3_MSB:`ALU_FUNC3_LSB] == `F3_OP_M_DIV) begin
                                        rv64_result_reg[`RVLENM1:`RVLEN0] <= rv64_uresult_reg[`RVLENM1:`RVLEN0];
                                    end else if (alu_func_i[`ALU_FUNC3_MSB:`ALU_FUNC3_LSB] == `F3_OP_M_DIVU) begin
                                        rv64_result_reg[`RVLENM1:`RVLEN0] <= rv64_uresult_reg[`RVLENM1:`RVLEN0];
                                    end else if (alu_func_i[`ALU_FUNC3_MSB:`ALU_FUNC3_LSB] == `F3_OP_M_REM) begin
                                        rv64_result_reg[`RVLENM1:`RVLEN0] <= rv64_uresult_reg[`RVLEN2M1:`RVLEN];
                                    end else if (alu_func_i[`ALU_FUNC3_MSB:`ALU_FUNC3_LSB] == `F3_OP_M_REMU) begin
                                        rv64_result_reg[`RVLENM1:`RVLEN0] <= rv64_uresult_reg[`RVLEN2M1:`RVLEN];
                                    end
                                    div_delay_reg <= `A0;
                                    busy_reg <= `RV1B0;
                                end
                            end
                        end else begin
                            busy_reg <= `RV1B0;
                            case (alu_func_i[`ALU_FUNC7_MSB:`ALU_FUNC3_LSB])
                                {`F7_OP_ADD, `F3_OP_ADD}: begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(data_rs1_i) + $signed(data_rs2_i);
                                end
                                {`F7_OP_SUB, `F3_OP_SUB}: begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(data_rs1_i) - $signed(data_rs2_i);
                                end
                                {`F7_OP_SLT, `F3_OP_SLT}: begin
                                    if ($signed(data_rs1_i) < $signed(data_rs2_i)) begin
                                        rv64_result_reg <= `A1;
                                    end else begin
                                        rv64_result_reg <= `A0;
                                    end
                                end
                                {`F7_OP_SLTU, `F3_OP_SLTU}: begin
                                    if (data_rs1_i < data_rs2_i) begin
                                        rv64_result_reg <= `A1;
                                    end else begin
                                        rv64_result_reg <= `A0;
                                    end
                                end
                                {`F7_OP_OR, `F3_OP_OR}: begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i | data_rs2_i;
                                end
                                {`F7_OP_AND, `F3_OP_AND}: begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i & data_rs2_i;
                                end
                                {`F7_OP_XOR, `F3_OP_XOR}: begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i ^ data_rs2_i;
                                end
                                {`F7_OP_SLL, `F3_OP_SLL}: begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i << data_rs2_i[4:0];
                                end
                                {`F7_OP_SRL, `F3_OP_SRL}: begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= data_rs1_i >> data_rs2_i[4:0];
                                end
                                {`F7_OP_SRA, `F3_OP_SRA}: begin
                                    rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(data_rs1_i) >>> data_rs2_i[4:0];
                                end
                            endcase
                        end
                    end
                    `OPCODE_LOAD: begin
                        branch_int_reg <= `RV1B0;
                        busy_reg <= `RV1B0;
                        rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(data_rs1_i) + $signed(imm_i);
                    end
                    `OPCODE_STORE: begin
                        branch_int_reg <= `RV1B0;
                        busy_reg <= `RV1B0;
                        rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(data_rs1_i) + $signed(imm_i);
                    end
                    `OPCODE_JALR: begin
                        branch_trg_reg[`RVLENM1:`RVLEN0] <= ($signed(data_rs1_i) + $signed(imm_i)) & `ALU_JALR_SPEC;
                        branch_int_reg <= `RV1B1;
                        busy_reg <= `RV1B0;
                        rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(pc_i) + `PC_ADD;
                    end
                    `OPCODE_JAL: begin
                        branch_trg_reg[`RVLENM1:`RVLEN0] <= $signed(pc_i) + $signed(imm_i);
                        branch_int_reg <= `RV1B1;
                        busy_reg <= `RV1B0;
                        rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(pc_i) + `PC_ADD;
                    end
                    `OPCODE_BRANCH: begin
                        busy_reg <= `RV1B0;
                        case(alu_func_i[`ALU_FUNC3_MSB:`ALU_FUNC3_LSB])
                            `F3_BRANCH_BEQ: begin
                                if (data_rs1_i == data_rs2_i) begin
                                    branch_int_reg <= `RV1B1;
                                end else begin
                                    branch_int_reg <= `RV1B0;
                                end
                            end
                            `F3_BRANCH_BGE: begin
                                if ($signed(data_rs1_i) >= $signed(data_rs2_i)) begin
                                    branch_int_reg <= `RV1B1;
                                end else begin
                                    branch_int_reg <= `RV1B0;
                                end
                            end
                            `F3_BRANCH_BGEU: begin
                                if (data_rs1_i >= data_rs2_i) begin
                                    branch_int_reg <= `RV1B1;
                                end else begin
                                    branch_int_reg <= `RV1B0;
                                end
                            end
                            `F3_BRANCH_BLT: begin
                                if ($signed(data_rs1_i) < $signed(data_rs2_i)) begin
                                    branch_int_reg <= `RV1B1;
                                end else begin
                                    branch_int_reg <= `RV1B0;
                                end
                            end
                            `F3_BRANCH_BLTU: begin
                                if (data_rs1_i < data_rs2_i) begin
                                    branch_int_reg <= `RV1B1;
                                end else begin
                                    branch_int_reg <= `RV1B0;
                                end
                            end
                            `F3_BRANCH_BNE: begin
                                if (data_rs1_i != data_rs2_i) begin
                                    branch_int_reg <= `RV1B1;
                                end else begin
                                    branch_int_reg <= `RV1B0;
                                end
                            end
                        endcase
                    end
                    `OPCODE_LUI: begin
                        branch_int_reg <= `RV1B0;
                        busy_reg <= `RV1B0;
                        rv64_result_reg[`RVLENM1:`RVLEN0] <= imm_i;
                    end
                    `OPCODE_AUIPC: begin
                        branch_int_reg <= `RV1B0;
                        busy_reg <= `RV1B0;
                        rv64_result_reg[`RVLENM1:`RVLEN0] <= $signed(pc_i) + $signed(imm_i);
                    end
                    `OPCODE_SYSTEM: begin
                        // TODO!
                    end
                endcase
            end
        end
    end

//----------------------------------------------------------------------//
//============================== ASSIGNS ===============================//
//----------------------------------------------------------------------//

    assign rv32_result_o = rv64_result_reg[`RVLENM1:`RVLEN0];
    assign branch_int_o = branch_int_reg;
    assign branch_trg_o = branch_trg_reg[`RVLENM1:`RVLEN0];
    assign busy_o = busy_reg;
    assign lpc_o = lpc_reg;
    assign rd_we_o = rd_we_reg;

endmodule
//----------------------------------------------------------------------//
//=============================== NOTES ================================//
//----------------------------------------------------------------------//

//####################################################################################################################################//