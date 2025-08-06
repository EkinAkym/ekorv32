# ⚙️ EkoRV-32 – RISC-V 32-bit Core by Ekin Akyıldırım

**EkoRV-32** is a 32-bit RISC-V processor core that supports both the **RV32I** (Base Integer) and **RV32M** (Multiplication/Division) instruction sets.

To ensure **ASIC compatibility**, all logic operations are placed inside modular units. The top module (`ekorv32.v`) is only responsible for wire-level connections, making it directly integrable into ASIC flows.

> 📦 The design features a **16KB unified memory**, divided equally into:
- **8KB Instruction Memory**
- **8KB Data Memory**

Memory size and other configuration options can be easily modified via the `ekorv32_defines.vh` file, which centralizes all key parameters in encoded form.

✍️ This entire design was developed by **Ekin Akyıldırım**.

> 💡 *A DMA (Direct Memory Access) module and additional peripheral support will be included in a future version.*

## 📐 EkoRV-32 Core Diagram
![EkoRV32](https://github.com/user-attachments/assets/d72d1c08-954a-4914-bda0-dbb610d79a2e)

## 🧾 File Structure

The following files constitute the entire synthesizable RISC-V core:

- `ekorv32_defines.vh`  
- `ekorv32.v`  
- `ekorv32_core_alu_div32_unit.v`  
- `ekorv32_core_alu_mul32_unit.v`  
- `ekorv32_core_alu_rv32im_unit.v`  
- `ekorv32_core_inst_decoder_unit.v`  
- `ekorv32_core_control_unit.v`  
- `ekorv32_core_pc_unit.v`  
- `ekorv32_core_register_unit.v`  
- `ekorv32_core_mem_ctrl_unit.v`  
- `ekorv32_memory.v`

All files are fully synthesizable and can be integrated into ASIC or FPGA workflows with ease.

## 🔧 Using Custom Instructions

To load your own instructions into the memory module:

1. Assemble your RISC-V code using a basic assembler.
2. Set the memory addresses as follows:
   - ROM (instruction memory): `0x00000000`
   - RAM (data memory): `0x00000800`
3. Convert your program to hex format suitable for Verilog `initial` memory initialization.
4. Open the `ekorv32_memory.v` file.
5. Locate the `initial begin` block and replace the existing instruction values with your own.

> ⚠️ The default instructions in the memory module are only for test purposes and should be removed before synthesis.

## 🛠️ OpenLane ASIC Implementation

The **EkoRV-32** core has been successfully implemented using the **OpenLane** physical design flow with the **Sky130** 130nm process node from Skywater.

> 🧪 Key Implementation Results:
- Target Frequency: **40 MHz**
- Passed all **timing analysis** (setup & hold) checks
- Fully clean **DRC**, **LVS**, and **Antenna** checks
- **Manufacturing-ready GDSII** successfully generated

📐 **Core Macro Size**: `603.255 µm x 613.975 µm`

💾 In this ASIC implementation, the EkoRV-32 core was combined with a **2KB OpenRAM-based SRAM macro**, forming a complete on-chip system that includes both compute and memory units.

This successful integration demonstrates that **EkoRV-32 is ASIC-compatible**.

### 🛠️ OpenLane ASIC Implementation Core GDS
![EkoRV32GDS](https://github.com/user-attachments/assets/0e21bced-7b36-458a-8fe2-72e38ea182b7)

#### Core Placement Density
![EkoRV32GDSPD](https://github.com/user-attachments/assets/414ff427-dec5-486e-a7da-7284f13db017)

### 🛠️ OpenLane ASIC Implementation Top GDS
![Top](https://github.com/user-attachments/assets/caa1c9cb-932d-46d9-b608-f18ad5f86cbc)
