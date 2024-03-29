module DivideTestBench();
    wire [31:0] quotient, remainder;
    reg [31:0] shadow_quot, shadow_rem; // check whether results in testbench are the same as results in hardware
    reg [31:0]  a, b;
    integer    i;
    parameter  num_tests = 20; // num of tests, can be changed to any positive number
    reg        sign;

    reg        clk;
    initial clk = 0;
    always #1 clk = ~clk;

    reg        start;
    wire       ready;

    // pre-define infinity for verify divide by zero
    wire [63:0] infinity;
    assign     infinity = 63'hffffffff;

    initial sign = 0;

    Divide div(ready,quotient,remainder,a,b,sign,clk);

    initial begin

        # 0.5;

        while ( !ready ) #1;

        for (i=0; i<num_tests; i=i+1) begin:A

         integer shadow_quot, shadow_rem;

         a = $random;
         b = i & 1 ? $random : $random & 3;
         start = 1;

         while ( ready ) #1;

         start = 0;

         while ( !ready ) #1;

         shadow_quot = b ? a / b : infinity; // when divisor is 0, the result goes to infinity
         shadow_rem  = b ? a % b : a;

         #1;
         if ( quotient != shadow_quot || remainder != shadow_rem ) begin
            $display("[ERR] Wrong quotient: %h / %h  =  %h r %h  !=  %h r %h (correct)",
                     a, b, quotient, remainder, shadow_quot, shadow_rem);
            $stop;
         end
		 $display("[TESTCASE - PASS] ", $time, " a = %b, b = %b, shadow_quot=%b, shadow_rem=%b", a, b, shadow_quot,shadow_rem);
      end

      $display("Tried %d divide tests",num_tests);
      $stop;
   end

endmodule
