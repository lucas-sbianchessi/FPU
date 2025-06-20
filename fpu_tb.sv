module fpu_tb;

  `timescale 10us/10ns // 10us^-1 = 100 kHz

  logic  [31:0]  op_A_in;
  logic  [31:0]  op_B_in;
  logic          clock;
  logic          reset;
  logic  [31:0]  data_out;
  logic  [3:0]   status_out;

 fpu dut (
    .op_A_in(op_A_in),
    .op_B_in(op_B_in),
    .clock(clock),
    .reset(reset),
    .data_out(data_out),
    .status_out(status_out)
  );
  
  // clock : 100 kHz
  always #0.5 clock = ~clock;


  initial begin
    clock = 0;
    reset = 1;
    #2;

    reset   = 0;
    #3

    op_A_in = 32'b0_011111110_0000000000000000000000;
    op_B_in = 32'b0_011111110_0000000000000000000000; // mostra q faz 1.f corretamente

    #20;
    op_A_in = 32'b0_011111110_0110000000000000000000;
    op_B_in = 32'b0_011111110_0010000000000000000000; // soma com expoente igual
    // resp = 32'b0_011111111_0100000000000000000000

    #20;
    op_A_in = 32'b0_011111110_0110000000000000000000;
    op_B_in = 32'b0_011111111_0010000000000000000000; // soma com expoentes diferentes
    // resp = 32'b0_011111111_1101000000000000000000

    #20;
    op_A_in = 32'b0_011111110_0110000000000000000000;
    op_B_in = 32'b1_011111110_0010000000000000000000; // subtracao com expoentes iguais
    // resp = 32'b0_011111100_0000000000000000000000

    #20;
    op_A_in = 32'b0_011111110_0010000000000000000000;
    op_B_in = 32'b1_011111110_0011000000000000000000; // subtracao com resultado negativo
    // resp = 32'b1_011111100_0000000000000000000000

    #20;
    op_A_in = 32'b0_011111110_0110000000000000000000;
    op_B_in = 32'b1_011111111_0010000000000000000000; // subtracao com expoentes diferentes
    // resp = 32'b0_011111100_0000000000000000000000

    #20;
    op_A_in = 32'b0_000000000_0000000000000000000000;
    op_B_in = 32'b0_011111111_0010000000000000000000; // soma com zero
    // resp = 32'b0_011111111_0010000000000000000000

    #20;
    op_A_in = 32'b1_011111100_0000000000000000000010;
    op_B_in = 32'b1_011111111_0010000000000000000000; // underflow
    // resp = 32'b1_011111111_0010000000000000000000

    #22;
    op_A_in = 32'b0_111111111_1000000000000000000000;
    op_B_in = 32'b0_111111111_1000000000000000000000; // overflow

    #20;

    $stop;
  end
endmodule

