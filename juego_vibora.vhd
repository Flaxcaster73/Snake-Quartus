library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity juego_vibora is
    Port ( 
        reloj_juego      : in  STD_LOGIC; 
        reloj_rapido     : in  STD_LOGIC; 
        reinicio         : in  STD_LOGIC; 
        btn_arriba       : in  STD_LOGIC; 
        btn_abajo        : in  STD_LOGIC;
        btn_izquierda    : in  STD_LOGIC;
        btn_derecha      : in  STD_LOGIC;
        salida_matriz    : out STD_LOGIC_VECTOR (63 downto 0);
        salida_puntaje   : out integer range 0 to 64;         
        salida_record    : out integer range 0 to 64;         
        salida_fin_juego : out STD_LOGIC                      
    );
end juego_vibora;

architecture Behavioral of juego_vibora is
    
    subtype coord is unsigned(2 downto 0);
    type registro_pos is record
        x : coord;
        y : coord;
    end record;

    type arreglo_vibora is array (0 to 63) of registro_pos;
    signal vibora : arreglo_vibora;
    signal tamano_vibora : integer range 1 to 64 := 3;
    
    signal dir_actual  : integer range 0 to 3 := 3; -- 0:Arriba, 1:Abajo, 2:Izq, 3:Der
    signal pos_comida  : registro_pos := (x => "100", y => "100"); 
    signal fin_juego   : std_logic := '0';
    
    signal record_maximo : integer range 0 to 64 := 0;
    
    signal rand_x, rand_y : coord := "000";

begin

    process(reloj_rapido)
    begin
        if rising_edge(reloj_rapido) then
            rand_x <= rand_x + 1;
            if rand_x = "111" then
                rand_y <= rand_y + 1;
            end if;
        end if;
    end process;

    process(reloj_juego, reinicio)
        variable nueva_cabeza_x, nueva_cabeza_y : coord;
        variable colision : std_logic;
        variable puntaje_actual : integer range 0 to 64;
    begin
        if reinicio = '1' then
            vibora(0) <= (x => "011", y => "011");
            vibora(1) <= (x => "010", y => "011");
            vibora(2) <= (x => "001", y => "011");
            tamano_vibora <= 3;
            dir_actual <= 3;
            pos_comida <= (x => "110", y => "110");
            fin_juego <= '0';
            
        elsif rising_edge(reloj_juego) then
            
            if fin_juego = '0' then 
                colision := '0';
                
                if btn_arriba = '0' and dir_actual /= 1 then dir_actual <= 0;
                elsif btn_abajo = '0' and dir_actual /= 0 then dir_actual <= 1;
                elsif btn_izquierda = '0' and dir_actual /= 3 then dir_actual <= 2;
                elsif btn_derecha = '0' and dir_actual /= 2 then dir_actual <= 3;
                end if;

                nueva_cabeza_x := vibora(0).x;
                nueva_cabeza_y := vibora(0).y;
                
                case dir_actual is
                    when 0 => nueva_cabeza_y := nueva_cabeza_y - 1;
                    when 1 => nueva_cabeza_y := nueva_cabeza_y + 1;
                    when 2 => nueva_cabeza_x := nueva_cabeza_x - 1;
                    when 3 => nueva_cabeza_x := nueva_cabeza_x + 1;
                end case;

                for i in 1 to 63 loop
                    if i < tamano_vibora then
                        if nueva_cabeza_x = vibora(i).x and nueva_cabeza_y = vibora(i).y then
                            colision := '1';
                        end if;
                    end if;
                end loop;

                if colision = '1' then
                    fin_juego <= '1'; 
                else
                    for i in 63 downto 1 loop
                        if i < tamano_vibora then
                            vibora(i) <= vibora(i-1);
                        end if;
                    end loop;

                    vibora(0).x <= nueva_cabeza_x;
                    vibora(0).y <= nueva_cabeza_y;

                    if nueva_cabeza_x = pos_comida.x and nueva_cabeza_y = pos_comida.y then
                        if tamano_vibora < 64 then
                            tamano_vibora <= tamano_vibora + 1;
                        end if;
                        pos_comida.x <= rand_x;
                        pos_comida.y <= rand_y;
                    end if;
                end if;
                
                puntaje_actual := tamano_vibora - 3;
                if puntaje_actual > record_maximo then
                    record_maximo <= puntaje_actual;
                end if;
                
            end if; 
        end if;
    end process;

    process(vibora, tamano_vibora, pos_comida)
        variable matriz_temp : STD_LOGIC_VECTOR(63 downto 0);
        variable indice : integer;
    begin
        matriz_temp := (others => '0');
        
        indice := to_integer(pos_comida.y) * 8 + to_integer(pos_comida.x);
        matriz_temp(63 - indice) := '1';
        
        for i in 0 to 63 loop
            if i < tamano_vibora then
                indice := to_integer(vibora(i).y) * 8 + to_integer(vibora(i).x);
                matriz_temp(63 - indice) := '1';
            end if;
        end loop;
        
        salida_matriz <= matriz_temp;
    end process;

    salida_puntaje   <= tamano_vibora - 3; 
    salida_record    <= record_maximo; 
    salida_fin_juego <= fin_juego; 

end Behavioral;