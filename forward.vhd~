library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.p_MI0.all;

entity forward is
	port( 
			ID_EX_rs: in std_logic_vector(4 downto 0);
			ID_EX_rt: in std_logic_vector(4 downto 0);
			EX_MEM_RegWrite: in std_logic;
			EX_MEM_RegDst: in std_logic_vector(4 downto 0);
			MEM_WB_RegWrite: in std_logic;
			MEM_WB_RegDst: in std_logic_vector(4 downto 0);
			fwd_A: out std_logic_vector(1 downto 0);
			fwd_B: out std_logic_vector(1 downto 0)
	);
end forward;

architecture forward_arq of forward is 

begin

	process(ID_EX_rs, ID_EX_rt, EX_MEM_RegWrite, EX_MEM_RegDst, MEM_WB_RegWrite, MEM_WB_RegDst)
	begin

			-- SETANDO PARA O PADRÃO, ISTO É, BANCO DE REGISTRADORES
			fwd_A <= "00";
			fwd_B <= "00";

			-- SE ESCRITA NA INSTRUÇÃO PASSANDO PARA MEM E
			-- SE REGISTRADOR DE DESTINO DESTA INSTRUÇÃO É DIFERENTE DE ZERO E
			-- SE REGISTRADOR DE DESTINO DESTA INSTRUÇÃO É IGUAL A "RS" DA INSTRUÇÃO QUE ESTÁ PASSADNO PARA EX
			if ( (EX_MEM_RegWrite = '1') AND (EX_MEM_RegDst /= "00000") AND (EX_MEM_RegDst = ID_EX_rs) ) then
					fwd_A <= "01";
			end if;

			-- IDEM MAS PARA "RT"
			if ( (EX_MEM_RegWrite = '1') AND (EX_MEM_RegDst /= "00000") AND (EX_MEM_RegDst = ID_EX_rt) ) then
					fwd_B <= "01";
			end if;

			-- SE ESCRITA NA INSTRUÇÃO PASSANDO PARA WB E
			-- SE REGISTRADOR DE DESTINO DESTA INSTRUÇÃO É DIFERENTE DE ZERO E
			-- SE REGISTRADOR DE DESTINO DESTA INSTRUÇÃO É IGUAL A "RS" DA INSTRUÇÃO QUE ESTÁ PASSADNO PARA EX E -
			-- SE REGISTRADOR DE DESTION DESTA INSTRUÇÃO É DIFERENTE DO REGISTRADOR DE DESTINO DA INSTRUÇÃO PASSANDO PARA EX OU
			-- SE NÃO É ESCRITA NA INSTRUÇÃO PASSANDO PARA EX  
			if ( (MEM_WB_RegWrite = '1') AND (MEM_WB_RegDst /= "00000") AND (MEM_WB_RegDst = ID_EX_rs) AND ( (EX_MEM_RegDst /= ID_EX_rs) OR (EX_MEM_RegWrite /= '1') ) ) then
					fwd_A <= "10";
			end if;

			-- IDEM MAS PARA "RT"
			if ( (MEM_WB_RegWrite = '1') AND (MEM_WB_RegDst /= "00000") AND (MEM_WB_RegDst = ID_EX_rt) AND ( (EX_MEM_RegDst /= ID_EX_rt) OR (EX_MEM_RegWrite /= '1') ) ) then
					fwd_B <= "10";
			end if;
	end process;

end forward_arq;
