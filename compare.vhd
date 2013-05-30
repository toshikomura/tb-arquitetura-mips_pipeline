library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.p_MI0.all;

entity compare is
	port( 
			a, b : in  reg32;
	   	BEQSrc : out std_logic
	);
end compare;

architecture compare_arq of compare is 

	signal intReg	: reg32;

begin
	process(a, b)
	begin
			if a = b then
					BEQSrc <= '1';
			else
					BEQSrc <= '0';
			end if;
	end process;

end compare_arq;
