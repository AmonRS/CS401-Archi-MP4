library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;


entity data_path is
    generic(width: integer);
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
end data_path;


architecture Behavioral of data_path is

    -- ALU
    component alu generic(width: integer);
    port(a, b:       in  STD_LOGIC_VECTOR((width-1) downto 0);
       alucontrol: in  STD_LOGIC_VECTOR(3 downto 0);
       aluout:     inout STD_LOGIC_VECTOR((width-1) downto 0);
       zero:       out STD_LOGIC);
    end component;
    
    -- register file
    component regfile generic(width: integer);
    port(clk:           in  STD_LOGIC;
       we3:           in  STD_LOGIC;
       -- determine number of address bits based on generic width component
       --ra1, ra2, wa3: in  STD_LOGIC_VECTOR( (integer(ceil(log2(real(width))))-1) downto 0);
       ra1, ra2, wa3: in  STD_LOGIC_VECTOR( 7 downto 0);
       wd3:           in  STD_LOGIC_VECTOR((width-1) downto 0);
       rd1, rd2:      out STD_LOGIC_VECTOR((width-1) downto 0));
    end component;
    
    -- adder
    component adder generic(width: integer);
    port(a, b: in  STD_LOGIC_VECTOR((width-1) downto 0);
       y:    out STD_LOGIC_VECTOR((width-1) downto 0));
    end component;

    -- sign extender (for immediate values)
    component signext generic( width: integer );
        port(a: in  STD_LOGIC_VECTOR((width/2)-1 downto 0);
            y: out STD_LOGIC_VECTOR(width-1 downto 0));
    end component;
    
    -- flip-flop register (for program counter etc.)
    component flopr generic(width: integer);
        port(clk, reset: in  STD_LOGIC;
            d: in  STD_LOGIC_VECTOR((width-1) downto 0);
            q: out STD_LOGIC_VECTOR((width-1) downto 0));
    end component;
    
    -- mux2 (for routing data)
    component mux2 generic(width: integer);
        port(d0, d1: in  STD_LOGIC_VECTOR(width-1 downto 0);
            s:      in  STD_LOGIC;
            y:      out STD_LOGIC_VECTOR(width-1 downto 0));
    end component;
    
    
    -- The signals to wire the datapath components together
    signal writereg: STD_LOGIC_VECTOR(7 downto 0);
    signal pcjump, pcnext, pcnextbr, pcplus4, pcbranch: STD_LOGIC_VECTOR((width-1) downto 0);
    signal signimm, signimmsh: STD_LOGIC_VECTOR((width-1) downto 0);
    signal srca, srcb, result: STD_LOGIC_VECTOR((width-1) downto 0);
    signal const_zero: STD_LOGIC_VECTOR((width-1) downto 0) := (others => '0');
    signal four: STD_LOGIC_VECTOR((width-1) downto 0);

begin

    -- 4
    four <= const_zero((width-1) downto 4) & X"4";
    
    -- next PC logic
    pcjump <= pcplus4((width-1) downto (width-4)) & instr((width-7) downto 0) & "00";
    pcreg:  flopr generic map(width) port map(clk => clk, reset => reset, d => pcnext, q => pc);
    pcadd1: adder generic map(width) port map(a => pc, b => four, y => pcplus4);
    --immsh:    sl2 generic map(width) port map(a => signimm, y => signimmsh);
    pcadd2: adder generic map(width) port map(a => pcplus4, b => signimmsh, y => pcbranch);
    pcbrmux: mux2 generic map(width) port map(d0 => pcplus4, d1 => pcbranch, s => pcsrc, y => pcnextbr);
    pcmux:   mux2 generic map(width) port map(d0 => pcnextbr, d1 => pcjump, s => jump, y => pcnext);

	-- register file logic
	rf: regfile generic map(width) port map(clk => clk, we3 => regwrite, 
	                                       ra1 => instr(15 downto 8), 
	                                       ra2 => instr(7 downto 0),
										   wa3 => writereg, wd3 => result, 
										   rd1 => srca, rd2 => writedata);

	-- select destination register based on regdst signal
	wrmux: mux2 generic map(8) port map( d0 => instr(23 downto 16), d1 => instr(23 downto 16),
									      s => regdst, y => writereg);
    
    -- select between alu output and data read from memory	
	resmux: mux2 generic map(width) port map( d0 => aluout, d1 => readdata, 
	                                           s => memread, y => result);
	
	-- sign extend immediate data
	se: signext generic map(width) port map( a => instr(((width/2)-1) downto 0), y => signimm);

	-- ALU logic
	srcbmux: mux2 generic map(width) port map( d0 => writedata, d1 => signimm, 
	                                            s => alusrc, y => srcb);
	
	-- wire up the main ALU
	mainalu:  alu generic map(width) port map(a => srca, b => srcb, 
	                                          alucontrol => alucontrol, aluout => aluout, zero => zero);

end Behavioral;
