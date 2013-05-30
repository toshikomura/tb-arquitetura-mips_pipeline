library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MI0.all;

entity control_pipeline is
	port 	(
			opcode: in std_logic_vector(5 downto 0);
		 	RegDst: out std_logic; 
			ALUSrc: out std_logic; 
			MemtoReg: out std_logic; 
			RegWrite: out std_logic; 
			MemRead: out std_logic; 
			MemWrite: out std_logic; 
			Branch: out std_logic; 
			ALUOp: out std_logic_vector(1 downto 0);
			PCSrc: out std_logic; -- JUMP AND JAL
			funct: in std_logic_vector(5 downto 0); -- JR
			JRSrc: out std_logic; -- JR
			JALSrc: out std_logic; -- JAL
		 	RegDst_JAL: out std_logic; -- JAL
			rst_jumps: out std_logic; -- JUMPS
			IME_op: in std_logic -- ADDI
		);
end control_pipeline;


architecture arq_control_pipeline of control_pipeline is



    --input [5:0] opcode;
    --output RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch;
    --output [1:0] ALUOp;
    --reg    RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch;
    --reg    [1:0] ALUOp;

begin
   
    process (opcode, funct, IME_op) -- INCLUIDO "FUNC" PARA SABER SE É JR E "IME_op" PARA SABER SINAL DO IMEDIATO 
    begin
        case opcode is

          	when R_FORMAT => RegDst <= '1'; ALUSrc <= '0'; MemtoReg <= '0'; RegWrite <='1'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "10"; PCSrc <= '0'; JRSrc <= 'X'; JALSrc <= '0'; RegDst_JAL <= 'X'; rst_jumps <= '0'; -- R type
								if (funct = "001000") then -- JR
							 							 RegDst <= '1' ; ALUSrc <= '0'; MemtoReg <= '0'; RegWrite <= '0'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "10"; PCSrc <= '1'; JRSrc <= '1'; JALSrc <= '0'; RegDst_JAL <= 'X'; rst_jumps <= '1'; -- JR
								end if;

          	when LW => RegDst <= '0'; ALUSrc <= '1'; MemtoReg <= '1'; RegWrite <='1'; MemRead<='1'; MemWrite<='0'; Branch<='0'; ALUOp <= "00"; PCSrc <= '0'; JRSrc <= 'X'; JALSrc <= 'X'; RegDst_JAL <= '0'; rst_jumps <= '0'; -- LW 

						when SW => RegDst <= 'X'; ALUSrc <= '1'; MemtoReg <= 'X'; RegWrite <='0'; MemRead<='0'; MemWrite<='1'; Branch<='0'; ALUOp <= "00"; PCSrc <= '0'; JRSrc <= 'X'; JALSrc <= 'X'; RegDst_JAL <= 'X'; rst_jumps <= '0'; -- SW

						when BEQ => RegDst <= 'X'; ALUSrc <= 'X'; MemtoReg <= 'X'; RegWrite <='0'; MemRead<='0'; MemWrite<='0'; Branch<='1'; ALUOp <= "XX"; PCSrc <= 'X'; JRSrc <= 'X'; JALSrc <= 'X'; RegDst_JAL <= 'X'; rst_jumps <= '1'; -- BEQ 

						when ADDI => RegDst <= '0'; ALUSrc <= '1'; MemtoReg <= '0'; RegWrite <='1'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "00"; PCSrc <= '0'; JRSrc <= 'X'; JALSrc <= '0'; RegDst_JAL <= '0'; rst_jumps <= '0'; 
								if (IME_op = '1') then -- ADDI
													RegDst <= '0'; ALUSrc <= '1'; MemtoReg <= '0'; RegWrite <='1'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "01"; PCSrc <= '0'; JRSrc <= 'X'; JALSrc <= '0'; RegDst_JAL <= '0'; rst_jumps <= '0'; 
								end if;

						when J => RegDst <= 'X'; ALUSrc <= '0'; MemtoReg <= 'X'; RegWrite <='0'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "XX"; PCSrc <= '1'; JRSrc <= '0'; 	JALSrc <= '1'; RegDst_JAL <= 'X'; rst_jumps <= '1'; -- JUMP

						when JAL => RegDst <= '0'; ALUSrc <= '0'; MemtoReg <= '0'; RegWrite <='1'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "01"; PCSrc <= '1'; 	JRSrc <= '0'; JALSrc <= '1'; RegDst_JAL <= '1'; rst_jumps <= '1'; -- JAL

						when others => RegDst <= '0'; ALUSrc <= '0'; MemtoReg <= '0'; RegWrite <='0'; MemRead<='0'; MemWrite<='0'; Branch<='0'; ALUOp <= "00"; PCSrc <= '0'; JRSrc <= '0'; JALSrc <= '0'; RegDst_JAL <= '0'; rst_jumps <= '0'; 

			end case;
    end process;

end arq_control_pipeline;
