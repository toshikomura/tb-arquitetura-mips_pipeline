library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.p_MI0.all;

entity mux_forward is
       port(
                sel: in std_logic_vector(1 downto 0);
                a, b, c: in std_logic_vector(4 downto 0);
                f: out std_logic_vector(4 downto 0)
           );
end mux_forward;

architecture arq_mux_forward of mux_forward is

begin
		process(sel, a, b, c)
		begin
				case sel is 
						when "00" => f <= a;
						when "01" => f <= b;
						when "10" => f <= c;
				end case;
		end process;

end arq_mux_forward;

