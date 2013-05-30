library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.p_MI0.all;

entity branch is
       	   port( 
			a, b : in  reg32;
			op: in std_logic;
			result :   out reg32
           );
end branch;

architecture branch_arq of branch is 

begin
		process(a, b, op)
		begin
				if (op = '1') then
						result <= a - b;
				else
						result <= a + b;
				end if;
		end process;

end branch_arq;
