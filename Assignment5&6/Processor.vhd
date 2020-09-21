----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.02.2020 19:38:31
-- Design Name: 
-- Module Name: Processor - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Processor is
--Takes a clock and executes the instructions in the memory
    Port (       
        clk: in std_logic;
        display: out std_logic_vector(15 downto 0);
        clock_display: out std_logic_vector(15 downto 0)
    );
end Processor;

architecture Behavioral of Processor is
--    --Clock Generation for Simulation
--    signal clk : std_logic := '0';
--    constant clk_period : time := 2 ns;
    
    --BRAM
    COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

    --Register File
    type Register_type is array(0 to 31) of std_logic_vector(31 downto 0);
    signal reg : Register_type := ("00000000000000000000000000001000",
                                   "00000000000000000000000000000010",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000",
                                   "00000000000000000001000000000000",--$sp: Initialize $sp with 4096
                                   "00000000000000000000000000000000",
                                   "00000000000000000000000000000000" --$ra
                                  );

    --States
    type inst_fetch_state_type is (idle,fetch,fetched_lw,fetched_sw,fetched_branch,end_fetch);
    signal fetch_state : inst_fetch_state_type := idle;

    type inst_exec_state_type is (idleex,execute,load,store,branch,end_execute);
    signal exec_state : inst_exec_state_type := idleex;

    --Memory Instantiation Signals
    signal addra : STD_LOGIC_VECTOR(11 DOWNTO 0); --Memory read/write is performed here
    --Signals for writing to memory
    signal write_enable : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    signal wr_index : integer := 0; --Where to write
    signal data_write : std_logic_vector(31 downto 0);
    --Signals for reading from memory
    signal read_enable : std_logic := '1';
    signal rd_index : integer := 0; --Where to read from
    signal data_read : std_logic_vector(31 downto 0) := "11111111111111111111111111111111"; --What is read
    
    signal instruction : std_logic_vector(31 downto 0) := "11111111111111111111111111111111"; --That is to be executed if the exec_State = execute
    signal saved_instruction : std_logic_vector(31 downto 0) := "11111111111111111111111111111111"; --Save instruction if there is a load or store

    signal is_fetch_lw : boolean := false;
    signal is_fetch_sw : boolean := false;
    signal saved : boolean := false;
    signal to_load : boolean := false;

    signal ld_index : integer := 0;
    
    --Special Instructions
    constant zero: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
    constant ones: std_logic_vector(31 downto 0):= "11111111111111111111111111111111";
    
    signal pc: integer := 0; --Program Counter: Instruction at pc is fetched in this cycle for execution after the execution of the pc-1 th (current) instruction

    --Instruction Decoding Signals
    signal op: std_logic_vector(5 downto 0):= "000000";
    signal rs: std_logic_vector(4 downto 0):= "00000";
    signal rt: std_logic_vector(4 downto 0):= "00000";
    signal rd: std_logic_vector(4 downto 0):= "00000";
    signal shamt: std_logic_vector(4 downto 0):= "00000";
    signal func: std_logic_vector(5 downto 0):= "000000";
    signal addr: std_logic_vector(15 downto 0):= "0000000000000000";
    signal index_rs: integer := 0;
    signal index_rt: integer := 0;
    signal index_rd: integer := 0;
    signal index_shamt: integer := 0;
    signal index_addr: integer := 0;
    signal target_26: integer := 0;
    signal label_16: integer := 0;
    
    --Taking Care of load-- BRAM delay in giving data_read
    signal data_rs : std_logic_vector(31 downto 0);
    signal data_rt : std_logic_vector(31 downto 0);
    signal data_add : std_logic_vector(31 downto 0);
    signal data_sub : std_logic_vector(31 downto 0);
    signal data_sll : std_logic_vector(31 downto 0);
    signal data_srl : std_logic_vector(31 downto 0);

    --Output Signals
    signal clock_display_counter : std_logic_vector(15 downto 0):="0000000000000000";
    
begin

    bram_instantiation : blk_mem_gen_0
  PORT MAP (
    clka => clk,
    wea => write_enable,
    addra => addra,
    dina => data_write,
    douta => data_read
  );

    instruction <= saved_instruction when saved else data_read;

    addra <= std_logic_vector(to_unsigned(rd_index, 12)) when read_enable ='1' else 
             std_logic_vector(to_unsigned(wr_index, 12));

    --Instruction Fetch Process
    --Changes pc, rd_index and lw_data
    process(clk)
    begin
        if (rising_edge(clk)) then
            case fetch_state is
                when idle => --Initial State
                    fetch_state <= fetch;
                    pc<=pc+1;
                    rd_index<=pc+1;
                when fetch => --fetch ith instruction
                    --if last instruction fetched was lw/sw change state
                    --Do not update instruction and don not change pc
                    pc <= pc+1;                    
                    rd_index<=pc+1;
                    if (saved) then
                        saved <= false;
                    end if ;
                    if (instruction = zero) then
                        fetch_state <= end_fetch;
                    elsif (op = "100011") then
                        fetch_state <= fetched_lw;
                        rd_index <= to_integer(unsigned(reg(to_integer(unsigned(instruction(25 downto 21))))+ instruction(15 downto 0)));
                        is_fetch_lw <= true;
                    elsif (op = "101011") then
                        fetch_state <= fetched_sw;
                        is_fetch_sw <= true;
                    elsif (op = "000000" and rt = "00000" and rd = "00000" and shamt = "00000" and func = "001000") then --jr rs
                        fetch_state <= fetched_branch;
                        pc <= to_integer(unsigned(data_rs));
                        rd_index <= to_integer(unsigned(data_rs));
                    elsif (op = "000010") then --j target
                        fetch_state <= fetched_branch;
                        pc <= target_26;
                        rd_index <= target_26;
                    elsif (op = "000011") then --jal target
                        fetch_state <= fetched_branch;
                        pc <= target_26;
                        rd_index <= target_26;
                    elsif (op = "000100" and data_rs = data_rt) then --beq rs rt label
                        fetch_state <= fetched_branch;
                        pc <= label_16;
                        rd_index <= label_16;
                    elsif (op = "000101" and data_rs /= data_rt) then --bne rs rt label
                        fetch_state <= fetched_branch;
                        pc <= label_16;
                        rd_index <= label_16;
                    elsif (op = "000110" and rt = "00000" and to_integer(unsigned(data_rs)) <= 0) then --blez rs label
                        fetch_state <= fetched_branch;
                        pc <= label_16;
                        rd_index <= label_16;
                    elsif (op = "000111" and rt = "00000" and to_integer(unsigned(data_rs)) > 0) then --bgtz rs label
                        fetch_state <= fetched_branch;
                        pc <= label_16;
                        rd_index <= label_16;
                    end if;
                when fetched_lw => --instruction will be saved this cycle
                    --Fetch the data to be loaded
                    fetch_state <= fetch;
                    rd_index <= pc; --Not pc+1 because in the next state pc will remain pc
                    is_fetch_lw <= false;
                    --Save Instruction
                    saved_instruction <= instruction;
                    saved <= true;
                when fetched_sw => --instruction will be saved this cycle
                    --Wait
                    fetch_state <= fetch;
                    is_fetch_sw <= false;
                    --Save Instruction
                    saved_instruction <= instruction;
                    saved <= true;
                when fetched_branch => --instruction after jumping will be fetched in this state in 1 cycle
                    fetch_state <= fetch;
                    pc<=pc+1;
                    rd_index<=pc+1;
                when others =>
            end case;
        end if;
    end process;

    op <= instruction(31 downto 26);
    rs<=instruction(25 downto 21);
    rt<=instruction(20 downto 16);
    rd<=instruction(15 downto 11);
    func<= instruction(5 downto 0);
    addr <= instruction(15 downto 0);
    shamt <= instruction(10 downto 6);
    index_rd <= to_integer(unsigned(instruction(15 downto 11)));
    index_rt <= to_integer(unsigned(instruction(20 downto 16)));
    index_rs <= to_integer(unsigned(instruction(25 downto 21)));
    index_shamt <= to_integer(unsigned(instruction(10 downto 6)));
    index_addr <= to_integer(unsigned(reg(to_integer(unsigned(instruction(25 downto 21))))+ instruction(15 downto 0)));
    target_26 <= to_integer(unsigned(instruction(25 downto 0)));
    label_16 <= to_integer(unsigned(instruction(15 downto 0)));


    --reg(ld_index) <= data_read when to_load else reg(ld_index);
    
    --If rs/rt is same as the loaded register then take the value in data_read instead of register value    
    --If rd is the same as the loaded register then take care by assigning the new value later
    data_rs <= data_read when (ld_index=index_rs and to_load) else reg(index_rs);
    data_rt <= data_read when (ld_index=index_rt and to_load) else reg(index_rt);
    data_add <= data_rs + data_rt;--reg(index_rs)+ reg(index_rt);
    data_sub <= data_rs - data_rt;--reg(index_rs) - reg(index_rt);
    data_sll <= std_logic_vector(shift_left(unsigned(data_rt), index_shamt));--std_logic_vector(shift_left(unsigned(reg(index_rt)), index_shamt));
    data_srl <= std_logic_vector(shift_right(unsigned(data_rt), index_shamt));--std_logic_vector(shift_right(unsigned(reg(index_rt)), index_shamt));
    

    --Instruction Execution Process
    --Changes reg, display and clock_display_counter
    --Changes register file and data_write depending on what instruction is
    process(clk)
    begin
        if (rising_edge(clk)) then
            clock_display_counter <= clock_display_counter + "0000000000000001";
            case exec_state  is        
                when idleex => 
                    exec_state <= execute;
                when execute => --instruction will be executed in this cycle
                    if (to_load) then
                        reg(ld_index) <= data_read;
                        display <= data_read(15 downto 0); --Displaying lw only when next instruction does not override display
                        to_load <= false;      
                    end if ;     
                    if (instruction = zero) then
                        clock_display <= clock_display_counter;
                        exec_state <= end_execute;
                        read_enable <= '0';
                    elsif(op="000000" and func="100000") then --add rd, rs, rt
                        reg(index_rd) <= data_add;
                        display <= data_add(15 downto 0); --Displaying add
                    elsif(op="000000" and func="100010") then
                        reg(index_rd) <= data_sub;
                        display <= data_sub(15 downto 0); --Displaying sub
                    elsif(op="000000" and func="000000") then --sll rd, rt, shamt
                        reg(index_rd) <= data_sll;
                        display <= data_sll(15 downto 0); --Displaying sll
                    elsif(op="000000" and func="000010") then --srl rd, rt, shamt
                        reg(index_rd) <= data_srl;
                        display <= data_srl(15 downto 0); --Displaying srl
                    elsif(op="100011") then --lw rt, address
                        ld_index <= index_rt;
                        exec_state <= load;
                    elsif(op="101011") then                        
                        if (index_addr < 1000 or index_addr > 4095) then
                            exec_state <= end_execute;
                        else
                            wr_index <= to_integer(unsigned(reg(to_integer(unsigned(instruction(25 downto 21))))+ instruction(15 downto 0)));
                            exec_state <= store;
                            write_enable <= "1";
                            read_enable <= '0';
                            data_write <= data_rt;
                            display <= data_rt(15 downto 0); --Displaying sw
                        end if;
                    elsif (op = "000000" and rt = "00000" and rd = "00000" and shamt = "00000" and func = "001000") then --jr rs
                        exec_state <= branch;
                    elsif (op = "000010") then --j target
                        exec_state <= branch;
                    elsif (op = "000011") then --jal target
                        exec_state <= branch;
                        reg(31) <= std_logic_vector(to_unsigned(pc, 32));
                    elsif (op = "000100" and data_rs = data_rt) then --beq rs rt label
                        exec_state <= branch;
                    elsif (op = "000101" and data_rs /= data_rt) then --bne rs rt label
                        exec_state <= branch;
                    elsif (op = "000110" and rt = "00000" and to_integer(unsigned(data_rs)) <= 0) then --blez rs label
                        exec_state <= branch;
                    elsif (op = "000111" and rt = "00000" and to_integer(unsigned(data_rs)) > 0) then --bgtz rs label
                        exec_state <= branch;
                    end if;
                when load =>
                    to_load <= true;
                    exec_state <= execute;
                when store =>
                    write_enable <= "0";
                    read_enable <= '1';
                    exec_state <= execute;                
                when branch => --Do not execute whatever is in instruction as it is junk => no need to save
                    exec_state <= execute;
                when others =>
            end case ;
        end if;
    end process;
    
    --Clock Generation Process
--    process
--    begin
--        wait for clk_period/2; --half of the clock period
--        clk <= not clk;
--    end process;
    
end Behavioral;