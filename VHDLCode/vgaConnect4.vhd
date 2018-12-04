library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity clk1Hz is
    port (clk1 : in std_logic;
           clk : out std_logic
         );
    end clk1Hz;
    architecture comp of clk1Hz is
    signal count : integer :=1;
    signal clock : std_logic :='0';
    begin
     --clk generation.For 50 MHz clock this generates 1 Hz clock.
    process(clk1) 
    begin
    if rising_edge(clk1) then
    count <=count+1;
    if(count = 25000000) then
    clock <= not clock;
    count <= 1;
    end if;
    end if;
	 	 clk<= clock; 
    end process;
end comp;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is
port(clk50_in    : in std_logic;          -----system clock i/p
        red      : out std_logic;         -----primrary colour output
        green    : out std_logic;
        blue     : out std_logic;
        hs_out   : out std_logic;         ------horizontal control signal
        vs_out   : out std_logic;         ------vertical   control signal
		botonIzq : in bit;
        botonDer : in bit;
        botonAb  : in bit:='0';
        ledCol1  : out bit;
        ledCol2  : out bit; 
        ledCol3  : out bit; 
        ledCol4  : out bit;
        --reset    : in  bit;
		ledIndica: out bit;
        led      : out bit);
end VGA;

architecture Behavioral of VGA is

--components

--component clk1Hz port(a: in std_logic; b: out std_logic); end component;
component clk1Hz port (clk1 : in std_logic;
           clk : out std_logic
         );
    end component;
 --vga
signal clk25             : std_logic;
signal hs : std_logic_vector (9 downto 0);
signal vs : std_logic_vector (9 downto 0);
--Signals del juego
signal clock50: std_logic; 
signal clk1Hert: std_logic;
signal count :integer := 1;--for 1Hz clock

--limitesCuadricula
signal limiteSuperior, limiteInferior, limiteIzquierda, 
limiteDerecha, limiteLineaA, limiteLineaB, limiteLineaC: std_logic_vector (9 downto 0);
signal limiteLinea1, limiteLinea2, limiteLinea3: std_logic_vector(9 downto 0);

--columnas
signal columna1Rojo, columna2Rojo, columna3Rojo, columna4Rojo: bit_vector(3 downto 0) := "0000";
signal columna1Amarillo, columna2Amarillo, columna3Amarillo, columna4Amarillo: bit_vector(3 downto 0) :="0000";
signal columna1General, columna2General, columna3General, columna4General: bit_vector(3 downto 0):= "0000";

--indices
signal limiteInferiorSelector, limiteSuperiorSelector, limiteIzquierdoSelector, limiteDerechoSelector: std_logic_vector(9 downto 0);
type limitesDerSel is array (0 to 3) of std_logic_vector(9 downto 0);
type limitesIzqSel is array (0 to 3) of std_logic_vector(9 downto 0);
signal limitesDerecha : limitesDerSel := ("0100100111","0110000110","0111100101","1001000100"); --{295, 390, 485, 580}
signal limitesIzquierda : limitesIzqSel := ("0011110000","0101001111","0110101110","1000001101"); --{240,335,430,525}
--type matriz is array(0 downto 3, 0 downto 3) of integer range 0 to 2; 

signal indices: std_logic_vector(3 downto 0);
signal ledsignal, signalLedIndicador : bit;--indicador de la frecuencia de 1hz
--signal leeAbajo : bit;
signal columna: integer := 1;
signal jugador : bit:='1'; --para el estado del jugador

signal redWins, yellowWins, tie, tieSignal: bit:='0';

begin
--inicializacion de las variables de la cuadricula y los limites
 limiteIzquierda          <=  "0011011100"; --220
 limiteDerecha            <=  "1001011000"; --600
 limiteSuperior           <=  "0001111000"; --120
 limiteInferior           <=  "0111110100"; --500
 limiteLineaA             <=  "0011010111"; --120+(500-120)/4
 limiteLineaB             <=  "0100110110"; --120+2*(500-120)/4
 limiteLineaC             <=  "0110010101"; --120+3*(500-120)/4
 limiteLinea1             <=  "0100111011"; --220+(600-220)/4
 limiteLinea2             <=  "0110011010"; --220+2*(600-220)/4
 limiteLinea3             <=  "0111111001"; --220+3*(600-220)/4
 limiteInferiorSelector   <=  "0000110000"; --56
 limiteSuperiorSelector   <=  "0001111101"; --6
 limiteIzquierdoSelector  <=  "0011110000"; --0
 limiteDerechoSelector    <=  "0100100111"; --0


process(clk50_in)
begin
    if(rising_edge(clk50_in)) then
        --verticales
        if(columna1Rojo="1111" or columna2Rojo="1111" or columna3Rojo="1111" or columna4Rojo="1111") then redWins<='1'; yellowWins<='0'; tie<='0'; end if;
        if(columna1Amarillo="1111" or columna2Amarillo="1111" or columna3Amarillo="1111" or columna4Amarillo="1111") then yellowWins<='1'; redWins<='0'; tie<='0'; end if;
        --horizontales
        if(columna1Rojo(3)='1' and columna2Rojo(3)='1' and columna3Rojo(3)='1' and columna4Rojo(3)='1')then redWins<='1'; yellowWins<='0'; tie<='0'; end if;
        if(columna1Rojo(2)='1' and columna2Rojo(2)='1' and columna3Rojo(2)='1' and columna4Rojo(2)='1')then redWins<='1'; yellowWins<='0'; tie<='0'; end if;
        if(columna1Rojo(1)='1' and columna2Rojo(1)='1' and columna3Rojo(1)='1' and columna4Rojo(1)='1')then redWins<='1'; yellowWins<='0'; tie<='0'; end if;
        if(columna1Rojo(0)='1' and columna2Rojo(0)='1' and columna3Rojo(0)='1' and columna4Rojo(0)='1')then redWins<='1'; yellowWins<='0'; tie<='0'; end if;
        if(columna2Amarillo(3)='1' and columna2Amarillo(3)='1' and columna3Amarillo(3)='1' and columna4Amarillo(3)='1')then yellowWins<='1'; redWins<='0'; tie<='0'; end if;
        if(columna2Amarillo(2)='1' and columna2Amarillo(2)='1' and columna3Amarillo(2)='1' and columna4Amarillo(2)='1')then yellowWins<='1'; redWins<='0'; tie<='0'; end if;
        if(columna2Amarillo(1)='1' and columna2Amarillo(1)='1' and columna3Amarillo(1)='1' and columna4Amarillo(1)='1')then yellowWins<='1'; redWins<='0'; tie<='0'; end if;
        if(columna2Amarillo(0)='1' and columna2Amarillo(0)='1' and columna3Amarillo(0)='1' and columna4Amarillo(0)='1')then yellowWins<='1'; redWins<='0'; tie<='0'; end if;
        --diagonales
        if(columna1Rojo(3)='1' and columna2Rojo(2)='1' and columna3Rojo(1)='1' and columna4Rojo(0)='1')then redWins<='1'; yellowWins<='0'; tie<='0'; end if;
        if(columna1Rojo(0)='1' and columna2Rojo(1)='1' and columna3Rojo(2)='1' and columna4Rojo(3)='1')then redWins<='1'; yellowWins<='0'; tie<='0'; end if;
        if(columna1amarillo(3)='1' and columna2amarillo(2)='1' and columna3amarillo(1)='1' and columna4amarillo(0)='1')then yellowWins<='1'; redWins<='0'; tie<='0'; end if;
        if(columna1amarillo(0)='1' and columna2amarillo(1)='1' and columna3amarillo(2)='1' and columna4amarillo(3)='1')then yellowWins<='1'; redWins<='0'; tie<='0'; end if;

        --ties
        if(columna1General="1111" and columna2General="1111" and columna3General="1111" and columna4General="1111")then
            tieSignal <='1';
            end if;
        if(tieSignal = '1' and redWins = '0' and yellowWins = '0')then tie<='1'; yellowWins <= '0'; redWins <= '0'; end if;
    end if;
end process;

-- generate a 25Mhz clock
process (clk50_in)
begin
    --divisor de frecuencia 50 a 25
if clk50_in'event and clk50_in='1' then
    count <=count+1;
    if(count = 7500000) then
        clk1Hert <= not clk1Hert;
        count <= 1;
    end if;
if (clk25 = '0') then              
clk25 <= '1';
else
clk25 <= '0';
end if;
end if;
end process;
--clk1Hz port map(clock50, clk1Hert);
led <= ledsignal;
ledIndica<= signalLedIndicador;
process(clk50_in)
begin
if(rising_edge(clk50_in)) then
            if(columna = 1) then LedCol1<='1'; ledCol2<='0'; ledCol3<='0'; ledCol4<='0'; end if;
            if(columna = 2) then LedCol1<='0'; ledCol2<='1'; ledCol3<='0'; ledCol4<='0'; end if;
            if(columna = 3) then LedCol1<='0'; ledCol2<='0'; ledCol3<='1'; ledCol4<='0'; end if;
            if(columna = 4) then LedCol1<='0'; ledCol2<='0'; ledCol3<='0'; ledCol4<='1'; end if;
				end if;
end process;
				
process (clk1Hert)
begin
    if(rising_edge(clk1Hert)) then
        ledsignal <= not ledsignal; 
          --if(botonAb = '1' and jugador = '0') then jugador <= '1'; elsif (botonAb = '1' and jugador ='1') then jugador <= '0'; end if;
		  if(botonDer = '1' or botonIzq = '1' or botonAb = '1') then signalLedIndicador <= '1'; else signalLedIndicador <= '0'; end if;
		  if(botonDer = '1') then
		  limitesDerecha(0)<=limitesDerecha(1);
		  limitesDerecha(1)<=limitesDerecha(2);
		  limitesDerecha(2)<=limitesDerecha(3);
		  limitesDerecha(3)<=limitesDerecha(0);
		  limitesIzquierda(0)<=limitesIzquierda(1);
		  limitesIzquierda(1)<=limitesIzquierda(2);
		  limitesIzquierda(2)<=limitesIzquierda(3);
          limitesIzquierda(3)<=limitesIzquierda(0);
          --columna := (columna + 1) mod 4; para saber en que columna realmente esta pisando el selector
			 if(columna = 1) then columna <= 2; elsif columna = 2 then columna <= 3; elsif columna = 3 then columna <= 4; else columna<=1; end if;
		  end if; 
		  if botonIzq = '1' then
		  limitesDerecha(0)<=limitesDerecha(3);
		  limitesDerecha(1)<=limitesDerecha(0);
		  limitesDerecha(2)<=limitesDerecha(1);
		  limitesDerecha(3)<=limitesDerecha(2);
		  limitesIzquierda(0)<=limitesIzquierda(3);
		  limitesIzquierda(1)<=limitesIzquierda(0);
		  limitesIzquierda(2)<=limitesIzquierda(1);
          limitesIzquierda(3)<=limitesIzquierda(2);
			 if(columna = 1) then columna <= 4; elsif columna = 2 then columna <= 1; elsif columna = 3 then columna <= 2; else columna<=3; end if;
		  end if; 
    end if; 
end process; 

process(clk1Hert)
begin
    if(rising_edge(clk1Hert))then
        --COLUMNA 1
    --if(reset='1')then columna1General <= "0000"; columna1Rojo<="0000"; columna1Amarillo<="0000";
    --                  columna2General <= "0000"; columna2Rojo<="0000"; columna2Amarillo<="0000";
    --                  columna3General <= "0000"; columna3Rojo<="0000"; columna3Amarillo<="0000";
    --                  columna4General <= "0000"; columna4Rojo<="0000"; columna4Amarillo<="0000";
    --                  end if;
if(columna = 1 and botonAb = '1')then --and (not columna1General = "1111"))then 

c1: case columna1General is
    when "0000" =>     
    if(jugador = '1') then
        columna1Rojo<="0001";
        jugador<='0';
        columna1General <= "0001";
    else
        columna1Amarillo<="0001";
        jugador<='1';
        columna1General <= "0001"; 
    end if;
    when "0001" => 
    if(jugador = '1') then
        columna1Rojo(1)<='1';
        jugador<='0';
        columna1General <= "0011"; 
    else
        columna1Amarillo(1)<='1';
        jugador<='1';
        columna1General <= "0011"; 
    end if;
    when "0011" => 
    if(jugador = '1') then
        columna1Rojo(2)<='1';
        jugador<='0';
        columna1General <= "0111"; 
    else
        columna1Amarillo(2)<='1';
        jugador<='1';
        columna1General <= "0111"; 
    end if;
    when "0111" =>
    if(jugador = '1') then
        columna1Rojo(3)<='1';
        jugador<='0';
        columna1General <= "1111"; 
    else
        columna1Amarillo(3)<='1';
        jugador<='1';
        columna1General <= "1111"; 
    end if;
    when others => null;
    end case c1;
end if; 
--COLUMNA 2
if(columna = 2 and botonAb = '1')then 
if(columna2General = "0000") then
    if(jugador = '1') then
        columna2Rojo<="0001";
        jugador<='0';
        columna2General <= "0001"; 
    else
        columna2Amarillo<="0001";
        jugador<='1';
        columna2General <= "0001"; 
    end if;
end if;
if(columna2General = "0001") then
    if(jugador = '1') then
        columna2Rojo(1)<='1';
        jugador<='0';
        columna2General <= "0011"; 
    else
        columna2Amarillo(1)<='1';
        jugador<='1';
        columna2General <= "0011"; 
    end if;
end if;
if(columna2General = "0011") then
    if(jugador = '1') then
        columna2Rojo(2)<='1';
        jugador<='0';
        columna2General <= "0111"; 
    else
        columna2Amarillo(2)<='1';
        jugador<='1';
        columna2General <= "0111"; 
    end if;
end if;
if(columna2General = "0111") then
    if(jugador = '1') then
        columna2Rojo(3)<='1';
        jugador<='0';
        columna2General <= "1111"; 
    else
        columna2Amarillo(3)<='1';
        jugador<='1';
        columna2General <= "1111"; 
    end if;
end if;
end if; 
--COLUMNA 3
if(columna = 3 and botonAb = '1')then 
if(columna3General = "0000") then
    if(jugador = '1') then
        columna3Rojo<="0001";
        jugador<='0';
        columna3General <= "0001"; 
    else
        columna3Amarillo<="0001";
        jugador<='1';
        columna3General <= "0001"; 
    end if;
end if;
if(columna3General = "0001") then
    if(jugador = '1') then
        columna3Rojo(1)<='1';
        jugador<='0';
        columna3General <= "0011"; 
    else
        columna3Amarillo(1)<='1';
        jugador<='1';
        columna3General <= "0011"; 
    end if;
end if;
if(columna3General = "0011") then
    if(jugador = '1') then
        columna3Rojo(2)<='1';
        jugador<='0';
        columna3General <= "0111"; 
    else
        columna3Amarillo(2)<='1';
        jugador<='1';
        columna3General <= "0111"; 
    end if;
end if;
if(columna3General = "0111") then
    if(jugador = '1') then
        columna3Rojo(3)<='1';
        jugador<='0';
        columna3General <= "1111"; 
    else
        columna3Amarillo(3)<='1';
        jugador<='1';
        columna3General <= "1111"; 
    end if;
end if;
end if; 
--COLUMNA 4
if(columna = 4 and botonAb = '1')then 
if(columna4General = "0000") then
    if(jugador = '1') then
        columna4Rojo<="0001";
        jugador<='0';
        columna4General <= "0001"; 
    else
        columna4Amarillo<="0001";
        jugador<='1';
        columna4General <= "0001"; 
    end if;
end if;
if(columna4General = "0001") then
    if(jugador = '1') then
        --columna4Rojo(2)<='1';
        columna4Rojo(1)<='1';
        jugador<='0';
        columna4General <= "0011"; 
    else
        --columna4Amarillo(2)<='1';
        columna4Amarillo(1)<='1';
        --"----" , "--1-", "001-"
        jugador<='1';
        columna4General <= "0011"; 
    end if;
end if;
if(columna4General = "0011") then
    if(jugador = '1') then
        --columna4Rojo(1)<='1';
        columna4Rojo(2)<='1';
        jugador<='0';
        columna4General <= "0111"; 
    else
        --columna4Amarillo(1)<='1';
        columna4Amarillo(2)<='1';
        jugador<='1';
        columna4General <= "0111"; 
    end if;
end if;
if(columna4General = "0111") then
    if(jugador = '1') then
        --columna4Rojo(0)<='1';
        columna4Rojo(3)<='1';
        jugador<='0';
        columna4General <= "1111"; 
    else
        --columna4Amarillo(0)<='1';
        columna4Amarillo(3)<='1';
        jugador<='1';
        columna4General <= "1111"; 
    end if;	
end if;
end if; end if;
end process;
        


process (clk25)
begin
if clk25'event and clk25 = '1' then
    --TABLERO
if(redWins = '0' and tie = '0' and yellowWins = '0')then 
if hs = limiteIzquierda and vs >= limiteSuperior and vs <= limiteInferior then ---linea izquierda
    red <= '0' ; blue <= '1'; green <= '1';
elsif hs = limiteDerecha and vs >= limiteSuperior and vs <= limiteInferior then--linea derecha 
    red <= '0'; blue <= '1'; green <= '1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteSuperior then -- linea arriba / 120
    red <= '0'; blue <= '1'; green <= '1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteInferior then -- linea abajo / 511
    red <= '0'; blue <= '1'; green <= '1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteLineaA then -- linea A 
    red <= '0'; blue <= '1'; green <= '1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteLineaB then -- linea B
    red <= '0'; blue <= '1'; green <= '1';
elsif hs <= limiteDerecha and hs>= limiteIzquierda and vs = limiteLineaC then -- linea C
    red <= '0'; blue <= '1'; green <='1';
elsif hs = limiteLinea1 and vs >= limiteSuperior and vs <= limiteInferior then--linea derecha
    red <= '0'; blue <= '1'; green <= '1';
elsif hs = limiteLinea2 and vs >= limiteSuperior and vs <= limiteInferior then--linea derecha
    red <= '0'; blue <= '1'; green <= '1';
elsif hs = limiteLinea3 and vs >= limiteSuperior and vs <= limiteInferior then--linea derecha
    red <= '0'; blue <= '1'; green <= '1';
elsif jugador='1' and hs <= limitesDerecha(0) and hs >= limitesIzquierda(0) and vs = (limiteSuperiorSelector-"111") then --cursor selector
    red <= '1'; blue <= '0'; green <= '0';
elsif jugador='0' and hs <= limitesDerecha(0) and hs >= limitesIzquierda(0) and vs = (limiteSuperiorSelector-"111") then --cursor selector
    red <= '1'; blue <= '0'; green <= '1';
    --(3,0)
elsif columna1Rojo(0)='1' and hs <= limiteLinea1 and hs >= limiteIzquierda and vs <= limiteInferior and vs >= limiteLineaC then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna1Amarillo(0)='1' and hs <= limiteLinea1 and hs >= limiteIzquierda and vs <= limiteInferior and vs >= limiteLineaC then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(3,1)
elsif columna2Rojo(0)='1' and hs <= limiteLinea2 and hs >= limiteLinea1 and vs <= limiteInferior and vs >= limiteLineaC then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna2Amarillo(0)='1' and hs <= limiteLinea2 and hs >= limiteLinea1 and vs <= limiteInferior and vs >= limiteLineaC then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(3,2)
elsif columna3Rojo(0)='1' and hs <= limiteLinea3 and hs >= limiteLinea2 and vs <= limiteInferior and vs >= limiteLineaC then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna3Amarillo(0)='1' and hs <= limiteLinea3 and hs >= limiteLinea2 and vs <= limiteInferior and vs >= limiteLineaC then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(3,3)
elsif columna4Rojo(0)='1' and hs <= limiteDerecha and hs >= limiteLinea3 and vs <= limiteInferior and vs >= limiteLineaC then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna4Amarillo(0)='1' and hs <= limiteDerecha and hs >= limiteLinea3 and vs <= limiteInferior and vs >= limiteLineaC then --bloque
    red <= '1'; blue <= '0'; green <= '1';

    --(2,0)
elsif columna1Rojo(1)='1' and hs <= limiteLinea1 and hs >= limiteIzquierda and vs <= limiteLineaC and vs >= limiteLineaB then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna1Amarillo(1)='1' and hs <= limiteLinea1 and hs >= limiteIzquierda and vs <= limiteLineaC and vs >= limiteLineaB then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(2,1)
elsif columna2Rojo(1)='1' and hs <= limiteLinea2 and hs >= limiteLinea1 and vs <= limiteLineaC and vs >= limiteLineaB then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna2Amarillo(1)='1' and hs <= limiteLinea2 and hs >= limiteLinea1 and vs <= limiteLineaC and vs >= limiteLineaB then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(2,2)
elsif columna3Rojo(1)='1' and hs <= limiteLinea3 and hs >= limiteLinea2 and vs <= limiteLineaC and vs >= limiteLineaB then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna3Amarillo(1)='1' and hs <= limiteLinea3 and hs >= limiteLinea2 and vs <= limiteLineaC and vs >= limiteLineaB then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(2,3)
elsif columna4Rojo(1)='1' and hs <= limiteDerecha and hs >= limiteLinea3 and vs <= limiteLineaC and vs >= limiteLineaB then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna4Amarillo(1)='1' and hs <= limiteDerecha and hs >= limiteLinea3 and vs <= limiteLineaC and vs >= limiteLineaB then --bloque
    red <= '1'; blue <= '0'; green <= '1';

    --(1,0)
elsif columna1Rojo(2)='1' and hs <= limiteLinea1 and hs >= limiteIzquierda and vs <= limiteLineaB and vs >= limiteLineaA then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna1Amarillo(2)='1' and hs <= limiteLinea1 and hs >= limiteIzquierda and vs <= limiteLineaB and vs >= limiteLineaA then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(1,1)
elsif columna2Rojo(2)='1' and hs <= limiteLinea2 and hs >= limiteLinea1 and vs <= limiteLineaB and vs >= limiteLineaA then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna2Amarillo(2)='1' and hs <= limiteLinea2 and hs >= limiteLinea1 and vs <= limiteLineaB and vs >= limiteLineaA then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(1,2)
elsif columna3Rojo(2)='1' and hs <= limiteLinea3 and hs >= limiteLinea2 and vs <= limiteLineaB and vs >= limiteLineaA then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna3Amarillo(2)='1' and hs <= limiteLinea3 and hs >= limiteLinea2 and vs <= limiteLineaB and vs >= limiteLineaA then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(1,3)
elsif columna4Rojo(2)='1' and hs <= limiteDerecha and hs >= limiteLinea3 and vs <= limiteLineaB and vs >= limiteLineaA then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna4Amarillo(2)='1' and hs <= limiteDerecha and hs >= limiteLinea3 and vs <= limiteLineaB and vs >= limiteLineaA then --bloque
    red <= '1'; blue <= '0'; green <= '1';


    --(0,0)
elsif columna1Rojo(3)='1' and hs <= limiteLinea1 and hs >= limiteIzquierda and vs <= limiteLineaA and vs >= limiteSuperior then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna1Amarillo(3)='1' and hs <= limiteLinea1 and hs >= limiteIzquierda and vs <= limiteLineaA and vs >= limiteSuperior then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(0,1)
elsif columna2Rojo(3)='1' and hs <= limiteLinea2 and hs >= limiteLinea1 and vs <= limiteLineaA and vs >= limiteSuperior then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna2Amarillo(3)='1' and hs <= limiteLinea2 and hs >= limiteLinea1 and vs <= limiteLineaA and vs >= limiteSuperior then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(0,2)
elsif columna3Rojo(3)='1' and hs <= limiteLinea3 and hs >= limiteLinea2 and vs <= limiteLineaA and vs >= limiteSuperior then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna3Amarillo(3)='1' and hs <= limiteLinea3 and hs >= limiteLinea2 and vs <= limiteLineaA and vs >= limiteSuperior then --bloque
    red <= '1'; blue <= '0'; green <= '1';
    --(0,3)
elsif columna4Rojo(3)='1' and hs <= limiteDerecha and hs >= limiteLinea3 and vs <= limiteLineaA and vs >= limiteSuperior then --bloque
    red <= '1'; blue <= '0'; green <= '0';
elsif columna4Amarillo(3)='1' and hs <= limiteDerecha and hs >= limiteLinea3 and vs <= limiteLineaA and vs >= limiteSuperior then --bloque
    red <= '1'; blue <= '0'; green <= '1';
--------------------------------------------------------------------------------
else                     ----------blank signal display
    red <= '0' ; blue <= '0'; green <= '0' ;
end if;

end if;
--WIN
    if(redWins = '1') then 
        red<='1'; blue<='0'; green <='0';
    end if;

    if(yellowWins = '1') then 
        red<='1'; blue<='0'; green<='1';
    end if;

    if(tie = '1') then
        red<='1'; blue<='1'; green='0';
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