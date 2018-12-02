library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity VGA is
port(clk50_in : in std_logic;         -----system clock i/p
       red       : out std_logic;         -----primrary colour output
       green     : out std_logic;
       blue     : out std_logic;
       hs_out   : out std_logic;         ------horizontal control signal
       vs_out   : out std_logic);         ------vertical   control signal
end VGA;
 
architecture Behavioral of VGA is
 
signal clk25             : std_logic;
signal hs : std_logic_vector (9 downto 0);
signal vs : std_logic_vector (9 downto 0);
signal limiteSuperior, limiteInferior, limiteIzquierda, limiteDerecha, limiteLineaA, limiteLineaB, limiteLineaC: std_logic_vector (9 downto 0);
begin
 limiteIzquierda <= "0011001000";
 limiteDerecha <= "1001111110";
 limiteSuperior <= "0001111000";
 limiteInferior <= "0111001000";
 limiteLineaA <=   "0010001100";
 limiteLineaB <=   "0010100000";
 limiteLineaC <=   "0010110100";
 
-- generate a 25Mhz clock
process (clk50_in)
begin
if clk50_in'event and clk50_in='1' then
if (clk25 = '0') then              
 
clk25 <= '1';
else
clk25 <= '0';
end if;
end if;
end process;

process (clk25)
begin
if clk25'event and clk25 = '1' then
if hs = limiteIzquierda and vs >= limiteSuperior and vs <= limiteInferior then ---linea izquierda
red <= '0' ;
blue <= '1';
green <= '0';
elsif hs = limiteDerecha and vs >= limiteSuperior and vs <= limiteInferior then--linea derecha
red <= '0';
blue <= '1'; 
green <= '0';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteSuperior then -- linea arriba / 120
red <= '0'; 
blue<='1';
green <='0';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteInferior then -- linea abajo / 511
red <= '0'; 
blue<='1';
green <='0';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteLineaA then -- linea A 
red <= '0'; 
blue<='1';
green <='0';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteLineaB then -- linea B
red <= '0'; 
blue<='1';
green <='0';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteLineaC then -- linea B
red <= '0'; 
blue<='1';
green <='0';

--------------------------------------------------------------------------------
else                     ----------blank signal display
red <= '0' ;
blue <= '0';
green <= '0' ;
end if;
if (hs > "0000000000" )
and (hs < "0001100001" ) -- 96+1   -----horizontal tracing
then
hs_out <= '0';
else
hs_out <= '1';
end if;
if (vs > "0000000000" )
and (vs < "0000000011" ) -- 2+1   ------vertical tracing
then
vs_out <= '0';
else
vs_out <= '1';
end if;
hs <= hs + "0000000001" ;
if (hs= "1100100000") then     ----incremental of horizontal line
vs <= vs + "0000000001";       ----incremental of vertical line
hs <= "0000000000";
end if;
if (vs= "1000001001") then                 
vs <= "0000000000";
end if;
end if;
end process;
end Behavioral;