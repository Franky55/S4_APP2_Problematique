---------------------------------------------------------------------------------------------
-- circuit mef_decod_i2s_v1b.vhd                   Version mise en oeuvre avec des compteurs
---------------------------------------------------------------------------------------------
-- Université de Sherbrooke - Département de GEGI
-- Version         : 1.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 7 mai 2019
-- Auteur(s)       : Daniel Dalle
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2019.1
---------------------------------------------------------------------------------------------
-- Description:
-- MEF pour decodeur I2S version 1b
-- La MEF est substituee par un compteur
--
-- notes
-- frequences (peuvent varier un peu selon les contraintes de mise en oeuvre)
-- i_lrc        ~ 48.    KHz    (~ 20.8    us)
-- d_ac_mclk,   ~ 12.288 MHz    (~ 80,715  ns) (non utilisee dans le codeur)
-- i_bclk       ~ 3,10   MHz    (~ 322,857 ns) freq mclk/4
-- La durée d'une période reclrc est de 64,5 périodes de bclk ...
--
-- Revision  
-- Revision 14 mai 2019 (version ..._v1b) composants dans entités et fichiers distincts
---------------------------------------------------------------------------------------------
-- À faire :
--
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

entity mef_decod_i2s_v1b is
   Port ( 
   i_bclk      : in std_logic;
   i_reset     : in    std_logic; 
   i_lrc       : in std_logic;
   i_cpt_bits  : in std_logic_vector(6 downto 0);
 --  
   o_bit_enable     : out std_logic ;  --
   o_load_left      : out std_logic ;  --
   o_load_right     : out std_logic ;  --
   o_str_dat        : out std_logic ;  --  
   o_cpt_bit_reset  : out std_logic   -- 
   
);
end mef_decod_i2s_v1b;

architecture Behavioral of mef_decod_i2s_v1b is

    type fsm_cI2S_etats is (
         Wait_L,
         Read_L,
         Send_L,
         Wait_R,
         Read_R,
         Send_R
         );
       
   signal fsm_EtatCourant, fsm_prochainEtat : fsm_cI2S_etats;
   signal   d_reclrc_prec  : std_logic ;  --
   signal outputs : std_logic_vector(4 downto 0);
begin

   --Selection d'etat
   select_etat: process(i_bclk, i_reset)
     begin
        if(rising_edge(i_bclk)) then
            if(i_reset = '1') then
                fsm_EtatCourant <= Wait_L;
                --fsm_prochainEtat <= Wait_L;
            else
                fsm_EtatCourant <= fsm_prochainEtat;
            end if;
        end if;
     end process;

   -- pour detecter transitions d_ac_reclrc
   reglrc_I2S: process ( i_bclk)
   begin
   if i_bclk'event and (i_bclk = '1') then
        d_reclrc_prec <= i_lrc;
   end if;
   end process;
   
  -- synch compteur codeur
   rest_cpt: process (i_lrc, d_reclrc_prec, i_reset)
      begin
         o_cpt_bit_reset <= (d_reclrc_prec xor i_lrc) or i_reset;
      end process;
      

    transitionsLecture: process(fsm_EtatCourant, i_bclk, i_cpt_bits, i_lrc)
    begin
        if (rising_edge(i_bclk)) then
            case fsm_EtatCourant is
                when Read_L =>
                    if (i_cpt_bits = 22) then
                        fsm_prochainEtat <= Send_L;
                    end if;
                when Send_L =>
                    fsm_prochainEtat <= Wait_R;
                when Read_R =>
                    if (i_cpt_bits = 22) then
                        fsm_prochainEtat <= Send_R;
                    end if;
                when Send_R =>
                    fsm_prochainEtat <= Wait_L;
                when others =>
            end case;
        end if;
          
        if (falling_edge(i_lrc)) then
            fsm_prochainEtat <= Read_L;
        end if;
        
        if (rising_edge(i_lrc)) then
            fsm_prochainEtat <= Read_R;
        end if;

 end process;
 
    setVariables: process(fsm_EtatCourant)
    begin
        case fsm_EtatCourant is
            when Wait_L     => outputs <= "00101";
            when Read_L     => outputs <= "10000";
            when Send_L     => outputs <= "01010";
            when Wait_R     => outputs <= "01001";
            when Read_R     => outputs <= "10000";
            when Send_R     => outputs <= "00110";
            when others => outputs <= "00001";
        end case;
    end process;
    
    o_bit_enable    <= outputs(4);
    o_load_left     <= outputs(3);
    o_load_right    <= outputs(2);
    o_str_dat     <= outputs(1);
    o_cpt_bit_reset <= outputs(0);

end Behavioral;