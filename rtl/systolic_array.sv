module systolic_array #(
    parameter DATAWIDTH = 16,
    parameter N_SIZE = 5
) (
    input clk, rst_n,
    input valid_in,
    input signed [DATAWIDTH-1:0] matrix_a_in [0:N_SIZE-1],
    input signed [DATAWIDTH-1:0] matrix_b_in [0:N_SIZE-1],
    output reg valid_out,
    output reg [DATAWIDTH*2-1:0] matrix_out [0:N_SIZE-1] // width is double for output as if we perform multiplication for example 3 * 3 = 9, 3 is two bits wide while 9 is 4 bits wide
);
   
    reg [DATAWIDTH-1:0] matrix_a_pipe [0:N_SIZE-1][0:N_SIZE-1]; // to pipeline the inputs in second and third row from the column feeding matrix
    reg [DATAWIDTH-1:0] matrix_b_pipe [0:N_SIZE-1][0:N_SIZE-1]; // to pipeline the inputs in second and third column from the row feeding matrix
    reg [DATAWIDTH*2-1:0] accumulator [0:N_SIZE-1][0:N_SIZE-1]; // to store the multiplication results 
    
    reg [DATAWIDTH-1:0] temp_a [0:N_SIZE-1]; // to store the first row of the matrix A
    reg [DATAWIDTH-1:0] temp_b [0:N_SIZE-1]; // to store the first column of the matrix B
    reg [N_SIZE*2-1:0] clock_cycle; // to count the clock cycles for pipelining,
    reg [N_SIZE*2-1:0] delayed_clock; // delayed clock is to be used in output logic as 
    //when we fill the pipe matrices and then the accumulator so it adds a one clock delay overhead for 3 by 3 matrices
    

    
    integer i, j, k, q;

    // internal always block to handle the pipelining and accumulation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            k <= 0; // for pipelining the inputs
            q <= 0; // for pipelining the inputs
            clock_cycle <= 0; // resetting the clock cycle counter
            for (i = 0; i < N_SIZE; i = i + 1) begin // output is zeroed on reset
                for (j = 0; j < N_SIZE; j = j + 1) begin
                    matrix_a_pipe[i][j] <= 0; // zeroing the pipelined inputs
                    matrix_b_pipe[i][j] <= 0; // zeroing the pipelined inputs
                    accumulator[i][j] <= 0; // zeroing the accumulator
                end
            end
        end 
        else if (valid_in || k < N_SIZE*2) begin
            // storing the first elements of of both matrices in temp_a and temp_b
            if (clock_cycle < N_SIZE) begin
                for (q = 0; q < N_SIZE; q = q + 1) begin
                    matrix_a_pipe[q][0] <= matrix_a_in[q]; // storing the column elements of matrix A
                end
                for (q = 0; q < N_SIZE; q = q + 1) begin
                    matrix_b_pipe[0][q] <= matrix_b_in[q]; // storing the row elements of matrix B
                end
                temp_a[k] <= matrix_a_in[0]; // storing the first element of every column of matrix A as we will need it later 
                // and they will be overwritten by the incoming inputs
                temp_b[k] <= matrix_b_in[0]; // storing the first element of every row of matrix B as we will need it later
                accumulator[0][0] <= accumulator[0][0] + (matrix_a_in[0] * matrix_b_in[0]); // ex: O11 = I11 * W11 + I12 * W21 + I13 * W31,
                // get the first row column multiplication result
            end

            // next stages are for pipelining
            if (k > 0) begin
                for (q = 1; q < N_SIZE; q = q + 1) begin // this for loop is to pipeline the inputs for the right number of times
                    matrix_a_pipe[q][k] <= matrix_a_pipe[q][k-1]; // for ex if N_size is 3 so the first element of the second row will be pipelined once,
                end // and the first element of the third row will be pipelined twice
                for (q = 1; q < N_SIZE; q = q + 1) begin
                    matrix_b_pipe[k][q] <= matrix_b_pipe[k-1][q]; // pipelining the inputs in next columns
                end
            end
            if (k > 1 && N_SIZE > 1) begin // the above if statement is used for the first set of inputs from both matrices, so we have to put this block N_SIZE times
                for (q = 1; q < N_SIZE; q = q + 1) begin // this for loop is to pipeline the inputs for the right number of times
                    matrix_a_pipe[q][k-1] <= matrix_a_pipe[q][k-2]; // for ex if N_size is 3 so the first element of the second row will be pipelined once,
                end // and the first element of the third row will be pipelined twice
                for (q = 1; q < N_SIZE; q = q + 1) begin
                    matrix_b_pipe[k-1][q] <= matrix_b_pipe[k-2][q]; // pipelining the inputs in next columns
                end
            end
            if (k > 2 && N_SIZE > 2) begin
                for (q = 1; q < N_SIZE; q = q + 1) begin 
                    matrix_a_pipe[q][k-2] <= matrix_a_pipe[q][k-3]; 
                end 
                for (q = 1; q < N_SIZE; q = q + 1) begin
                    matrix_b_pipe[k-2][q] <= matrix_b_pipe[k-3][q]; // pipelining the inputs in next columns
                end
            end
            if (k > 3 && N_SIZE > 3) begin
                for (q = 1; q < N_SIZE; q = q + 1) begin
                    matrix_a_pipe[q][k-3] <= matrix_a_pipe[q][k-4];
                end
                for (q = 1; q < N_SIZE; q = q + 1) begin
                    matrix_b_pipe[k-3][q] <= matrix_b_pipe[k-4][q];
                end
            end

            // storing the multiplication result in the accumulator
            if (clock_cycle > 1 && (clock_cycle < N_SIZE + 2) && N_SIZE > 1) begin
                accumulator[0][1] <= accumulator[0][1] + (temp_a[k-2] * matrix_b_pipe[1][1]); // ex: O12 = I11 * W12 + I12 * W22 + I13 * W32
                accumulator[1][0] <= accumulator[1][0] + (temp_b[k-2] * matrix_a_pipe[1][1]); // ex: O21 = I21 * W11 + I22 * W21 + I23 * W31
                accumulator[1][1] <= accumulator[1][1] + (matrix_a_pipe[1][1] * matrix_b_pipe[1][1]); // ex: O22 = I21 * W12 + I22 * W22 + I23 * W32, 
                // as I21 will be I22 in the next cycle and I22 will be I23 in the next cycle
            end
            if (clock_cycle > 2 && (clock_cycle < N_SIZE + 3) && N_SIZE > 2) begin // if N_SIZE is greater than 2, we can perform the next multiplication
                accumulator[0][2] <= accumulator[0][2] + (temp_a[k-3] * matrix_b_pipe[2][2]); // ex: O13 = I31 * W11, I32 * W21, I33 * W31
                accumulator[1][2] <= accumulator[1][2] + (matrix_a_pipe[1][2] * matrix_b_pipe[2][2]); // ex: O23 = I21 * W13, I22 * W23, I23 * W33
                accumulator[2][0] <= accumulator[2][0] + (temp_b[k-3] * matrix_a_pipe[2][2]); // ex: O31 = I31 * W11, I32 * W21, I33 * W31
                accumulator[2][1] <= accumulator[2][1] + (matrix_b_pipe[2][1] * matrix_a_pipe[2][2]); // ex: O32 = I31 * W12, I32 * W22, I33 * W32
                accumulator[2][2] <= accumulator[2][2] + (matrix_a_pipe[2][2] * matrix_b_pipe[2][2]); // ex: O33 = I31 * W13, I32 * W23, I33 * W33
            end
            if (clock_cycle > 3 && (clock_cycle < N_SIZE + 4) && N_SIZE > 3) begin // if N_SIZE is greater than 3, we can perform the next multiplication
                accumulator[0][3] <= accumulator[0][3] + (temp_a[k-4] * matrix_b_pipe[3][3]);
                accumulator[1][3] <= accumulator[1][3] + (matrix_a_pipe[1][3] * matrix_b_pipe[3][3]);
                accumulator[2][3] <= accumulator[2][3] + (matrix_a_pipe[2][3] * matrix_b_pipe[3][3]);
                accumulator[3][0] <= accumulator[3][0] + (temp_b[k-4] * matrix_a_pipe[3][3]);
                accumulator[3][1] <= accumulator[3][1] + (matrix_b_pipe[3][1] * matrix_a_pipe[3][3]);
                accumulator[3][2] <= accumulator[3][2] + (matrix_b_pipe[3][2] * matrix_a_pipe[3][3]);
                accumulator[3][3] <= accumulator[3][3] + (matrix_a_pipe[3][3] * matrix_b_pipe[3][3]);
            end

            // counters
            k <= k + 1; // incrementing the counter for pipelining
            clock_cycle <= clock_cycle + 1; // incrementing the clock cycle counter
            delayed_clock <= clock_cycle; // storing the current clock cycle in the delayed clock register
        end
        else
            delayed_clock <= clock_cycle; // to make the last clock
    end

    // combinatoinal always block to output the results
    always @(*) begin
        if (!rst_n) begin
            valid_out = 0;
            for (i = 0; i < N_SIZE; i = i + 1) begin
                matrix_out[i] = 0; // zeroing the output on reset
            end
        end
        
        else if (clock_cycle == 3  && N_SIZE < 3) begin // the second condition to prevent entering this branch if N_SIZE is greater than 2 
            for (i = 0; i < N_SIZE; i = i + 1) begin
                matrix_out[i] = accumulator[0][i]; // output the first row 
            end
            if (N_SIZE == 2) matrix_out[1] = accumulator[0][1] + (temp_a[1] * matrix_b_pipe[1][1]); // just to fasten the assignment of the last pipelined element
            valid_out = 1; // setting the valid output flag
        end
        else if ((delayed_clock == 4 && N_SIZE < 4) || (N_SIZE == 2 && clock_cycle == 4)) begin // the last condition is specially for 2 x 2 matrices to make it generate the output in 4 clock cycles (perfect)
            for (i = 0; i < N_SIZE; i = i + 1) begin
                if (N_SIZE < 3)
                    matrix_out[i] = accumulator[1][i]; // output of the second row if N_SIZE < 3
                else
                    matrix_out[i] = accumulator[0][i]; // output the first row
            end
            if (N_SIZE == 3) matrix_out[2] = accumulator[0][2] + (temp_a[2] * matrix_b_pipe[2][2]); // just to fasten the assignment of the last pipelined element
            valid_out = 1; // setting the valid output flag
        end
        else if (delayed_clock == 5 && N_SIZE < 5) begin // the second condition to prevent entering this branch if N_SIZE
            for (i = 0; i < N_SIZE; i = i + 1) begin
                if (N_SIZE < 4)
                    matrix_out[i] = accumulator[1][i]; // output the second row
                else
                    matrix_out[i] = accumulator[0][i]; // output the first row
            end
            if (N_SIZE == 4) matrix_out[3] = accumulator[0][3] + (temp_a[3] * matrix_b_pipe[3][3]); // just to fasten the assignment of the last pipelined element
            valid_out = 1; // setting the valid output flag
        end
        else if (delayed_clock == 6 && N_SIZE < 6) begin // the second condition to prevent entering this branch if N_SIZE
            for (i = 0; i < N_SIZE; i = i + 1) begin
                if (N_SIZE < 4)
                    matrix_out[i] = accumulator[2][i]; // output the third row
                else 
                    matrix_out[i] = accumulator[1][i];
            end
            valid_out = 1; // setting the valid output flag
        end
        else if (delayed_clock == 7 && N_SIZE < 7) begin 
            for (i = 0; i < N_SIZE; i = i + 1) begin
                matrix_out[i] = accumulator[2][i]; // output the third row
            end
            valid_out = 1; // setting the valid output flag
        end
        else if (delayed_clock == 8 && N_SIZE < 8) begin // the second condition to prevent entering this branch if
            for (i = 0; i < N_SIZE; i = i + 1) begin
                matrix_out[i] = accumulator[3][i]; // output the fourth row
            end
        end
        else begin
            valid_out = 0;
            for (i = 0; i < N_SIZE; i = i + 1) begin
                matrix_out[i] = 0; // zeroing the output
            end
        end
    end
endmodule