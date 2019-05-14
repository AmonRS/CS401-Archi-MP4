------------------------------------------------------------
-- mips.vhd
-- David_Harris@hmc.edu and Sarah_Harris@hmc.edu 30 May 2006
-- Single Cycle MIPS processor
------------------------------------------------------------

------------------------------------------------------------
-- Entity Declarations
------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.all;

entity processor is
 -- single cycle MIPS processor
  generic(width: integer);
  port(clk, reset:        in  STD_LOGIC;
       pc:                inout STD_LOGIC_VECTOR((width-1) downto 0);
       instr:             in  STD_LOGIC_VECTOR((width-1) downto 0);
       memwrite:          out STD_LOGIC;
       aluout, writedata: inout STD_LOGIC_VECTOR((width-1) downto 0);
       readdata:          in  STD_LOGIC_VECTOR((width-1) downto 0));
end;

---------------------------------------------------------
-- Architecture Definitions
---------------------------------------------------------

architecture struct of processor is
  component control_unit
    port(op:          in  STD_LOGIC_VECTOR(7 downto 0);
         zero:               in  STD_LOGIC;
         memread, memwrite: out STD_LOGIC;
         pcsrc, alusrc:      out STD_LOGIC;
         regdst, regwrite:   out STD_LOGIC;
         jump:               out STD_LOGIC;
         alucontrol:         out STD_LOGIC_VECTOR(3 downto 0));
  end component;
  
  component data_path generic(width : integer );
  port(clk, reset:        in  STD_LOGIC;
       memread, pcsrc:   in  STD_LOGIC;
       alusrc, regdst:    in  STD_LOGIC;
       regwrite, jump:    in  STD_LOGIC;
       alucontrol:        in  STD_LOGIC_VECTOR(3 downto 0);
       zero:              out STD_LOGIC;
       pc:                inout STD_LOGIC_VECTOR((width-1) downto 0);
       instr:             in  STD_LOGIC_VECTOR((width-1) downto 0);
       aluout, writedata: inout STD_LOGIC_VECTOR((width-1) downto 0);
       readdata:          in  STD_LOGIC_VECTOR((width-1) downto 0));
  end component;
  
  -- Signals to wire the datapath unit to the controller unit
  signal memread, alusrc, regdst, regwrite, jump, pcsrc: STD_LOGIC;
  signal zero: STD_LOGIC;
  signal alucontrol: STD_LOGIC_VECTOR(3 downto 0);
  
begin
  cont: control_unit port map( op => instr((width-1) downto 24),
                            zero => zero, memread => memread, memwrite => memwrite, 
                            pcsrc => pcsrc, alusrc => alusrc,
				            regdst => regdst, regwrite => regwrite, 
				            jump => jump, alucontrol => alucontrol);
				            
  --dp: data_path generic map(width) port map(clk => clk, reset => reset, 
  dp: data_path generic map(32) port map(clk => clk, reset => reset, 
                                           memread => memread, pcsrc => pcsrc, 
                                           alusrc => alusrc, regdst => regdst,
                                           regwrite => regwrite,  jump => jump, 
                                           alucontrol => alucontrol, zero => zero, 
                                           pc => pc, instr => instr,
								           aluout => aluout, writedata => writedata, 
								           readdata => readdata);
end;
