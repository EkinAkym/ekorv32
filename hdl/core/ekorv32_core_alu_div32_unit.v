//####################################################################################################################################//
//  Module Name  : ekorv32_core_alu_div32_unit.v
//  Project      : EkoRV-32 
//  Author       : Ekin Akyildirim
//  Change Log   : 07.06.2025 | E.Akyildirim | v1.0
//  Description  : EkoRV-32 Core ALU 32-bit signed and unsigned divider unit.
//####################################################################################################################################//

//----------------------------------------------------------------------//
//============================== INCLUDES ==============================//
//----------------------------------------------------------------------//
`include "ekorv32_defines.vh"

//----------------------------------------------------------------------//
//================ MODULE PARAMETERS,INPUTS AND OUTPUTS ================//
//----------------------------------------------------------------------//
module ekorv32_core_alu_div32_unit (
    input clk_i,
    input rst_i,
    input en_i,
    input [`RVLENM1:`RVLEN0] divd_i, // dividend
    input [`RVLENM1:`RVLEN0] divr_i, // divisor
    output [`RVLENM1:`RVLEN0] sres_o, // signed result
    output [`RVLENM1:`RVLEN0] srem_o,  // signed remainder
    output [`RVLENM1:`RVLEN0] ures_o, // unsigned result
    output [`RVLENM1:`RVLEN0] urem_o, // unsigned remainder
    output done_o,
    output div_by_zero_int_o
);
//----------------------------------------------------------------------//
//============================ LOCALPARAMS =============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//============================= REGISTERS ==============================//
//----------------------------------------------------------------------//
    reg [`A5:`A0] cnt_reg;
    reg [`RVLEN2M1:`RVLEN0] udivd_reg, udivr_reg;
    reg [`RVLENM1:`RVLEN0] uquo_reg;
    reg [`RVLEN2M1:`RVLEN0] sdivd_reg, sdivr_reg;
    reg [`RVLENM1:`RVLEN0] squo_reg;
    reg smode_reg;
    reg busy_reg;
    reg divd_sign_reg, divr_sign_reg;
    reg [`RVLENM1:`RVLEN0] sres_reg;
    reg [`RVLENM1:`RVLEN0] srem_reg;
    reg [`RVLENM1:`RVLEN0] ures_reg;
    reg [`RVLENM1:`RVLEN0] urem_reg;
    reg div_by_zero_int_reg, done_reg;
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
        cnt_reg <= `A0;
        squo_reg <= `A0;
        srem_reg <= `A0;
        sres_reg <= `A0;
        uquo_reg <= `A0;
        urem_reg <= `A0;
        ures_reg <= `A0;
        div_by_zero_int_reg <= `RV1B0;
        done_reg <= `RV1B0;
        busy_reg <= `RV1B0;
    end else begin
        if(en_i && !busy_reg) begin
            done_reg <= `RV1B0;
            div_by_zero_int_reg <= `A0;
            cnt_reg <= `A0;
            busy_reg <= `RV1B1;
            if(divr_i == `A0) begin
                div_by_zero_int_reg <= `RV1B1;
                busy_reg <= `RV1B0;
                done_reg <= `RV1B1;
            end else begin
                udivd_reg <= {`RV32B0, divd_i};
                udivr_reg <= {divr_i, `RV32B0};
                uquo_reg  <= `A0;
                divd_sign_reg <= divd_i[`A31];
                divr_sign_reg <= divr_i[`A31];
                sdivd_reg <= {`RV32B0, divd_i[`A31] ? (~divd_i + `A1) : divd_i};
                sdivr_reg <= {divr_i[`A31] ? (~divr_i + `A1) : divr_i, `RV32B0};
            end
        end else if (busy_reg) begin
            if (cnt_reg < `A33) begin
                if(udivd_reg >= udivr_reg) begin
                    udivd_reg <= udivd_reg - udivr_reg;
                    uquo_reg  <=  (uquo_reg << `A1) | `RV1B1;
                end else begin
                    uquo_reg <= uquo_reg << `A1;
                end
                udivr_reg <= udivr_reg >> `A1;
                if(sdivd_reg >= sdivr_reg) begin
                    sdivd_reg <= sdivd_reg - sdivr_reg;
                    squo_reg <= (squo_reg << `A1) | `RV1B1;
                end else begin
                    squo_reg <= squo_reg << `A1;
                end
                sdivr_reg <= sdivr_reg >> `A1;
                cnt_reg <= cnt_reg + `A1;
            end else begin
                busy_reg <= `RV1B0;
                done_reg <= `RV1B1;
                ures_reg <= uquo_reg;
                urem_reg <= udivd_reg[`A31:`A0];
                sres_reg <= (divd_sign_reg ^ divr_sign_reg) ? (~squo_reg + `A1) : squo_reg;
                srem_reg <= divd_sign_reg ? (~sdivd_reg[`A31:`A0] + `A1) : sdivd_reg[`A31:`A0];
            end
        end else begin
            done_reg <= `RV1B0;
        end
    end
end
//----------------------------------------------------------------------//
//============================== ASSIGNS ===============================//
//----------------------------------------------------------------------//
    assign sres_o = sres_reg;
    assign srem_o = srem_reg;
    assign ures_o = ures_reg;
    assign urem_o = urem_reg;
    assign done_o = done_reg;
    assign div_by_zero_int_o = div_by_zero_int_reg;
endmodule
//----------------------------------------------------------------------//
//=============================== NOTES ================================//
//----------------------------------------------------------------------//

//####################################################################################################################################//