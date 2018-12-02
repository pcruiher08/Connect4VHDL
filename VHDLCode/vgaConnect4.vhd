library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity clk1Hz is
    port (clk1 : in std_logic;
           clk : out std_logic
         );
    end clk1Hz;
    
    architecture Behavioral of digi_clk is
    
    signal count : integer :=1;
    signal clk : std_logic :='0';
    
    
     --clk generation.For 50 MHz clock this generates 1 Hz clock.
    process(clk1) 
    begin
    if(clk1'event and clk1='1') then
    count <=count+1;
    if(count = 25000000) then
    clk <= not clk;
    count <=1;
    end if;
    end if;
    end process;
end Behavioral;

entity VGA is
port(clk50_in : in std_logic;         -----system clock i/p
       red       : out std_logic;         -----primrary colour output
       green     : out std_logic;
       blue     : out std_logic;
       hs_out   : out std_logic;         ------horizontal control signal
       vs_out   : out std_logic);         ------vertical   control signal
end VGA;
 
architecture Behavioral of VGA is
 --vga
signal clk25             : std_logic;
signal hs : std_logic_vector (9 downto 0);
signal vs : std_logic_vector (9 downto 0);
--Signals del juego

signal clk1Hert: std_logic;

--limitesCuadricula
signal limiteSuperior, limiteInferior, limiteIzquierda, 
limiteDerecha, limiteLineaA, limiteLineaB, limiteLineaC: std_logic_vector (9 downto 0);
signal limiteLinea1, limiteLinea2, limiteLinea3: std_logic_vector(9 downto 0);

--filas
signal fila1Rojo, fila2Rojo, fila3Rojo, fila4Rojo: bit_vector(3 downto 0);
signal fila1Amarillo, fila2Amarillo, fila3Amarillo, fila4Amarillo: bit_vector(3 downto 0);
signal fila1General, fila2General, fila3General, fila4General: bit_vector(3 downto 0);

--columnas
signal columna1Rojo, columna2Rojo, columna3Rojo, columna4Rojo: bit_vector(3 downto 0);
signal columna1Amarillo, columna2Amarillo, columna3Amarillo, columna4Amarillo: bit_vector(3 downto 0);
signal columna1General, columna2General, columna3General, columna4General: bit_vector(3 downto 0);

signal indices: std_logic_vector(3 downto 0);

begin
--cuadricula
 limiteIzquierda <= "0011011100"; --220
 limiteDerecha  <=  "1001011000"; --600
 limiteSuperior <=  "0001111000"; --120
 limiteInferior <=  "0111110100"; --500
 limiteLineaA   <=  "0011010111"; --120+(500-120)/4
 limiteLineaB   <=  "0100110110"; --120+2*(500-120)/4
 limiteLineaC   <=  "0110010101"; --120+3*(500-120)/4
 limiteLinea1   <=  "0100111011"; --220+(600-220)/4
 limiteLinea2   <=  "0110011010"; --220+2*(600-220)/4
 limiteLinea3   <=  "0111111001"; --220+3*(600-220)/4
 
-- generate a 25Mhz clock
process (clk50_in)
begin
    --divisor de frecuencia 50 a 25
if clk50_in'event and clk50_in='1' then
if (clk25 = '0') then              
 
clk25 <= '1';
else
clk25 <= '0';
end if;
end if;
end process;

process(clk50_in)
begin
    port_map(clk50_in, clk1Hert);
end process;

process (clk25)
begin
if clk25'event and clk25 = '1' then
if hs = limiteIzquierda and vs >= limiteSuperior and vs <= limiteInferior then ---linea izquierda
red <= '0' ;
blue <= '1';
green <= '1';
elsif hs = limiteDerecha and vs >= limiteSuperior and vs <= limiteInferior then--linea derecha
red <= '0';
blue <= '1'; 
green <= '1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteSuperior then -- linea arriba / 120
red <= '0'; 
blue<='1';
green <='1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteInferior then -- linea abajo / 511
red <= '0'; 
blue<='1';
green <='1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteLineaA then -- linea A 
red <= '0'; 
blue<='1';
green <='1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteLineaB then -- linea B
red <= '0'; 
blue<='1';
green <='1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteLineaC then -- linea B
red <= '0'; 
blue<='1';
green <='1';
elsif hs = limiteLinea1 and vs >= limiteSuperior and vs <= limiteInferior then--linea derecha
red <= '0';
blue <= '1'; 
green <= '1';
elsif hs = limiteLinea2 and vs >= limiteSuperior and vs <= limiteInferior then--linea derecha
red <= '0';
blue <= '1'; 
green <= '1';
elsif hs = limiteLinea3 and vs >= limiteSuperior and vs <= limiteInferior then--linea derecha
red <= '0';
blue <= '1'; 
green <= '1';
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