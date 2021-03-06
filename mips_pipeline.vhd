library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_bit.all;
use work.p_MI0.all;

entity mips_pipeline is
	port (
		clk: in std_logic;
		reset: in std_logic
	);
end mips_pipeline;


architecture arq_mips_pipeline of mips_pipeline is
   

    -- ********************************************************************
    --                              Signal Declarations
    -- ********************************************************************
     
    -- IF Signal Declarations
    
    signal IF_instr, IF_pc, IF_pc_next, IF_pc4 : reg32 := (others => '0');
		signal IF_pc4_or_j : reg32 := (others => '0'); -- JUMP AND JAL
		signal IF_j_or_jr: reg32; -- JR

    -- ID Signal Declarations

    signal ID_instr, ID_pc4: reg32;  -- pipeline register values from EX
    signal ID_op, ID_funct: std_logic_vector(5 downto 0);
    signal ID_rs, ID_rt, ID_rd: std_logic_vector(4 downto 0);
    signal ID_immed: std_logic_vector(15 downto 0); -- FUNC TO JR
    signal ID_extend, ID_A, ID_B: reg32;
    signal ID_RegWrite, ID_RegDst, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_ALUSrc: std_logic; --ID Control Signals ID_Branch
    signal ID_ALUOp: std_logic_vector(1 downto 0);
		signal ID_PCSrc: std_logic; -- JUMP AND JAL
		signal ID_pc_j: reg32; -- JUMP AND JAL
		signal ID_JRSrc: std_logic; -- JR
		signal ID_JALSrc: std_logic; -- JAL
		signal ID_RegDst_Jal: std_logic; -- JAL
		signal ID_reset_jumps: std_logic; -- JUMPS
		signal ID_BEQSrc: std_logic; -- BEQ ID
		signal ID_btgt: reg32; -- BEQ ID
		signal ID_offset: reg32; -- BEQ ID
		signal ID_Branch_compare, ID_Branch_control: std_logic; -- BEQ
		signal ID_IME_op: std_logic; -- BEQ

    -- EX Signals

    signal EX_pc4, EX_extend, EX_A, EX_B: reg32;
    signal EX_offset, EX_alub, EX_ALUOut: reg32;
    signal EX_rt, EX_rd: std_logic_vector(4 downto 0);
    signal EX_RegRd: std_logic_vector(4 downto 0);
    signal EX_funct: std_logic_vector(5 downto 0);
    signal EX_RegWrite, EX_Branch, EX_RegDst, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_ALUSrc: std_logic;  -- EX Control Signals
    signal EX_Zero: std_logic;
    signal EX_ALUOp: std_logic_vector(1 downto 0);
    signal EX_Operation: std_logic_vector(2 downto 0);
		signal EX_JALSrc: std_logic; -- JAL
		signal EX_RegDst_Jal: std_logic; -- JAL
		signal EX_rt_or_RegDst_Jal: std_logic_vector(4 downto 0); -- JAL
		signal EX_JRSrc: std_logic; -- JR
		signal EX_pc_j: reg32; -- JUMP
		signal EX_PCSrc: std_logic; -- JUMP OR JAL
		signal EX_BEQSrc: std_logic := '0'; -- BEQ ID
		signal EX_btgt: reg32; -- BEQ
		signal EX_rs: std_logic_vector(4 downto 0); -- FORWARD
		signal EX_fwd_A, EX_fwd_B: std_logic_vector(1 downto 0); -- FORWARD
		signal EX_fwd_A_out, EX_fwd_B_out: reg32; -- FORWARD

   -- MEM Signals

    signal MEM_PCSrc: std_logic;
    signal MEM_RegWrite, MEM_Branch, MEM_MemtoReg, MEM_MemRead, MEM_MemWrite, MEM_Zero: std_logic;
    signal MEM_btgt, MEM_ALUOut, MEM_B: reg32;
    signal MEM_memout: reg32;
    signal MEM_RegRd: std_logic_vector(4 downto 0);
		signal MEM_pc4: reg32; -- JAL
		signal MEM_JALSrc: std_logic; -- JAL
   
    -- WB Signals

    signal WB_RegWrite, WB_MemtoReg: std_logic;  -- WB Control Signals
    signal WB_memout, WB_ALUOut: reg32;
    signal WB_wd: reg32;
    signal WB_RegRd: std_logic_vector(4 downto 0);
		signal WB_pc4: reg32; -- JAL
		signal WB_JALSrc: std_logic; -- JAL
		signal WB_ALUOut_or_pc4: reg32; -- JAL

begin -- BEGIN MIPS_PIPELINE ARCHITECTURE

    -- ********************************************************************
    --                              IF Stage
    -- ********************************************************************

    -- IF HardwareClass 

		-- ATUALIZANDO "PC"
    PC: entity work.reg port map (clk, reset, IF_pc_next, IF_pc);

		-- SOMANDO 4 A "PC"
    PC4: entity work.add32 port map (IF_pc, x"00000004", IF_pc4);

		-- SELECIONANDO O SALTO DO "JUMP" OU SALTO DO "JR"
    MX4: entity work.mux2 port map (EX_JRSrc, EX_pc_j, EX_A, IF_j_or_jr); -- mux to jump or jr

		-- SELECIONANDO O "PC + 4" OU A SAIDA DE "MX4"
    MX3: entity work.mux2 port map (EX_PCSrc, IF_pc4, IF_j_or_jr, IF_pc4_or_j); -- mux to mx4 out or pc4

		-- SELECIONANDO A SAIDA DE "MX3" OU O SALTO DE "BEQ"
    MX2: entity work.mux2 port map (EX_BEQSrc, IF_pc4_or_j, EX_btgt, IF_pc_next); -- mux to mx3 out or beq

		-- BUSCA DA INSTRUÇÃO
    ROM_INST: entity work.rom32 port map (IF_pc, IF_instr);

    IF_s: process(clk)
    begin     			-- IF/ID Pipeline Register
    	if rising_edge(clk) then
        	if reset = '1' then

            				ID_instr <= (others => '0');
            				ID_pc4   <= (others => '0');

        	else
								if ID_reset_jumps = '1' then -- JUMPS

										ID_instr <= (others => '0');

								else

            				ID_instr <= IF_instr;
            				ID_pc4   <= IF_pc4;

								end if;
        	end if;
			end if;
   	end process;


    -- ********************************************************************
    --                              ID Stage
    -- ********************************************************************

		-- COLETANDO VALORES DA INSTRUÇÃO
    ID_op <= ID_instr(31 downto 26);
    ID_rs <= ID_instr(25 downto 21);
    ID_rt <= ID_instr(20 downto 16);
    ID_rd <= ID_instr(15 downto 11);
    ID_immed <= ID_instr(15 downto 0);
		-- pc 31-26 with immediate 25-0 to jump
		ID_pc_j <= ID_pc4(31 downto 26) & ID_instr(25 downto 0);
		-- Func to JR
		ID_funct <= ID_instr(5 downto 0);

		-- BANCO DE REGISTRADORES
    REG_FILE: entity work.reg_bank port map ( clk, reset, WB_RegWrite, ID_rs, ID_rt, WB_RegRd, ID_A, ID_B, WB_wd);

    -- sign-extender
    EXT: process(ID_immed)
    begin

			-- ALTERAÇÃO NA EXTENSÃO DE SINAL, CONVERTENDO O VALOR NEGATIVO PARA POSITIVO E SINALIZANDO QUE É NEGATIVO
			if ID_immed(15) = '1' then
				ID_extend <= x"0000" & ((not ID_immed(15 downto 0) )+ 1); -- BEQ ext sig -- CONVERTENDO PARA POSITIVO
				ID_IME_op <= '1'; -- BEQ -- SINALIZADOR
			else
				ID_extend <= x"0000" & ID_immed(15 downto 0);
				ID_IME_op <= '0'; -- BEQ
			end if;
   	end process;

		-- COMPARA OS VALORES DE "A" E "B" QUE SAIRAM DO BANCO DE REGISTRADORES
    COMPARE: entity work.compare port map (ID_A, ID_B, ID_Branch_compare); -- BEQ ID

		-- SHIFTA EM 2 (MULTIPLICA POR 4)
    SIGN_EXT: entity work.shift_left port map (ID_extend, 2, ID_offset); -- BEQ ID

		-- SOMA "PC + 4" COM O VALOR SHIFTADO
    BRANCH_ADD: entity work.branch port map (ID_pc4, ID_offset, ID_IME_op, ID_btgt); -- BEQ ID add novo sign

		-- DEFINE A MAIOR PARTE DOS SINAIS DO PIPELINE
    CTRL: entity work.control_pipeline port map (ID_op, ID_RegDst, ID_ALUSrc, ID_MemtoReg, ID_RegWrite, ID_MemRead, ID_MemWrite, ID_Branch_control, ID_ALUOp, ID_PCSrc, ID_funct, ID_JRSrc, ID_JALSrc, ID_RegDst_Jal, ID_reset_jumps, ID_IME_op);

		-- COMPARAÇÃO PARA VER SE A INSTRUÇÃO É BEQ E SE AS SAIDA "A" E "B" DA ULA SÃO IGUAIS
		ID_BEQSrc <= ID_Branch_compare AND ID_Branch_control; -- BEQ

    ID_EX_pip: process(clk)		    -- ID/EX Pipeline Register
    begin
			if rising_edge(clk) then
        if reset = '1' then
          EX_RegDst   <= '0';
	    		EX_ALUOp    <= (others => '0');
          EX_ALUSrc   <= '0';
		    --	EX_Branch   <= '0';
					EX_MemRead  <= '0';
					EX_MemWrite <= '0';
					EX_RegWrite <= '0';
					EX_MemtoReg <= '0';

					EX_pc4      <= (others => '0');
					EX_A        <= (others => '0');
					EX_B        <= (others => '0');
					EX_extend   <= (others => '0');
					EX_rt       <= (others => '0');
					EX_rd       <= (others => '0');

        else 

        	EX_RegDst   <= ID_RegDst;
       		EX_ALUOp    <= ID_ALUOp;
       		EX_ALUSrc   <= ID_ALUSrc;
       	--	EX_Branch   <= ID_Branch;
       		EX_MemRead  <= ID_MemRead;
       		EX_MemWrite <= ID_MemWrite;
       		EX_RegWrite <= ID_RegWrite;
       		EX_MemtoReg <= ID_MemtoReg;
          
       		EX_pc4      <= ID_pc4;
       		EX_A        <= ID_A;
       		EX_B        <= ID_B;
      		EX_extend   <= ID_extend;
					EX_rs       <= ID_rs; -- FORWARD
       		EX_rt       <= ID_rt;
       		EX_rd       <= ID_rd;
					EX_funct    <= ID_funct;
					EX_PCSrc    <= ID_PCSrc;
					EX_pc_j     <= ID_pc_j; -- JUMP
					EX_JRSrc    <= ID_JRSrc; -- JUMP
					EX_JALSrc   <= ID_JALSrc; -- JAL
					EX_RegDst_Jal <= ID_RegDst_Jal; -- JAL
					EX_BEQSrc   <= ID_BEQSrc; -- BEQ
					EX_btgt     <= ID_btgt; -- BEQ
      	end if;
			end if;
		end process;

    -- ********************************************************************
    --                              EX Stage
    -- ********************************************************************

    -- branch offset shifter
   -- SIGN_EXT: entity work.shift_left port map (EX_extend, 2, EX_offset);

   -- EX_funct <= EX_extend(5 downto 0);  

   -- BRANCH_ADD: entity work.add32 port map (EX_pc4, EX_offset, EX_btgt);

		FORWARD: entity work.forward port map (EX_rs, EX_rt, MEM_RegWrite, MEM_RegRd, WB_RegWrite, WB_RegRd, EX_fwd_A, EX_fwd_B); -- FORWARD

		-- MUX QUE SELECIONA A ENTRADA "A" DA ULA | BANCO DE REGISTRADORES OU ADIANTAMENTO
		MUX_FORWARD_A: entity work.mux3 port map (EX_fwd_A, EX_A, MEM_ALUOut, WB_wd, EX_fwd_A_out); -- FORWARD A

		-- MUX QUE SELECIONA A ENTRADA "B" DA ULA | BANCO DE REGISTRADORES OU ADIANTAMENTO
		MUX_FORWARD_B: entity work.mux3 port map (EX_fwd_B, EX_B, MEM_ALUOut, WB_wd, EX_fwd_B_out); -- FORWARD B

		-- MUX QUE SELECIONA A SAIDA DE "MUX_FORWARD_B" OU O IMEDIATO EXTENDIDO
    ALU_MUX_A: entity work.mux2 port map (EX_ALUSrc, EX_fwd_B_out, EX_extend, EX_alub);

		-- ULA
    ALU_h: entity work.alu port map (EX_Operation, EX_fwd_A_out, EX_alub, EX_ALUOut, EX_Zero );

		-- DEFINE QUAL VAI SER O REGISTRADOR DE DESTINO | "rt" ou "31"
    DEST_MUX2_JAL: entity work.mux2 generic map (5) port map (EX_RegDst_Jal, EX_rt, REGDST_JAL, EX_rt_or_RegDst_Jal); -- JAL

		-- DEFINE QUAL VAI SER O REGISTRADOR DE DESTINO | SAIDA DE "DEST_MUX2_JAL" OU "rd"
    DEST_MUX2: entity work.mux2 generic map (5) port map (EX_RegDst, EX_rt_or_RegDst_Jal, EX_rd, EX_RegRd);

		-- DEFINE OPERAÇÃO NA ULA
    ALU_c: entity work.alu_ctl port map (EX_ALUOp, EX_funct, EX_Operation);


    EX_MEM_pip: process (clk)		    -- EX/MEM Pipeline Register
    begin
			if rising_edge(clk) then
       	if reset = '1' then
        
        -- 	MEM_Branch   <= '0';
      		MEM_MemRead  <= '0';
       		MEM_MemWrite <= '0';
      		MEM_RegWrite <= '0';
      		MEM_MemtoReg <= '0';
      		MEM_Zero     <= '0';

        	MEM_btgt     <= (others => '0');
       		MEM_ALUOut   <= (others => '0');
       		MEM_B        <= (others => '0');
       		MEM_RegRd    <= (others => '0');

       	else

       	--	MEM_Branch   <= EX_Branch;
      		MEM_MemRead  <= EX_MemRead;
       		MEM_MemWrite <= EX_MemWrite;
       		MEM_RegWrite <= EX_RegWrite;
       		MEM_MemtoReg <= EX_MemtoReg;
       		MEM_Zero     <= EX_Zero;

      	--	MEM_btgt     <= EX_btgt;
      		MEM_ALUOut   <= EX_ALUOut;
      		MEM_B        <= EX_B;
       		MEM_RegRd    <= EX_RegRd;
					MEM_pc4      <= EX_pc4; -- JAL
					MEM_JALSrc    <= EX_JALSrc; -- JAL
      	end if;
			end if;
    end process;

    -- ********************************************************************
    --                              MEM Stage
    -- ********************************************************************

		-- ACESSO A MEMÓRIA
    MEM_ACCESS: entity work.mem32 port map (clk, MEM_MemRead, MEM_MemWrite, MEM_ALUOut, MEM_B, MEM_memout);

    -- MEM_PCSrc <= MEM_Branch and MEM_Zero;

    MEM_WB_pip: process (clk)		-- MEM/WB Pipeline Register
    begin
			if rising_edge(clk) then
	     	if reset = '1' then
         	WB_RegWrite <= '0';
       		WB_MemtoReg <= '0';
      		WB_ALUOut   <= (others => '0');
       		WB_memout   <= (others => '0');
       		WB_RegRd    <= (others => '0');

        else

       		WB_RegWrite <= MEM_RegWrite;
      		WB_MemtoReg <= MEM_MemtoReg;
      		WB_ALUOut   <= MEM_ALUOut;
      		WB_memout   <= MEM_memout;
      		WB_RegRd    <= MEM_RegRd;
					WB_pc4      <= MEM_pc4; -- JAL
					WB_JALSrc   <= MEM_JALSrc; -- JAL
       	end if;
			end if;
    end process;       

    -- ********************************************************************
    --                              WB Stage
    -- ********************************************************************

		-- SELECIONA A SAIDA DA ULA OU "PC + 4" QUANDO JAL ESTAVA EM ID
    MUX_DEST_JAL: entity work.mux2 port map (WB_JALSrc, WB_ALUOut, WB_pc4, WB_ALUOut_or_pc4); -- JAL

		-- SELECIONA A SAIDA DE "MUX_DEST_JAL" OU SAIDA DA MEMÓRIA
    MUX_DEST: entity work.mux2 port map (WB_MemtoReg, WB_ALUOut_or_pc4, WB_memout, WB_wd);
    
    --REG_FILE: reg_bank port map (clk, reset, WB_RegWrite, ID_rs, ID_rt, WB_RegRd, ID_A, ID_B, WB_wd); *instance is the same of that in the ID stage


end arq_mips_pipeline;

