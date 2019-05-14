---------------------------------------------------------------
-- ALU
---------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.ALL;



entity alu is 
  generic(width: integer:= 32);
  port(a, b:       in  STD_LOGIC_VECTOR((width-1) downto 0);
       alucontrol: in  STD_LOGIC_VECTOR (3 downto 0);
       aluout:     inout STD_LOGIC_VECTOR((width-1) downto 0);
       zero:       out STD_LOGIC);
end;



architecture behave of alu is
  signal b2, sum, diff, modd, xorr, inc, dec, power, slt: STD_LOGIC_VECTOR((width-1) downto 0);
  signal mul, div: STD_LOGIC_VECTOR((2*width)-1 downto 0);
  signal const_zero : STD_LOGIC_VECTOR((width-1) downto 0) := (others => '0');
  
begin

  -- for addition and subtraction
  b2 <= not b when alucontrol(3) = '1' else b;
  sum <= a + b2 + alucontrol(3);
  diff <= sum;
  -- mod
  modd <= std_logic_vector( unsigned(a) mod unsigned(b2) );
  -- mul , div , power
  mul <= (a * b);
  --div<=a;--div <= (a / b);
  --power<=a;--power <= a ** b;
  -- inc , dec
  inc <= a + 1;
  dec <= a - 1;
  -- slt should be 1 if most significant bit of sum is 1
  slt <= ( const_zero(width-1 downto 1) & '1') when sum((width-1)) = '1' else (others =>'0');
  

  
  -- determine alu operation from alucontrol bits
  with alucontrol(3 downto 0) select aluout <=
    a and b                         when "0000",    -- a & b
    a or b                          when "0001",    -- a | b
    a xor b                         when "0010",    -- a (x) b
    sum                             when "0011",    -- a + b
    inc                             when "0100",    -- a + 1
    mul((width-1) downto 0)         when "0101",    -- a * b
    --div                             when "0110",    -- a / b
    modd                            when "0111",    -- a % b
    a nand b                        when "1000",    -- a ~& b
    a nor b                         when "1001",    -- a ~| b
    not a                           when "1010",    -- ~a
    diff                            when "1011",    -- a - b
    dec                             when "1100",    -- a - 1
    -- 1101 is not used.
    --power                           when "1110",    -- a ** b
    slt                             when "1111",
    
    a                               when others;

	
	
	
  -- set the zero flag if aluout(result) is 0
  zero <= '1' when aluout = const_zero else '0';
  
end;
