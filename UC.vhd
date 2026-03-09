library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component IFetch is
  Port (Jump: in std_logic;
        JumpAddress: in std_logic_vector(31 downto 0);
        PCSrc: in std_logic;
        BranchAddress: in std_logic_vector(31 downto 0);
        EN: in std_logic;
        RST: in std_logic;
        CLK: in std_logic;
        PC: out std_logic_vector(31 downto 0);
        Instruction: out std_logic_vector(31 downto 0));
end component;

component ID is
  Port (RegWrite:in std_logic;
        Instr: in std_logic_vector(25 downto 0);
        RegDst: in std_logic;
        CLK: in std_logic;
        en: in std_logic;
        ExtOp: in std_logic;
        RD1: out std_logic_vector(31 downto 0);
        RD2: out std_logic_vector(31 downto 0);
        WD: in std_logic_vector(31 downto 0);
        Ext_Imm: out std_logic_vector(31 downto 0);
        func: out std_logic_vector(5 downto 0);
        sa: out std_logic_vector(4 downto 0));
end component;

component EX is
  Port (   ALUSrc : in STD_LOGIC;
           RD1 : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           PC4 : in STD_LOGIC_VECTOR (31 downto 0);
           ALURes : out STD_LOGIC_VECTOR (31 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0);
           Zero : out STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR (1 downto 0));
end component;

component MEM is
    Port ( MemWrite: in std_logic;
           ALUResIN : in std_logic_vector(31 downto 0);
           RD2 : in std_logic_vector(31 downto 0);
           CLK : in std_logic;
           EN : in std_logic;
           MemData : out std_logic_vector(31 downto 0);
           ALUResOUT: out std_logic_vector(31 downto 0));
end component;

component UC is
  Port ( Instr: in std_logic_vector(5 downto 0);
         RegDst: out std_logic;
         ExtOp: out std_logic;
         ALUSrc: out std_logic;
         Branch: out std_logic;
         Jump: out std_logic;
         ALUOp: out std_logic_vector(1 downto 0);
         MemWrite: out std_logic;
         MemtoReg : out std_logic;
         RegWrite : out std_logic
         );
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;


--Signals
signal EN : std_logic;
--signals IFetch
signal Jump : std_logic;
signal JumpAddress: std_logic_vector(31 downto 0) := (others =>'0');
signal PCSrc : std_logic;
signal BranchAddress : std_logic_vector(31 downto 0) := (others =>'0');
signal Instruction : std_logic_vector(31 downto 0):=(others =>'0');
signal PC : std_logic_vector(31 downto 0) := (others => '0');
-- signals ID
signal RegWrite: std_logic;
signal RegDst: std_logic;
signal ExtOp: std_logic;
signal RD1 : std_logic_vector(31 downto 0):= (others =>'0');
signal RD2: std_logic_vector(31 downto 0):= (others =>'0');
signal WD : std_logic_vector(31 downto 0):= (others =>'0');
signal Ext_Imm: std_logic_vector(31 downto 0):= (others =>'0');
signal func: std_logic_vector(5 downto 0):= (others =>'0');
signal sa: std_logic_vector(4 downto 0 ):= (others =>'0');
--signals EX
signal ALUSrc: std_logic;
signal ALURes : std_logic_vector(31 downto 0):=(others => '0');
signal Zero : std_logic;
signal ALUOp:  std_logic_vector(1 downto 0);
--signals MEM
signal MemWrite: std_logic;
signal MemData: std_logic_vector(31 downto 0):= (others =>'0');
signal ALUResOUT: std_logic_vector(31 downto 0):= (others =>'0');
--signals UC
signal Branch : std_logic;
signal MemtoReg : std_logic;

signal DIGITS : std_logic_vector(31 downto 0);
begin

JumpAddress <= Pc(31 downto 28) & Instruction(25 downto 0) & "00";
PCSrc <= Zero AND Branch;

Componenta1_MPG: MPG port map(EN , btn(0), clk);
Componenta2_IFetch: IFetch port map(Jump, JumpAddress, PCSrc, BranchAddress, EN, btn(1), clk, PC, Instruction);
Componenta3_ID : ID port map(regWrite,  Instruction(25 downto 0), RegDst, clk, EN, ExtOp,RD1, RD2, WD, Ext_Imm, func, sa);
Componenta4_EX: EX port map(ALUSrc, RD1, RD2, Ext_Imm, func, sa, PC, ALURes, BranchAddress, Zero, ALUOp);
Componenta5_MEM: MEM port map(MemWrite, ALURes, RD2, clk, EN, MemData, ALUResOut);
Componenta6_UC : UC port map(Instruction(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);

WD <= ALUResOUT when MemtoReg = '0' else MemData;

process(sw(7 downto 5))
begin 
    case sw(7 downto 5) is
        when "000" => DIGITS <= Instruction;
        when "001" => DIGITS <= PC;
        when "010" => DIGITS <= RD1;
        when "011" => DIGITS <= RD2;
        when "100" => DIGITS <= Ext_Imm;
        when "101" => DIGITS <= ALURes;
        when "110" => DIGITS <= MemData;
        when others => DIGITS <= WD;
     end case;
end process;

Componenta7_SDD: SSD port map(clk, DIGITS, an,cat);

led(9 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & Memtoreg & RegWrite;
end Behavioral;