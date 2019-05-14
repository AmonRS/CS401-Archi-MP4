library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;




entity computer_top is -- top-level design for testing
  port( 
       CLKM : in STD_LOGIC;
       A_TO_G : out STD_LOGIC_VECTOR(6 downto 0);
       AN : out STD_LOGIC_VECTOR(7 downto 0);
       DP : out STD_LOGIC;
       LED : out  STD_LOGIC_VECTOR(15 downto 0);
       reset : in STD_LOGIC;
       BTNC, BTNU, BTNL, BTNR, BTND: in STD_LOGIC;
       
       MISO : in STD_LOGIC;   -- Master In Slave Out, Pin 3, Port JA
       SW : in STD_LOGIC_VECTOR( 15 downto 0); -- Switches 2, 1, and 0  -- lol no plz use switches 6,5,4
       SS : out STD_LOGIC;    -- Slave Select, Pin 1, Port JA
       MOSI : out STD_LOGIC;  -- Master Out Slave In, Pin 2, Port JA
       SCLK : out STD_LOGIC  -- Serial Clock, Pin 4, Port JA
	   );
end;






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
  
  component PmodJSTK_Demo is
      Port ( CLK : in  STD_LOGIC;                                -- 100Mhz onboard clock
             RST : in  STD_LOGIC;                                -- Button D
             MISO : in  STD_LOGIC;                                -- Master In Slave Out, JA3
             SW : in  STD_LOGIC_VECTOR (2 downto 0);        -- Switches 2, 1, and 0
             SS : out  STD_LOGIC;                                -- Slave Select, Pin 1, Port JA
             MOSI : out  STD_LOGIC;                            -- Master Out Slave In, Pin 2, Port JA
             SCLK : out  STD_LOGIC;                            -- Serial Clock, Pin 4, Port JA
             LED : out  STD_LOGIC_VECTOR (2 downto 0);    -- LEDs 2, 1, and 0
             AN : out  STD_LOGIC_VECTOR (3 downto 0);    -- Anodes for Seven Segment Display
             SEG : out  STD_LOGIC_VECTOR (6 downto 0)); -- Cathodes for Seven Segment Display
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
  signal led_for_7seg: STD_LOGIC_VECTOR(3 downto 0);
  
  signal res: STD_LOGIC;

  signal sw_jstk: STD_LOGIC_VECTOR(2 downto 0);
  signal led_jstk: STD_LOGIC_VECTOR(2 downto 0);
  signal trash_signal_1: STD_LOGIC_VECTOR(3 downto 0);
  signal trash_signal_2: STD_LOGIC_VECTOR(6 downto 0);



begin
    -- clk signal       -- use a lower bit for a faster clock
    clk <= clk_div(27); 
    -- clk <= clk_div(26);
    -- clk <= clk_div(0);  -- use this in simulation (fast clk)
    
    res <= not reset;
    
    -- LED signals from buttons
    LED(15) <= BTNU;
    LED(14) <= BTND;
    LED(13) <= BTNL;
    LED(12) <= BTNR;
    
    -- LED signals from 7-seg disp
    LED(3 downto 0) <= led_for_7seg;
    -- 7-seg display
    display: display_hex port map( CLKM  => CLKM,  x => display_bus, 
                   A_TO_G => A_TO_G,  AN => AN,  DP => DP,  LED => led_for_7seg, clk_div => clk_div ); 


    proc1: processor_top port map( clk => clk, reset => reset, out_port_1 => display_bus );
    
    
    -- SW for jstk
    sw_jstk <= SW(6 downto 4);
    --LED for jstk
    LED(10 downto 8) <= led_jstk;

    -- joystick port map
	joystick: PmodJSTK_Demo port map(
	        CLK => CLKM, 
            RST => res,
            MISO => MISO,
            SW => sw_jstk,
            SS => SS,
            MOSI => MOSI,
            SCLK => SCLK,
            LED => led_jstk,
            AN => trash_signal_1,
            SEG => trash_signal_2
	 );
    


end Behavioral;
