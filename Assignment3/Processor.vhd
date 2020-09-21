library IEEE;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Processor is
     Port(
         clk: in std_logic
     );
end Processor;

architecture Behavioural of Processor is
   --signal clk : std_logic := '0';
    constant clk_period : time := 2 ns;

    type Register_type is array(0 to 31) of std_logic_vector(31 downto 0);
    type Memory_type is array( 0 to 4095) of std_logic_vector(31 downto 0);

    -- Read a *.bin file
    impure function Initialize_mem(FileName : STRING) return Memory_type is
      file FileHandle       : TEXT open READ_MODE is FileName;
      variable CurrentLine  : LINE;
      variable TempWord     : STD_LOGIC_VECTOR(31 downto 0);
      variable Result       : Memory_type    := (others => (others => '0'));
      variable c: character;
    begin
        for i in 0 to 4095 loop
            exit when endfile(FileHandle);
            readline(FileHandle, CurrentLine);
            for j in 31 downto 0 loop
                read(CurrentLine, c);
                case c is
                    when '0' => TempWord(j) := '0';
                    when '1' => TempWord(j) := '1';
                    when others => TempWord(j) := '0';
                end case;
            end loop;
            Result(i):= TempWord;
        end loop;
        return Result;
    end function;

    -- Read a *.bin file
    impure function Initialize_reg(FileName : STRING) return Register_type is
      file FileHandle       : TEXT open READ_MODE is FileName;
      variable CurrentLine  : LINE;
      variable TempWord     : STD_LOGIC_VECTOR(31 downto 0);
      variable Result       : Register_type    := (others => (others => '0'));
      variable c: character;
    begin
        for i in 0 to 31 loop
            exit when endfile(FileHandle);
            readline(FileHandle, CurrentLine);
            for j in 31 downto 0 loop
                read(CurrentLine, c);
                case c is
                    when '0' => TempWord(j) := '0';
                    when '1' => TempWord(j) := '1';
                    when others => TempWord(j) := '0';
                end case;
            end loop;
            Result(i):= TempWord;
        end loop;
        return Result;
    end function;

    signal reg : Register_type := Initialize_reg("/Users/diwakarprajapati/Desktop/COL/COL216/Assignments/Assignment3/Regin.txt");
    signal mem : Memory_type := Initialize_mem("/Users/diwakarprajapati/Desktop/COL/COL216/Assignments/Assignment3/Input.txt");
    signal zero: std_logic_vector(31 downto 0):= x"00000000";
    signal flag: std_logic := '1';
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
    signal i: integer := 0;
    signal started: integer := 0;


begin
    process(clk)
    --variable i:integer:=-1;
    begin
        if(flag='1') then
            if(rising_edge(clk)) then
                if(mem(i)=zero) then
                    flag<='0';
                else
                    i<=i+1;
                    op <= mem(i)(31 downto 26);
                    rs<=mem(i)(25 downto 21);
                    rt<=mem(i)(20 downto 16);
                    rd<=mem(i)(15 downto 11);
                    func<= mem(i)(5 downto 0);
                    addr <= mem(i)(15 downto 0);
                    shamt <= mem(i)(10 downto 6);
                    index_rd <= to_integer(unsigned(mem(i)(15 downto 11)));
                    index_rt <= to_integer(unsigned(mem(i)(20 downto 16)));
                    index_rs <= to_integer(unsigned(mem(i)(25 downto 21)));
                    index_shamt <= to_integer(unsigned(mem(i)(10 downto 6)));
                    index_addr <= to_integer(unsigned(reg(to_integer(unsigned(mem(i)(25 downto 21))))+ mem(i)(15 downto 0)));
                    if(op="000000") then
                        if(func="100000") then
                            reg(index_rd) <= reg(index_rs)+ reg(index_rt);
                        elsif(func="100010") then
                            reg(index_rd) <= reg(index_rs) - reg(index_rt);
                        elsif(func="000000") then
                            reg(index_rd) <= std_logic_vector(shift_left(unsigned(reg(index_rt)), index_shamt));
                        elsif(func="000010") then
                            reg(index_rd) <= std_logic_vector(shift_right(unsigned(reg(index_rt)), index_shamt));
                        end if;
                    else
                        if(op="100011") then
                             reg(index_rt) <= mem(index_addr);
                        elsif(op="101011") then
                            if (index_addr < 1000 or index_addr > 4095) then
                                flag<='0';
                            else
                                mem(index_addr) <= reg(index_rt);
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    process
    begin
        wait for clk_period/2; --half of the clock period
        clk <= not clk;
    end process;

end Behavioural;
