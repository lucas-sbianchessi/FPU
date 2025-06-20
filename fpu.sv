module fpu (
  input  logic  [31:0]  op_A_in,
  input  logic  [31:0]  op_B_in,
  input  logic          clock,
  input  logic          reset,
  output logic  [31:0]  data_out,
  output logic  [3:0]   status_out // EXACT, OVERFLOW, UNDERFLOW, INEXACT
);

  typedef enum {
    INIT,
    SHIFT_UP_A,
    SHIFT_UP_B,
    SUM,
    FIND_ONE
  } TipoEstado;

  TipoEstado   estado;
  logic        op;

  logic [23:0] mantissa; // buffer para aritmetica
  logic [8:0]  expoente;

  logic        sinal_A;
  logic [8:0]  expoente_A;
  logic [23:0] mantissa_A;

  logic        sinal_B;
  logic [8:0]  expoente_B;
  logic [23:0] mantissa_B;

  logic        sinal_out;
  logic [8:0]  expoente_out;
  logic [21:0] mantissa_out;

  assign data_out = {sinal_out, expoente_out, mantissa_out};


  always_ff @(posedge clock, negedge reset) begin
    if (reset) begin
      estado       <= INIT;
      status_out   <= 4'b1000;

      mantissa     <= 0;

      sinal_out    <= 0;
      expoente_out <= 0;
      mantissa_out <= 0;

      sinal_A      <= 0;
      mantissa_A   <= 0;
      expoente_A   <= 0;

      sinal_B      <= 0;
      mantissa_B   <= 0;
      expoente_B   <= 0;
    end else begin
      case (estado)
        INIT: begin
          status_out <= 4'b1000;

          sinal_A    <= op_A_in[31];
          sinal_B    <= op_B_in[31];

          expoente_A <= op_A_in[30:22];
          expoente_B <= op_B_in[30:22];

          // coloca 1 na frente devido a especificacao do padrao
          mantissa_A[22:0] <= {1'b1, op_A_in[21:0]};
          mantissa_B[22:0] <= {1'b1, op_B_in[21:0]};

          if (op_A_in[30:0] == 0) begin
            sinal_out    <= sinal_B;
            expoente_out <= expoente_B;
            mantissa_out <= mantissa_B;
          end else if (op_B_in[30:0] == 0) begin
            sinal_out    <= sinal_A;
            expoente_out <= expoente_A;
            mantissa_out <= mantissa_A;
          end else begin
            // Verifica o menor expoente, se igual vai para a soma
            if (op_A_in[30:22] < op_B_in[30:22]) begin
              estado <= SHIFT_UP_A;
            end else if (expoente_B < expoente_A) begin
              estado <= SHIFT_UP_B;
            end else begin
              estado <= SUM;
            end
          end
        end

        SHIFT_UP_A: begin
          if (mantissa_A[0] == 1) begin
            // acende UNDERFLOW e o INEXACT
            status_out[3] = 0;
            status_out    = status_out | 4'b0011;
          end

          // shifting para baixo e aumentando o expoente
          mantissa_A = mantissa_A >> 1;
          expoente_A++;
          if (expoente_A == 0) begin
            status_out = 4'b0101;
          end

          if (expoente_B == expoente_A) begin
            estado = SUM;
          end
        end

        SHIFT_UP_B: begin
          if (mantissa_B[0] == 1) begin
            // acende UNDERFLOW e o INEXACT
            status_out[3] = 0;
            status_out    = status_out | 4'b0011;
          end

          // shifting para baixo e aumentando o expoente
          mantissa_B = mantissa_B >> 1;
          expoente_B++;
          if (expoente_B == 0) begin
            status_out <= 4'b0101;
          end

          if (expoente_A == expoente_B) begin
            estado = SUM;
          end
        end

        SUM: begin
          op <= sinal_A ^ sinal_B;
          expoente = expoente_A;

          if (op) begin // se os sinais sao diferentes

            if (mantissa_A > mantissa_B) begin
              mantissa  <= mantissa_A - mantissa_B;
              sinal_out <= sinal_A;

              estado <= FIND_ONE;
            end else if (mantissa_B > mantissa_A) begin 
              mantissa  <= mantissa_B - mantissa_A;
              sinal_out <= sinal_B;

              estado <= FIND_ONE;
            end else begin
              sinal_out    <= 0;
              expoente_out <= 0;
              mantissa_out <= 0;

              estado <= INIT;
            end

          end else begin // se os sinais sao iguais
              mantissa = mantissa_A + mantissa_B;
              // Pela forma que foi preenchido e garantido que em uma soma ou
              // o primeiro ou o segundo bit estao setados remove um digito 
              // por conta do padrao
              if (mantissa[23] == 1) begin
                mantissa_A = mantissa >> 1;
                expoente++;
                if (expoente == 0) begin
                  status_out <= 4'b0101;
                end
                mantissa = mantissa_A;
              end

              sinal_out <= sinal_A;
              expoente_out <= expoente;
              mantissa_out <= mantissa[21:0]; // 22 numeros

              estado <= INIT;
          end
        end

        FIND_ONE: begin
          mantissa_A = mantissa;

          // Procura o primeiro um e o descarta
          if (mantissa[22] == 1) begin
            expoente_out <= expoente;
            mantissa_out <= mantissa[21:0];

            estado <= INIT;
          end

          // Pode ser alterado mesmo apos ser achado pois ja foi salvo
          mantissa = mantissa_A << 1;
          expoente--;
        end
      endcase
    end
  end
endmodule
