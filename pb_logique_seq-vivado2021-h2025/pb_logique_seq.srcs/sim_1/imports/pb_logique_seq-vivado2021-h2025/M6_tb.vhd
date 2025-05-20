library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_calcul_param_2 is
end tb_calcul_param_2;

architecture behavior of tb_calcul_param_2 is

    -- Component Declaration
    component calcul_param_2 is
        Port (
            i_bclk   : in  std_logic;
            i_reset  : in  std_logic;
            i_en     : in  std_logic;
            i_ech    : in  std_logic_vector (23 downto 0);
            o_param  : out std_logic_vector (7 downto 0)
        );
    end component;

    -- Signals for testbench
    signal i_bclk   : std_logic := '0';
    signal i_reset  : std_logic := '1';
    signal i_en     : std_logic := '0';
    signal i_ech    : std_logic_vector(23 downto 0) := (others => '0');
    signal o_param  : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: calcul_param_2
        port map (
            i_bclk   => i_bclk,
            i_reset  => i_reset,
            i_en     => i_en,
            i_ech    => i_ech,
            o_param  => o_param
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            i_bclk <= '0';
            wait for CLK_PERIOD / 2;
            i_bclk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Apply reset
        wait for 20 ns;
        i_reset <= '0';
        wait for 20 ns;

        -- Apply first input sample
        i_en <= '1';
        i_ech <= x"0000FF"; -- Sample input
        wait for CLK_PERIOD;

        -- Apply second input
        i_ech <= x"00FF00";
        wait for CLK_PERIOD;

        -- Apply third input
        i_ech <= x"FF0000";
        wait for CLK_PERIOD;

        i_en <= '0';  -- Disable input
        wait for 50 ns;

        -- Finish simulation
        wait;
    end process;

end behavior;
