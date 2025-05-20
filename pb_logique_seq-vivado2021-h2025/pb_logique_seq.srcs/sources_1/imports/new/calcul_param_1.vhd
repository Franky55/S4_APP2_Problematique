
---------------------------------------------------------------------------------------------
--    calcul_param_1.vhd
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calcul_param_1 is
    Port (
        i_bclk    : in   std_logic; -- horloge BCLK
        i_reset   : in   std_logic;
        i_en      : in   std_logic; -- un nouvel échantillon est disponible
        i_ech     : in   std_logic_vector (23 downto 0); -- échantillon audio
        o_param   : out  std_logic_vector (7 downto 0)    -- valeur de période (approximée)
    );
end calcul_param_1;

architecture Behavioral of calcul_param_1 is
    type etat_type is (IDLE, ACTIF, CHECK, OUTPARAM);
    signal etat, etat_suiv : etat_type;

    signal countCLK : std_logic_vector (7 downto 0) := "00000000";
    signal countUp        : std_logic_vector (1 downto 0) := "00";
    signal last        : std_logic;
    signal countCLK222 : std_logic_vector (7 downto 0) := "00000000" ;
    signal i_ech_Average3 : std_logic_vector (23 downto 0);
    signal i_ech_Average : std_logic_vector (23 downto 0);
    signal i_ech_prev : std_logic_vector (23 downto 0) := i_ech;
    signal i_ech_prevprev : std_logic_vector (23 downto 0) := i_ech;

begin

    process(i_bclk)
    begin
        if rising_edge(i_bclk) then
            countCLK222 <= countCLK222 + 1;
            etat <= etat_suiv;
        end if;
    end process;

    process(i_en, i_ech)
    begin
        if(i_en = '1') then
            i_ech_Average <= i_ech + i_ech_prev + i_ech_prevprev;
            i_ech_Average3 <= std_logic_vector(signed(i_ech_Average) / 3);

            i_ech_prev <= i_ech;
            i_ech_prevprev <= i_ech_prev;
        end if;
    end process;

    process(etat, i_en, countUp)
    begin
         case etat is
            when IDLE =>
                IF(i_en = '1') then
                    etat_suiv <= ACTIF;
                ELSE
                    etat_suiv <= IDLE;
                end if;
            when ACTIF =>
                IF(i_en = '1') then
                    etat_suiv <= CHECK;
                else
                    etat_suiv <= ACTIF;
                end if;
            when CHECK =>
                IF(countUp = "10") then
                     etat_suiv <= OUTPARAM;
                else
                     etat_suiv <= ACTIF;
                end if;
            when OUTPARAM =>
                etat_suiv <= IDLE;
            when others =>
                etat_suiv <= IDLE;
        end case;
    end process;

    process(etat)
    begin
        case etat is
            when IDLE =>
                countCLK <= "00000000";
                countUP <= "00";
                last <= '0';

            when ACTIF =>
                countCLK <= countCLK + 1;
            when CHECK =>
                countCLK <= countCLK + 1;
                if(i_ech_Average3(23) = '1' AND last = '0') then
                    countUP <= countUP + 1;
                end if;
                last <= i_ech_Average3(23);
           when OUTPARAM =>
                if(countUP = "10") then
                    o_param <= countCLK;
                end if;

            when others =>

       end case;
    end process;
end Behavioral;