//####################################################################################################################################//
//  Module Name  : ekorv32_defines.vh
//  Project      : EkoRV-32 
//  Author       : Ekin Akyildirim
//  Change Log   : 15.08.2025 | E.Akyildirim | v1.1
//  Description  : EkoRV-32 Defines File
//####################################################################################################################################//

//----------------------------------------------------------------------//
//============================== DEFINES ===============================//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
//################################ MAIN ################################//
//----------------------------------------------------------------------//

`define CLOCK_FREQUENCY         (100_000_000)

`define MEM_DEPTH               (4096)

`define UART_BAUDRATE           (115_200)
`define UART_TX_STOPBIT         (2)

`define I2C_BUS_FREQUENCY       (400_000)

`define SPI_BUS_FREQUENCY       (1_000_000)
`define SPI_CLOCK_POLARIZATION  (0)
`define SPI_CLOCK_PHASE         (0)

//----------------------------------------------------------------------//
//############################### BASIC ################################//
//----------------------------------------------------------------------//
`define RVLEN       (32)
`define RVLEN2      (64)
//----------------------------------------------------------------------//
`define A0          (0)
`define A1          (1)
`define A2          (2)
`define A3          (3)
`define A4          (4)
`define A5          (5)
`define A6          (6)
`define A7          (7)
`define A8          (8)
`define A9          (9)
`define A10         (10)
`define A11         (11)
`define A12         (12)
`define A13         (13)
`define A14         (14)
`define A15         (15)
`define A16         (16)
`define A17         (17)
`define A18         (18)
`define A19         (19)
`define A20         (20)
`define A21         (21)
`define A22         (22)
`define A23         (23)
`define A24         (24)
`define A25         (25)
`define A26         (26)
`define A27         (27)
`define A28         (28)
`define A29         (29)
`define A30         (30)
`define A31         (31)
`define A32         (32)
`define A33         (33)
//----------------------------------------------------------------------//
`define RV1B0       (1'b0)
`define RV1B1       (1'b1)
`define RV2B0       (2'b00)
`define RV2B1       (2'b11)
`define RV3B0       (3'b000)
`define RV3B1       (3'b111)
`define RV4B0       (4'b0000)
`define RV4B1       (4'b1111)
`define RV5B0       (5'b00000)
`define RV5B1       (5'b11111)
`define RV6B0       (6'b000000)
`define RV6B1       (6'b111111)
`define RV7B0       (7'b0000000)
`define RV7B1       (7'b1111111)
`define RV12B0      (12'b000000000000)
`define RV12B1      (12'b111111111111)
`define RV16B0      (16'b0000000000000000)
`define RV16B1      (16'b1111111111111111)
`define RV32B0      (32'b00000000000000000000000000000000)
`define RV32B1      (32'b11111111111111111111111111111111)
//----------------------------------------------------------------------//
`define RVLEN0      (0)
`define BYTE3       (24)
`define BYTE2       (16)
`define BYTE2M1     (15)
`define BYTE1M1     (7)
`define BYTE1M2     (6)
`define BYTE1       (8)
`define BYTE0       (0)
`define RVLEN2M1    (`RVLEN2-1)
`define RVLENM1     (`RVLEN-1)

//----------------------------------------------------------------------//
//############################### RV-32 ################################//
//----------------------------------------------------------------------//

`define ADDR_RESET          (32'h0000_0000)
//----------------------------------------------------------------------//
`define OPCODE_MSB          (6)
`define OPCODE_LSB          (0)
`define OPCODE_LSBP2        (2)
`define FUNC3_MSB           (14)
`define FUNC3_LSB           (12)
`define FUNC7_MSB           (31)
`define FUNC7_LSB           (25)
`define RD_MSB              (11)
`define RD_LSB              (7)
`define RS1_MSB             (19)
`define RS1_LSB             (15)
`define RS2_MSB             (24)
`define RS2_LSB             (20)
`define IMM_XI_MSB          (31)
`define IMM_XI_LSB          (20)
`define IMM_XU_MSB          (31)
`define IMM_XU_LSB          (12)
`define IMM_SXM_MSB         (31)
`define IMM_SXM_LSB         (25)
`define IMM_SXL_MSB         (11)
`define IMM_SXL_LSB         (7)
`define IMM_JAL_MMSB        (19)
`define IMM_JAL_MLSB        (12)
`define IMM_JAL_MB          (20)
`define IMM_JAL_LMSB        (30)
`define IMM_JAL_LLSB        (21)
`define IMM_BRANCH_7        (7)
`define IMM_BRANCH_MMSB     (30)
`define IMM_BRANCH_MLSB     (25)
`define IMM_BRANCH_LMSB     (11)
`define IMM_BRANCH_LLSB     (8)
//----------------------------------------------------------------------//
`define ALU_FUNC3_LSB       (0)
`define ALU_FUNC3_MSB       (2)
`define ALU_FUNC7_LSB       (3)
`define ALU_FUNC7_MSB       (9)
`define ALU_OP              (6)
`define ALU_OPM2            (4)
`define ALU_OPLP2           (2)
`define ALU_FUNC            (15)
`define ALU_JALR_SPEC       (32'hFFFFFFFE)
//----------------------------------------------------------------------//
`define SELECTION           (4)
`define MEM_OP              (4)
//----------------------------------------------------------------------//
`define OPCODE_LOAD         (5'b00000)
`define OPCODE_STORE        (5'b01000)
`define OPCODE_BRANCH       (5'b11000)
`define OPCODE_JAL          (5'b11011)
`define OPCODE_JALR         (5'b11001)
`define OPCODE_JAL          (5'b11011)
`define OPCODE_OP           (5'b01100)
`define OPCODE_OP_IMM       (5'b00100)
`define OPCODE_SYSTEM       (5'b11100)
`define OPCODE_MISCMEM      (5'b00011)
`define OPCODE_AUIPC        (5'b00101)
`define OPCODE_LUI          (5'b01101)
//----------------------------------------------------------------------//
`define F3_BRANCH_BEQ       (3'b000)
`define F3_BRANCH_BNE       (3'b001)
`define F3_BRANCH_BLT       (3'b100)
`define F3_BRANCH_BGE       (3'b101)
`define F3_BRANCH_BLTU      (3'b110)
`define F3_BRANCH_BGEU      (3'b111)
//----------------------------------------------------------------------//
`define F3_JALR             (3'b000)
//----------------------------------------------------------------------//
`define F3_LOAD_LB          (3'b000)
`define F3_LOAD_LH          (3'b001)
`define F3_LOAD_LW          (3'b010)
`define F3_LOAD_LBU         (3'b100)
`define F3_LOAD_LHU         (3'b101)
//----------------------------------------------------------------------//
`define F3_STORE_SB         (3'b000)
`define F3_STORE_SH         (3'b001)
`define F3_STORE_SW         (3'b010)
//----------------------------------------------------------------------//
`define F3_OPIMM_ADDI       (3'b000)
`define F3_OPIMM_SLTI       (3'b010)
`define F3_OPIMM_SLTIU      (3'b011)
`define F3_OPIMM_XORI       (3'b100)
`define F3_OPIMM_ORI        (3'b110)
`define F3_OPIMM_ANDI       (3'b111)
`define F3_OPIMM_SLLI       (3'b001)
`define F3_OPIMM_SRLI       (3'b101)
`define F3_OPIMM_SRAI       (3'b101)
//----------------------------------------------------------------------//
`define F3_OP_ADD           (3'b000)
`define F3_OP_SUB           (3'b000)
`define F3_OP_SLL           (3'b001)
`define F3_OP_SLT           (3'b010)
`define F3_OP_SLTU          (3'b011)
`define F3_OP_XOR           (3'b100)
`define F3_OP_SRL           (3'b101)
`define F3_OP_SRA           (3'b101)
`define F3_OP_OR            (3'b110)
`define F3_OP_AND           (3'b111)
//----------------------------------------------------------------------//
`define F3_OP_M_MUL         (3'b000)
`define F3_OP_M_MULH        (3'b001)
`define F3_OP_M_MULHSU      (3'b010)
`define F3_OP_M_MULHU       (3'b011)
`define F3_OP_M_DIV         (3'b100)
`define F3_OP_M_DIVU        (3'b101)
`define F3_OP_M_REM         (3'b110)
`define F3_OP_M_REMU        (3'b111)
//----------------------------------------------------------------------//
`define F7_OPIMM_SLLI       (7'b0000000)
`define F7_OPIMM_SRLI       (7'b0000000)
`define F7_OPIMM_SRAI       (7'b0100000)
//----------------------------------------------------------------------//
`define F7_OP_ADD           (7'b0000000)
`define F7_OP_SUB           (7'b0100000)
`define F7_OP_SLL           (7'b0000000)
`define F7_OP_SLT           (7'b0000000)
`define F7_OP_SLTU          (7'b0000000)
`define F7_OP_XOR           (7'b0000000)
`define F7_OP_SRL           (7'b0000000)
`define F7_OP_SRA           (7'b0100000)
`define F7_OP_OR            (7'b0000000)
`define F7_OP_AND           (7'b0000000)
//----------------------------------------------------------------------//
`define F7_OP_M_EXT         (7'b0000001)
//----------------------------------------------------------------------//
`define PC_OP_RESET         (2'b00)
`define PC_OP_INC           (2'b01)
`define PC_OP_ASSIGN        (2'b10)
`define PC_OP_NO_OP         (2'b11)
`define PC_OP_LENM          (2)
`define PC_OP_LENL          (0)
`define PC_ADD              (4)
//----------------------------------------------------------------------//
`define MEM_IDLE            (0)
`define MEM_READ            (1)
`define MEM_WRITE           (2)
`define MEM_SIZE_W          (2'b10)
`define MEM_SIZE_H          (2'b01)
`define MEM_SIZE_B          (2'b00)
`define MEM_CTRL0           (0)
`define MEM_CTRL1           (1)
`define MEM_CTRL2           (2)
`define MEM_CTRL3           (3)
`define MEM_CTRL4           (4)
`define MEM_CTRL_SE         (2'b10)
`define MEM_CTRL_BE         (2'b10)
`define MEM_CTRL_WE         (2'b11)
`define MEM_DEPTHM1         (`MEM_DEPTH-1)
//----------------------------------------------------------------------//
`define INSTRUCTION_FETCH   (3'b000)
`define INSTRUCTION_DECODE  (3'b001)
`define EXECUTE             (3'b010)
`define MEMORY              (3'b011)
`define WRITEBACK           (3'b100)

//----------------------------------------------------------------------//
//################################ UART ################################//
//----------------------------------------------------------------------//

`define UART_TX_ST_IDLE     (2'b00)
`define UART_TX_ST_START    (2'b01)
`define UART_TX_ST_DATA     (2'b10)
`define UART_TX_ST_STOP     (2'b11)
//----------------------------------------------------------------------//
`define UART_RX_ST_IDLE     (2'b00)
`define UART_RX_ST_START    (2'b01)
`define UART_RX_ST_DATA     (2'b10)
`define UART_RX_ST_STOP     (2'b11)
//----------------------------------------------------------------------//
`define RX_START_COND       (1'b0)
`define TX_START_COND       (1'b0)
`define TX_STOP_COND        (1'b1)
`define RX_STOP_COND        (1'b1)

//----------------------------------------------------------------------//
//################################ I2C #################################//
//----------------------------------------------------------------------//
`define I2C_ST_IDLE         (3'b000)
`define I2C_ST_START        (3'b001)
`define I2C_ST_ADDR_INST    (3'b010)
`define I2C_ST_SLAVE_ACK    (3'b011)
`define I2C_ST_WRITE        (3'b100)
`define I2C_ST_READ         (3'b101)
`define I2C_ST_MASTER_ACK   (3'b110)
`define I2C_ST_STOP         (3'b111)
//----------------------------------------------------------------------//
//################################ SPI #################################//
//----------------------------------------------------------------------//

//----------------------------------------------------------------------//
`define SPI_CLK_POL_NOM     (0)
`define SPI_CLK_POL_INV     (1)
`define SPI_CLK_PHS_DIS     (0)
`define SPI_CLK_PHS_EN      (1)
//----------------------------------------------------------------------//
`define SPI_ST_IDLE         (1'b0)
`define SPI_ST_TRANSFER     (1'b1)

//####################################################################################################################################//