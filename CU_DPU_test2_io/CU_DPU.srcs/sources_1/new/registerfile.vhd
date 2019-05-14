---------------------------------------------------------------------
-- three-port register file
---------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;

entity regfile is 
  generic(width: integer);
  port(clk:           in  STD_LOGIC;
       we3:           in  STD_LOGIC;
	   -- determine number of address bits based on generic width
       --ra1, ra2, wa3: in  STD_LOGIC_VECTOR( (integer(ceil(log2(real(width))))-1) downto 0);
       ra1, ra2, wa3: in  STD_LOGIC_VECTOR( 7 downto 0);
       wd3:           in  STD_LOGIC_VECTOR((width-1) downto 0);
       rd1, rd2:      out STD_LOGIC_VECTOR((width-1) downto 0);
       instr:         in  STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of regfile is
  type ramtype is array ((width-1) downto 0) of STD_LOGIC_VECTOR((width-1) downto 0);
  signal mem: ramtype;
  
  signal ra11, ra22:         STD_LOGIC_VECTOR( 4 downto 0 );
  
begin
    ra11 <= ra1 (4 downto 0);
    ra22 <= ra2 (4 downto 0);

  -- three-ported register file
  
  -- write to the third port on rising edge of clock
  -- write address is in wa3
  process(clk) begin
    if rising_edge(clk) then
		if we3 = '1' then 
			mem(to_integer(unsigned(wa3))) <= wd3;
		end if;
    end if;
  end process;
  
  -- read mem from two separate ports 1 and 2 
  -- addresses are in ra1 and ra2
  process(ra11, ra22, mem) begin
    -- if not li/jump
    if (to_integer(unsigned(instr(31 downto 24)))/=35) and (to_integer(unsigned(instr(31 downto 24)))/=49) then
        if ( to_integer(unsigned(ra11)) /= 0) then 
            rd1 <= mem(to_integer(unsigned(ra1)));
        else 
            rd1 <= (others => '0'); -- register 0 holds 0
        end if;
        
        -- 
        if (to_integer(unsigned(instr(31 downto 24)))=34) then
            rd2 <= mem(to_integer( unsigned(instr(23 downto 16))));
        elsif ( to_integer(unsigned(ra22)) /= 0) then 
            rd2 <= mem(to_integer( unsigned(ra2)));
        else 
            rd2 <= (others => '0'); -- register 0 holds 0
        end if;
    end if;
  end process;
end;