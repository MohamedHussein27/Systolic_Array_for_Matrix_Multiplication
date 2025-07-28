# Systolic_Array_for_Matrix_multiplication

This project implements a **parameterized systolic array architecture** in SystemVerilog for efficient parallel matrix multiplication of square matrices. The array performs multiply-accumulate operations across a grid of processing elements (PEs) connected in a systolic flow.

---

## Overview

A **systolic array** is a hardware design pattern where data flows rhythmically between processing elements like the pumping of blood — hence the name "systolic." In this design:

- Matrix **A** is fed **column-wise** from the **left side** of the array.
- Matrix **B** is fed **row-wise** from the **top side** of the array.

- Outputs appear **row by row** after `2N-1` clock cycles due to pipelined data propagation.

---

## Key Notes

- The top-level module is called `systolic_array` and is fully **parameterized** with:
  - `DATAWIDTH` – bit-width of each element (default: 16 bits)
  - `N_SIZE` – matrix dimension size (e.g., 2 for 2×2, 4 for 4×4)

- Each **Processing Element (PE)** contains:
  - An accumulator for the partial sum
  - A multiplier for the incoming A and B values
  - Registers to forward A and B data to neighboring PEs

- **Data is synchronized** with a `clk` and active-low `rst_n`, and valid signals (`valid_in` and `valid_out`) are used to control and time the computation.

---

## Test Cases

This project includes simulation-based testbenches to verify the systolic array functionality for square matrix multiplication using:

- ✅ **2×2 matrix**
- ✅ **3×3 matrix**
- ✅ **4×4 matrix**

Each testbench:
- Applies A and B matrices as input streams
- Monitors and logs the result matrix `C`
- Displays expected vs. actual outputs
- Shows visual feed direction (with arrows) in comments to help understand matrix flow

📂 **The `simulation/` folder includes a `file.log` output for each test case** to verify and validate results after simulation.

---

## Documentation

For implementation details including:
- RTL architecture
- Internal data flow
- Clock by clock visualization
- Connect with code section
- Verifying functionality section
- Limitations and challenges of the design

> **Note:** For how design works you should check the [project Documentation](https://github.com/MohamedHussein27/Systolic_Array_for_Matrix_Multiplication/blob/main/report/Systolic%20Array%20Report.pdf)

---

## Contact Me!
- [Email](mailto:Mohamed_Hussein2100924@outlook.com)
- [WhatsApp](https://wa.me/+2001097685797)
- [LinkedIn](https://www.linkedin.com/in/mohamed-hussein-274337231)

