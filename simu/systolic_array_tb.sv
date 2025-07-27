module systolic_array_tb ();
    parameter DATAWIDTH = 16;
    parameter N_SIZE = 3;
    reg clk, rst_n;
    reg valid_in;
    reg signed [DATAWIDTH-1:0] matrix_a_in [0:N_SIZE-1];
    reg signed [DATAWIDTH-1:0] matrix_b_in [0:N_SIZE-1];
    wire valid_out;
    wire [DATAWIDTH*2-1:0] matrix_out [0:N_SIZE-1];

    // Instantiate DUT
    systolic_array #(
        .DATAWIDTH(DATAWIDTH),
        .N_SIZE(N_SIZE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .matrix_a_in(matrix_a_in),
        .matrix_b_in(matrix_b_in),
        .valid_out(valid_out),
        .matrix_out(matrix_out)
    );
    
    
    // clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end


    // test bench
    initial begin
        // Initial reset
        /*rst_n = 0;
        valid_in = 0;
        #20;
        rst_n = 1;

        //****************** case 1: 2 x 2 input matrices ******************\\

        // -------------------------------
        // First Input Cycle
        // A feeds from left (column-wise), B feeds from top (row-wise)
        //
        //  Matrix A column:        Matrix B row:
        //     →                     ↓
        //   [ 1 ]                 [ 5  6 ]
        //   [ 3 ]
        // -------------------------------
        valid_in = 1;
        matrix_a_in[0] = 1;  // A₁₁
        matrix_a_in[1] = 3;  // A₂₁
        matrix_b_in[0] = 5;  // B₁₁
        matrix_b_in[1] = 6;  // B₁₂

        // -------------------------------
        // Second Input Cycle
        // A feeds second column, B feeds second row
        //
        //  Matrix A column:        Matrix B row:
        //     →                     ↓
        //   [ 2 ]                 [ 7  8 ]
        //   [ 4 ]
        // -------------------------------
        #20; // negedge
        matrix_a_in[0] = 2;  // A₁₂
        matrix_a_in[1] = 4;  // A₂₂
        matrix_b_in[0] = 7;  // B₂₁
        matrix_b_in[1] = 8;  // B₂₂

        // Stop feeding
        valid_in = 0;


        #80; // add delay to make sure result is valid

        $display("=====================================");
        $display("Expected Output Matrix C:");
        $display("C[1][1] = 19    C[1][2] = 22"); // Expected: 19, 22
        $display("C[2][1] = 43    C[2][2] = 50"); // Expected: 43, 50
        $display("====================================="); */
        
        

        //****************** case 2: 3 x 3 input matrices A and B ******************\\
        
        rst_n = 0;
        valid_in = 0;
        #20;
        rst_n = 1;

        // -------------------------------
        // First Input Cycle
        // A feeds first column, B feeds first row
        //
        //  Matrix A column:        Matrix B row:
        //     →                         ↓
        //   [ 1 ]                   [ 9  8  7 ]
        //   [ 4 ]
        //   [ 7 ]
        // -------------------------------
        valid_in = 1;
        matrix_a_in[0] = 1;
        matrix_a_in[1] = 4;
        matrix_a_in[2] = 7;

        matrix_b_in[0] = 9;
        matrix_b_in[1] = 8;
        matrix_b_in[2] = 7;

        // -------------------------------
        // Second Input Cycle
        // A feeds second column, B feeds second row
        //
        //  Matrix A column:        Matrix B row:
        //     →                         ↓
        //   [ 2 ]                   [ 6  5  4 ]
        //   [ 5 ]
        //   [ 8 ]
        // -------------------------------
        #20; // at negedge clock
        matrix_a_in[0] = 2;
        matrix_a_in[1] = 5;
        matrix_a_in[2] = 8;

        matrix_b_in[0] = 6;
        matrix_b_in[1] = 5;
        matrix_b_in[2] = 4;

        // -------------------------------
        // Third Input Cycle
        // A feeds third column, B feeds third row
        //
        //  Matrix A column:        Matrix B row:
        //     →                         ↓
        //   [ 3 ]                   [ 3  2  1 ]
        //   [ 6 ]
        //   [ 9 ]
        // -------------------------------
        #20; // at negedge clock
        matrix_a_in[0] = 3;
        matrix_a_in[1] = 6;
        matrix_a_in[2] = 9;

        matrix_b_in[0] = 3;
        matrix_b_in[1] = 2;
        matrix_b_in[2] = 1;

        // -------------------------------
        // Stop feeding input
        // -------------------------------
        valid_in = 0;

        // Let output propagate
        #120;

        $display("=====================================");
        $display("Expected Output Matrix C:");
        $display("C[1][1] = 30   C[1][2] = 24   C[1][3] = 18");
        $display("C[2][1] = 84   C[2][2] = 69   C[2][3] = 54");
        $display("C[3][1] = 138  C[3][2] = 114  C[3][3] = 90");
        $display("=====================================");  
        
        

        //************************ case 3: 4 x 4 input matrices A and B ***************************\\
        /*rst_n = 0;
        valid_in = 0;
        #20;
        rst_n = 1;

        // -------------------------------
        // Clock Cycle 1
        // A feeds 1st column, B feeds 1st row
        //
        //  Matrix A column:       Matrix B row:
        //     →                         ↓
        //   [ 1 ]                   [16 15 14 13]
        //   [ 5 ]
        //   [ 9 ]
        //   [13 ]
        // -------------------------------
        valid_in = 1;
        matrix_a_in[0] = 1;  matrix_b_in[0] = 16;
        matrix_a_in[1] = 5;  matrix_b_in[1] = 15;
        matrix_a_in[2] = 9;  matrix_b_in[2] = 14;
        matrix_a_in[3] = 13; matrix_b_in[3] = 13;

        // -------------------------------
        // Clock Cycle 2
        // A feeds 2nd column, B feeds 2nd row
        //
        //   [ 2 ]                   [12 11 10 9]
        //   [ 6 ]
        //   [10 ]
        //   [14 ]
        // -------------------------------
        #20; // negedge
        matrix_a_in[0] = 2;  matrix_b_in[0] = 12;
        matrix_a_in[1] = 6;  matrix_b_in[1] = 11;
        matrix_a_in[2] =10;  matrix_b_in[2] = 10;
        matrix_a_in[3] =14;  matrix_b_in[3] = 9;

        // -------------------------------
        // Clock Cycle 3
        // A feeds 3rd column, B feeds 3rd row
        //
        //   [ 3 ]                   [8 7 6 5]
        //   [ 7 ]
        //   [11 ]
        //   [15 ]
        // -------------------------------
        #20;
        matrix_a_in[0] = 3;  matrix_b_in[0] = 8;
        matrix_a_in[1] = 7;  matrix_b_in[1] = 7;
        matrix_a_in[2] =11;  matrix_b_in[2] = 6;
        matrix_a_in[3] =15;  matrix_b_in[3] = 5;

        // -------------------------------
        // Clock Cycle 4
        // A feeds 4th column, B feeds 4th row
        //
        //   [ 4 ]                   [4 3 2 1]
        //   [ 8 ]
        //   [12 ]
        //   [16 ]
        // -------------------------------
        #20;
        matrix_a_in[0] = 4;  matrix_b_in[0] = 4;
        matrix_a_in[1] = 8;  matrix_b_in[1] = 3;
        matrix_a_in[2] =12;  matrix_b_in[2] = 2;
        matrix_a_in[3] =16;  matrix_b_in[3] = 1;

        // -------------------------------
        // Stop feeding
        // -------------------------------
        valid_in = 0;

        // Wait for outputs
        #260;

        $display("=====================================");
        $display("Expected Output Matrix C:");
        $display("C[1][1]=80   C[1][2]=70   C[1][3]=60   C[1][4]=50");
        $display("C[2][1]=240  C[2][2]=214  C[2][3]=188  C[2][4]=162");
        $display("C[3][1]=400  C[3][2]=358  C[3][3]=316  C[3][4]=274");
        $display("C[4][1]=560  C[4][2]=502  C[4][3]=444  C[4][4]=386");
        $display("=====================================");

        // displaying accumulator rows to show the correct functionality it is just a matter of timing
        $display("accumulator first row is: %0d,  %0d,  %0d, %0d", dut.accumulator[0][0], dut.accumulator[0][1], dut.accumulator[0][2], dut.accumulator[0][3]);
        $display("accumulator second row is: %0d,  %0d,  %0d, %0d", dut.accumulator[1][0], dut.accumulator[1][1], dut.accumulator[1][2], dut.accumulator[1][3]);
        $display("accumulator third row is: %0d,  %0d,  %0d, %0d", dut.accumulator[2][0], dut.accumulator[2][1], dut.accumulator[2][2], dut.accumulator[2][3]);
        $display("accumulator fourth row is: %0d,  %0d,  %0d, %0d", dut.accumulator[3][0], dut.accumulator[3][1], dut.accumulator[3][2], dut.accumulator[3][3]);
        */
        $stop;
    end
    always_comb begin
        if (N_SIZE == 2)
            $monitor("output matrix rows are %0d,  %0d", matrix_out[0], matrix_out[1]);
        else if (N_SIZE == 3)
            $monitor("output matrix rows are %0d,  %0d,  %0d", matrix_out[0], matrix_out[1], matrix_out[2]);
        else if (N_SIZE == 4) 
            $monitor("output matrix rows are %0d,  %0d,  %0d, %0d", matrix_out[0], matrix_out[1], matrix_out[2], matrix_out[3]);
    end
endmodule