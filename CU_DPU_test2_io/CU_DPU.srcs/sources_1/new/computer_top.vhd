library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;




entity computer_top is -- top-level design for testing
  port( 
       CLKM : in STD_LOGIC;
       A_TO_G : out STD_LOGIC_VECTOR(6 downto 0);
       AN : out STD_LOGIC_VECTOR(7 downto 0);
       DP : out STD_LOGIC;
       LED : out  STD_LOGIC_VECTOR(3 downto 0);
       reset : in STD_LOGIC
	   );
end;
--entity computer_top is
--    port( 
--       CLKM : in STD_LOGIC;
--       A_TO_G : out STD_LOGIC_VECTOR(6 downto 0);
--       AN : out STD_LOGIC_VECTOR(3 downto 0);
--       DP : out STD_LOGIC;
--       LED : out  STD_LOGIC_VECTOR(6 downto 0);
--       reset : in STD_LOGIC;
--       MISO : in STD_LOGIC;   -- Master In Slave Out, Pin 3, Port JA
--       SW : in STD_LOGIC_VECTOR( 2 downto 0); -- Switches 2, 1, and 0
--       SS : out STD_LOGIC;    -- Slave Select, Pin 1, Port JA                                   -- REMOVE COMMENTS 
--       MOSI : out STD_LOGIC;  -- Master Out Slave In, Pin 2, Port JA
--       SCLK : out STD_LOGIC  -- Serial Clock, Pin 4, Port JA
--	   );
--end computer_top;







architecture Behavioral of computer_top is

  component display_hex
	port (
		CLKM : in STD_LOGIC;
        x : in STD_LOGIC_VECTOR(31 downto 0);
        A_TO_G : out STD_LOGIC_VECTOR(6 downto 0);
        AN : out STD_LOGIC_VECTOR(7 downto 0);
        DP : out STD_LOGIC;
        LED : out  STD_LOGIC_VECTOR(3 downto 0);
        clk_div: out STD_LOGIC_VECTOR(28 downto 0)
	 );
  end component;

  component processor_top  -- top-level design for testing
    port( 
         clk : in STD_LOGIC;
         reset: in STD_LOGIC;
         out_port_1 : out STD_LOGIC_VECTOR(31 downto 0)
         );
  end component;
  
  -- this is a slowed signal clock provided to the mips_top set it from a lower bit on clk_div for a faster clock
  -- clk_div is a 29 bit counter provided by the display hex use bits from this to provide a slowed clock
  signal clk : STD_LOGIC := '0';
  signal clk_div : STD_LOGIC_VECTOR(28 downto 0);
  
  -- this data bus will hold a value for display by the hex display  
  signal display_bus: STD_LOGIC_VECTOR(31 downto 0); 
  
  signal res: STD_LOGIC;





begin
    -- clk signal       -- use a lower bit for a faster clock
    clk <= clk_div(27); 
    -- clk <= clk_div(26);
    -- clk <= clk_div(0);  -- use this in simulation (fast clk)

    proc1: processor_top port map( clk => clk, reset => reset, out_port_1 => display_bus );

    display: display_hex port map( CLKM  => CLKM,  x => display_bus, 
	           A_TO_G => A_TO_G,  AN => AN,  DP => DP,  LED => LED, clk_div => clk_div ); 


end Behavioral;
