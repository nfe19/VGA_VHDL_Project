library ieee;
use ieee.std_logic_1164.all;

entity VGA_Controller is
	generic(ha: integer := 96;
			  hb: integer := 144;
			  hc: integer := 784;
			  hd: integer := 800;
			  va: integer := 2;
			  vb: integer := 35;
			  vc: integer := 515;
			  vd: integer := 525);
	port(clk: in std_logic;
		  redSwitch, greenSwitch, blueSwitch: in std_logic;
		  pixelClk: buffer std_logic;
		  hSync, vSync: buffer std_logic;
		  VGA_R, VGA_G, VGA_B: out std_logic_vector(9 downto 0);
		  nblank, nsync: out std_logic);
end entity;

architecture logic of VGA_Controller is
	signal hActive, vActive, dena: std_logic;
	
begin

----------------------- Control Generator -----------------------

--Static DAC signals
nblank <= '1';		--no direct blanking
nsync <= '0';			--no sync on green (0-.7V range)


--Create 25 MHz clock from 50 MHz
process(clk)
begin
	if(rising_edge(clk)) then 
		pixelClk <= not(pixelClk);
	end if;
end process;


--end 25 Mhx clock


--Horizontal signal generation
process(pixelClk)
	variable hCount: integer range 0 to hd;
begin
	
	if(rising_edge(pixelClk)) then
		hCount := hcount+1;
		
		if(hCount=ha) then
			hSync <= '1'; 
		elsif(hCount=hb) then
			hActive <= '1';
		elsif(hCount=hc) then
			hActive <= '0';
		elsif(hCount=hd) then
			hSync <= '0';
			hCount := 0;
		end if;
	end if;
	
end process;
--end Horizontal signal generation

--Vertical signal generation
process(hSync)
	variable vCount: integer range 0 to vd;
begin
	
	if(falling_edge(hSync)) then
		vCount := vCount+1;
		
		if(vCount=va) then
			vSync <= '1'; 
		elsif(vCount=vb) then
			vActive <= '1';
		elsif(vCount=vc) then
			vActive <= '0';
		elsif(vCount=vd) then
			vSync <= '0';
			vCount := 0;
		end if;
	end if;
	
end process;


--end Vertical signal generation

--------------------- End Control Generator ---------------------


------------------------ Image Generator ------------------------
process(hSync, vSync, vActive, dena, redSwitch, greenSwitch, blueSwitch)

begin

	
	--main control
	if (dena='1') then
		VGA_R <= (others => redSwitch);
		VGA_G <= (others => greenSwitch);
		VGA_B <= (others => blueSwitch);

	else
		VGA_R <= (others => '0');
		VGA_G <= (others => '0');
		VGA_B <= (others => '0');
	end if;
end process;

end architecture;