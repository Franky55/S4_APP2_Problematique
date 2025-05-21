
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
    type etat_type is (IDLE, CHECK_PASSE_ZERO, CHECK_PERIODE, COUNT, OUTPARAM);
    signal etat_courant, etat_suiv : etat_type;

    signal countCLK         : std_logic_vector (7 downto 0) := "00000000";
    signal signal_output    : std_logic_vector (7 downto 0) := "00000000";
    signal count_transition_zero : std_logic_vector (1 downto 0) := "00";
    signal last_data_MSB    : std_logic;
    signal count_CLK_period : std_logic_vector (7 downto 0) := "00000000" ;
    signal i_ech_Average3   : std_logic_vector (23 downto 0);
    signal i_ech_Average    : std_logic_vector (23 downto 0);
    signal i_ech_prev       : std_logic_vector (23 downto 0) := i_ech;
    signal i_ech_prev_prev  : std_logic_vector (23 downto 0) := i_ech;

begin

    compteur_etat: process(i_bclk)
    begin
        if rising_edge(i_bclk) then
            if (i_reset = '1') then
                etat_courant <= IDLE;
                
            else
                etat_courant <= etat_suiv;
            end if;
        end if;
    end process;

    average: process(i_en, i_ech)
    begin
        if(i_en = '1') then
            i_ech_Average <= i_ech + i_ech_prev + i_ech_prev_prev;
            i_ech_Average3 <= std_logic_vector(signed(i_ech_Average) / 3);

            i_ech_prev <= i_ech;
            i_ech_prev_prev <= i_ech_prev;
        end if;
    end process;

    process(i_bclk, etat_courant, i_en, count_transition_zero, i_ech_Average3(23), last_data_MSB)
    begin
         case etat_courant is
            when IDLE =>
                if(i_en = '1') then
                    etat_suiv <= CHECK_PASSE_ZERO;
                end if;
            when CHECK_PASSE_ZERO =>
                if(i_en = '1' AND i_ech_Average3(23) = '1' AND last_data_MSB = '0') then
                    etat_suiv <= COUNT;
                elsif(i_en = '1') then
                    etat_suiv <= CHECK_PERIODE;
                else
                    etat_suiv <= CHECK_PASSE_ZERO;
                end if;
            when CHECK_PERIODE =>
                if(count_transition_zero = 2) then
                     etat_suiv <= OUTPARAM;
                else
                     etat_suiv <= CHECK_PASSE_ZERO;
                end if;
            when COUNT =>
                etat_suiv <= CHECK_PASSE_ZERO;
            when OUTPARAM =>
                if rising_edge(i_bclk) then
                    etat_suiv <= IDLE;
                end if;
            when others =>
                if rising_edge(i_bclk) then
                    etat_suiv <= IDLE;
                end if;
        end case;
    end process;

    process(etat_courant)
    begin
        case etat_courant is
            when IDLE =>
                countCLK <= "00000000";
                count_transition_zero <= "00";
                last_data_MSB <= '0';

            when CHECK_PASSE_ZERO =>
                countCLK <= countCLK + 1;
            when CHECK_PERIODE =>
                countCLK <= countCLK + 1;
                last_data_MSB <= i_ech_Average3(23);
            when COUNT =>
                countCLK <= countCLK + 1;
                count_transition_zero <= count_transition_zero + 1;
                last_data_MSB <= i_ech_Average3(23);
           when OUTPARAM =>
                signal_output <= countCLK;
           when others =>

       end case;
    end process;
    
    o_param <= signal_output;
end Behavioral;