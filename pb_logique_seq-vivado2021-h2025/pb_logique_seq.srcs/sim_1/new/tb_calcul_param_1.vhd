----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2025 09:19:12 PM
-- Design Name: 
-- Module Name: tb_calcul_param_1 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_calcul_param_1 is
--  Port ( );
end tb_calcul_param_1;

architecture Behavioral of tb_calcul_param_1 is

    component calcul_param_1
        Port (
            i_bclk  : in  std_logic;
            i_reset : in  std_logic;
            i_en    : in  std_logic;
            i_ech   : in  std_logic_vector (23 downto 0);
            o_param   : out  std_logic_vector (7 downto 0)    -- valeur de période (approximée)
        );
    end component;

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal en      : std_logic := '0';
    signal ech     : std_logic_vector(23 downto 0) := (others => '0');
    signal param   : std_logic_vector(7 downto 0);


    constant clk_period : time := 10 ns;

    -- Table de valeurs de la sinusoïde (exemple avec 20 échantillons)
    type sin_table_type is array (0 to 63) of integer;
    constant sin_table : sin_table_type := (
        0,  707106,  1000000,  707106,  0,
        -707106, -1000000, -707106, 0, 707106,
        1000000, 707106, 0, -707106, -1000000,
        -707106, 0,  707106,  1000000,  707106,  0,
        -707106, -1000000, -707106, 0, 707106,
        1000000, 707106, 0, -707106, -1000000,
        -707106, 0,  707106,  1000000,  707106,  0,
        -707106, -1000000, -707106, 0, 707106,
        1000000, 707106, 0, -707106, -1000000,
        -707106, 0,  707106,  1000000,  707106,  0,
        -707106, -1000000, -707106, 0, 707106,
        1000000, 707106, 0, -707106, -1000000,
        -707106
    );

begin

    uut: calcul_param_1
        port map (
            i_bclk  => clk,
            i_reset => rst,
            i_en    => en,
            i_ech   => ech,
            o_param => param
        );

    clk_proc: process
    begin
        while now < 5 ms loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
        -- Reset
        rst <= '1';
        wait for 50 ns;
        rst <= '0';

        -- Envoie des échantillons
        for i in 0 to 63 loop
            wait for clk_period;

            -- Conversion de l'entier en std_logic_vector signé 24 bits
            ech <= std_logic_vector(to_signed(sin_table(i), 24));
            en  <= '1';

            wait for clk_period;
            en <= '0';
        end loop;

        wait;
    end process;

end Behavioral;
