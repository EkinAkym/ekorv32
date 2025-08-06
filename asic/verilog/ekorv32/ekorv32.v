//####################################################################################################################################//
//  Module Name  : ekorv32.v
//  Project      : EkoRV-32 
//  Author       : Ekin Akyildirim
//  Change Log   : 07.06.2025 | E.Akyildirim | v1.0
//  Description  : EkoRV-32.
//####################################################################################################################################//

//----------------------------------------------------------------------//
//============================== INCLUDES ==============================//
//----------------------------------------------------------------------//
`include "ekorv32_defines.vh"

//----------------------------------------------------------------------//
//================ MODULE PARAMETERS,INPUTS AND OUTPUTS ================//
//----------------------------------------------------------------------//
module ekorv32 (
    input clk_i,
    input rst_i,
    output mem_en_o,
    output mem_we_o,
    output [`A11:`A0] mem_addr_o,
    output [`RVLENM1:`RVLEN0] mem_data_o,
    input [`RVLENM1:`RVLEN0] mem_data_i,
    input mem_ready_i,
    input mem_data_ready_i
);
//----------------------------------------------------------------------//
//============================ LOCALPARAMS =============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================= REGISTERS ==============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//=============================== WIRES ================================//
//----------------------------------------------------------------------//

    // Wires between Arithmetic Logic Unit and Instruction Decoder //
        wire alu_rd_we_i_w;
        wire [`RVLENM1:`RVLEN0] imm_w;
        wire [`ALU_FUNC:`RVLEN0] alu_func_w;
        wire [`ALU_OP:`RVLEN0] alu_op_w;   // -> also, connected to the control unit.

    // Wires between Register File and Instruction Decoder //
        wire [`SELECTION:`RVLEN0] sel_rs1_w;
        wire [`SELECTION:`RVLEN0] sel_rs2_w;
        wire [`SELECTION:`RVLEN0] sel_rd_w;
    
    // Wires between Control Unit and Instruction Decoder //
        wire decode_en_w;
        wire [`RVLENM1:`RVLEN0] inst_w;
        wire [`MEM_OP:`RVLEN0] mem_op_w;

    // Wires between Arithmetic Logic Unit and Control Unit //
        wire alu_en_w;
        wire alu_busy_w;
        wire [`RVLENM1:`RVLEN0] rv32_result_w;
        wire alu_branch_int_o_w;
        wire alu_rd_we_o_w;
        wire [`RVLENM1:`RVLEN0] alu_lpc_w;

    // Wires between Arithmetic Logic Unit and Program Counter Unit //
        wire [`RVLENM1:`RVLEN0] pc_w;   // -> also, connected to the control unit.
        wire [`RVLENM1:`RVLEN0] alu_branch_trg_o_w;

    // Wires between Arithmetic Logic Unit and Register File //
        wire [`RVLENM1:`RVLEN0] data_rs1_w;
        wire [`RVLENM1:`RVLEN0] data_rs2_w; // -> also, connected to the control unit.

    // Wires between Program Counter Unit and Control Unit //
        wire [`PC_OP_LENM:`PC_OP_LENL] pc_op_w;
    
    // Wires between Register File and Control Unit //
        wire [`RVLENM1:`RVLEN0] rf_rd_data_w;
        wire rf_rd_wb_en_w;
        wire rf_en_w;

    // Wires between Memory Control Unit and Control Unit //
        wire mem_ctrl_ready_w;
        wire mem_ctrl_data_ready_w;
        wire [`RVLENM1:`RVLEN0] mem_ctrl_data_i_w;
        wire [`RVLENM1:`RVLEN0] mem_ctrl_data_o_w;
        wire [`RVLENM1:`RVLEN0] mem_ctrl_addr_w;
        wire mem_ctrl_execute_w;
        wire [`MEM_CTRL1:`MEM_CTRL0] mem_ctrl_byte_en_w;
        wire mem_ctrl_we_w;
        wire mem_ctrl_sign_extend_w;

    // Wires between Memory Control Unit and Memory //


//----------------------------------------------------------------------//
//=========================== STATE MACHINE ============================//
//----------------------------------------------------------------------//
  
//----------------------------------------------------------------------//
//=========================== INSTANTIATIONS ===========================//
//----------------------------------------------------------------------//
    ekorv32_core_alu_rv32im_unit ALU(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(alu_en_w),
        .data_rs1_i(data_rs1_w),
        .data_rs2_i(data_rs2_w),
        .rd_we_i(alu_rd_we_i_w),
        .alu_op_i(alu_op_w[`ALU_OP:`ALU_OPLP2]),
        .alu_func_i(alu_func_w),
        .pc_i(pc_w), 
        .imm_i(imm_w),
        .rv32_result_o(rv32_result_w),
        .branch_trg_o(alu_branch_trg_o_w),
        .rd_we_o(alu_rd_we_o_w),
        .busy_o(alu_busy_w),
        .lpc_o(alu_lpc_w),
        .branch_int_o(alu_branch_int_o_w)
    );
    ekorv32_core_inst_decoder_unit DECODER(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(decode_en_w),
        .inst_i(inst_w),
        .sel_rs1_o(sel_rs1_w),
        .sel_rs2_o(sel_rs2_w),
        .sel_rd_o(sel_rd_w),
        .imm_o(imm_w),
        .rd_we_o(alu_rd_we_i_w),
        .alu_op_o(alu_op_w),
        .alu_func_o(alu_func_w),
        .mem_op_o(mem_op_w)
    );
    ekorv32_core_control_unit CONTROL_UNIT(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .alu_busy_i(alu_busy_w),
        .alu_result_i(rv32_result_w),
        .alu_branch_int_i(alu_branch_int_o_w),
        .alu_rd_we_i(alu_rd_we_o_w),
        .alu_en_o(alu_en_w),
        .id_alu_op_i(alu_op_w),
        .id_mem_op_i(mem_op_w),
        .id_inst_data_o(inst_w),
        .id_decode_en_o(decode_en_w),
        .mem_ctrl_ready_i(mem_ctrl_ready_w),
        .mem_ctrl_data_ready_i(mem_ctrl_data_ready_w),
        .mem_ctrl_data_i(mem_ctrl_data_o_w),
        .mem_ctrl_addr_o(mem_ctrl_addr_w),
        .mem_ctrl_we_o(mem_ctrl_we_w),
        .mem_ctrl_execute_o(mem_ctrl_execute_w),
        .mem_ctrl_byte_en_o(mem_ctrl_byte_en_w),
        .mem_ctrl_sign_extend_o(mem_ctrl_sign_extend_w),
        .mem_ctrl_data_o(mem_ctrl_data_i_w),
        .pc_i(pc_w),
        .pc_op_o(pc_op_w),
        .rf_rs_data_i(data_rs2_w),
        .rf_rd_wb_en_o(rf_rd_wb_en_w),
        .rf_en_o(rf_en_w),
        .rf_rd_data_o(rf_rd_data_w)
    );
    ekorv32_core_pc_unit PC_UNIT(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .pc_op_i(pc_op_w),
        .branch_pc_i(alu_branch_trg_o_w),
        .pc_o(pc_w)
    );
    ekorv32_core_mem_ctrl_unit MEM_CTRL(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .mem_ctrl_addr_i(mem_ctrl_addr_w),
        .mem_ctrl_data_i(mem_ctrl_data_i_w),
        .mem_ctrl_byte_en_i(mem_ctrl_byte_en_w),
        .mem_ctrl_sign_extend_i(mem_ctrl_sign_extend_w),
        .mem_ctrl_execute_i(mem_ctrl_execute_w),
        .mem_ctrl_we_i(mem_ctrl_we_w),
        .mem_ctrl_data_ready_o(mem_ctrl_data_ready_w),
        .mem_ctrl_ready_o(mem_ctrl_ready_w),
        .mem_ctrl_data_o(mem_ctrl_data_o_w),
        .mem_data_i(mem_data_i),
        .mem_ready_i(mem_ready_i),
        .mem_data_ready_i(mem_data_ready_i),
        .mem_en_o(mem_en_o),
        .mem_we_o(mem_we_o),
        .mem_addr_o(mem_addr_o),
        .mem_data_o(mem_data_o)
    );
    ekorv32_core_register_unit REGISTER(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(rf_en_w),
        .data_i(rf_rd_data_w),
        .sel_rs1_i(sel_rs1_w),
        .sel_rs2_i(sel_rs2_w),
        .sel_rd_i(sel_rd_w),
        .we_i(rf_rd_wb_en_w),
        .data_rs1_o(data_rs1_w),
        .data_rs2_o(data_rs2_w)
    );
    /*ekorv32_memory MEMORY(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .mem_en_i(mem_en_w),
        .mem_we_i(mem_we_w),
        .mem_addr_i(mem_addr_w),
        .mem_data_i(mem_data_i_w),
        .mem_data_o(mem_data_o_w),
        .mem_ready_o(mem_ready_w),
        .mem_data_ready_o(mem_data_ready_w)
    );*/

    /* TODO!
        ekorv32_dma DMA(
        );
        ekorv32_perip_uart UART(
        );
        ekorv32_perip_i2c_master I2C(
        );
         ekorv32_perip_spi_master SPI(
        );
    */
//----------------------------------------------------------------------//
//============================== PROCESS ===============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================== ASSIGNS ===============================//
//----------------------------------------------------------------------//
//----------------------------------------------------------------------//
//=============================== NOTES ================================//
//----------------------------------------------------------------------//
endmodule
//####################################################################################################################################//