
---------------------------------------------------------------------------------------------
--    calcul_param_2.vhd   (temporaire)
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--    Université de Sherbrooke - Département de GEGI
--
--    Version         : 5.0
--    Nomenclature    : inspiree de la nomenclature 0.2 GRAMS
--    Date            : 16 janvier 2020, 4 mai 2020
--    Auteur(s)       : 
--    Technologie     : ZYNQ 7000 Zybo Z7-10 (xc7z010clg400-1) 
--    Outils          : vivado 2019.1 64 bits
--
---------------------------------------------------------------------------------------------
--    Description (sur une carte Zybo)
---------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------
-- À FAIRE: 
-- Voir le guide de la problématique
---------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs
USE ieee.numeric_std.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------
entity calcul_param_2 is
    Port (
    i_bclk    : in   std_logic;   -- bit clock
    i_reset   : in   std_logic;
    i_en      : in   std_logic;   -- un echantillon present
    i_ech     : in   std_logic_vector (23 downto 0);
    o_param   : out  std_logic_vector (7 downto 0)                                     
    );
end calcul_param_2;

----------------------------------------------------------------------------------

architecture Behavioral of calcul_param_2 is

    type type_etat is (
        INIT, 
        SOMMATION, 
        CONVERTION,
        IDLE) ;

---------------------------------------------------------------------------------
-- Signaux
----------------------------------------------------------------------------------
    constant multi : unsigned(4 downto 0) := "11111";
    constant div : unsigned(5 downto 0) := "100000";
    
    signal sum: unsigned(47 downto 0) := (others => '0');
    signal division: unsigned(47 downto 0) := (others => '0');
    signal multiplication: unsigned(47 downto 0) := (others => '0');
    signal input: unsigned (47 downto 0); 
    signal EtatNext, EtatCourant : type_etat ;
    

---------------------------------------------------------------------------------------------
--    Description comportementale
---------------------------------------------------------------------------------------------
begin 

--    process (i_bclk)
--    begin
--        if rising_edge(i_bclk) then
--            if i_reset = '1' then
--                sum <= (others => '0');
--                o_param <= (others => '0');
--            elsif i_en = '1' then
--                input <= unsigned(signed(i_ech) * signed(i_ech));
--                multiplication <= RESIZE(multi * sum, 48);
--                division <= RESIZE(multiplication / div, 48);
--                sum <= division + input;
--                o_param <= std_logic_vector(sum(47 downto 40));
--            end if;
--        end if;
--    end process;


    trasitions: process (i_bclk, EtatCourant, i_ech, sum, input)
    begin
            if(i_reset = '1') then
                sum <= to_unsigned(0, 48);
                o_param <= "00000000";
            end if;
            if (i_en = '1') then
                input <= UNSIGNED(signed(i_ech) * signed(i_ech));
                --multiplication <= RESIZE((multi * sum), 48);
                if (sum > 0) then
                    division <= RESIZE(((multi * sum) / div), 48);
                else
                    division <= to_unsigned(0, 48);
                end if;
                sum <= division + input;
                o_param <= std_logic_vector(sum(47 downto 40));
            end if;
            
--        if (rising_edge(i_bclk)) then
--            input <= unsigned(signed(i_ech) * signed(i_ech));
            
--            if(i_reset = '1') then
--                EtatCourant <= INIT;
--                sum <= to_unsigned(0, 48);
--                o_param <= "00000000";
--            else
--                EtatCourant <= EtatNext;
--            end if;
--            case (EtatCourant) is
--                when INIT =>
--                    if (i_en = '1') then
--                        EtatNext <= SOMMATION;
--                    end if;
--                when SOMMATION => 
--                    EtatNext <= CONVERTION;
--                    sum <= RESIZE(((multi * sum) / div), 48) + input;
--                when CONVERTION => 
--                    EtatNext <= IDLE;
--                    o_param <= std_logic_vector(sum(47 downto 40));
--                when IDLE =>
--                    if (i_en = '1') then
--                        EtatNext <= SOMMATION;
--                    end if;
--                when others =>
--            end case;
--        end if;
    end process;
    
end Behavioral;
