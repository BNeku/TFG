%% Preparacion del dispositivo y datos

% IMPORTANTE: si se queda el objeto m abierto, genera problemas, siendo necesario eliminarlo en 
% la línea de comandos haciendo: clear m

%% Borrado de objetos previos
if exist('m','var')
    clear m;
end

%% Crear objeto 
m = mobiledev;

%% Cargar la RedLSTM si no existe la variable
if not(exist('TFGnet','var'))
    load(fullfile(pwd, 'src', 'red','TFGnet'), 'TFGnet');
    RedTFG = net;
end