
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
    signal sum: unsigned(63 downto 0) := (others => '0');
    signal input: unsigned (63 downto 0); 
    signal EtatNext, EtatCourant : type_etat ;

---------------------------------------------------------------------------------------------
--    Description comportementale
---------------------------------------------------------------------------------------------
begin 

    trasitions: process (i_bclk, EtatCourant, i_ech, sum)
    begin
        if (rising_edge(i_bclk)) then
            input <= resize(unsigned(i_ech), 64);
            
            if(i_reset = '1') then
                EtatCourant <= INIT;
                sum <= to_unsigned(0, 64);
                o_param <= "00000000";
            else
                EtatCourant <= EtatNext;
            end if;
            case (EtatCourant) is
                when INIT =>
                    if (i_en = '1') then
                        EtatNext <= SOMMATION;
                    end if;
                when SOMMATION => 
                    EtatNext <= CONVERTION;
                    sum <= ((31/32) * sum) + (input * input);
                when CONVERTION => 
                    EtatNext <= IDLE;
                    o_param <= std_logic_vector(sum(63 downto 56));
                when IDLE =>
                    if (i_en = '1') then
                        EtatNext <= SOMMATION;
                    end if;
                when others =>
            end case;
        end if;
    end process;
    
end Behavioral;
