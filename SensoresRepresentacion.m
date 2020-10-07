clear all; close all;

%% Datos Matlab Mobile y Matlab Mobile
% ver C:\Trabajo\Master AAA IoT\Matlab
% IoT\mobilesensor_mappinglocationandspeed.m, que también es del toolbox de
% Matlab 
%connector on password (el password en el Host puede ser cualquiera, pero igual al del móvil)

%% Definición de los canales
% Canal: C1 Sensores 
ChannelIDSensores1 = 613229;
readAPIKeySensores1 = 'MYZ5R4GC842YQTMU';
writeAPIKeySensores1 = 'Q2QD0LPW52WL6JUM';

% Canal: C2 Sensores (para Copia)
ChannelIDSensores2 = 607002;
readAPIKeySensores2 = '5TCKXF8BNNULHUUE';
writeAPIKeySensores2 = 'S99L626MNOO6RJ3L';

%% Comprobación de la existencia del objeto mobiledev y conexión
Existem = exist('m');
if Existem == 1
    delete(m)
end

while Existem ~= 1
  m = mobiledev;
  Existem = exist('m');
end

Conectado = m.Connected;
while Conectado == 0
  % intentar la conexión de nuevo
  Conectado = m.Connected;
end
% Activar la recepción de datos
m.Logging = 1;
m.PositionSensorEnabled = 1;

iter = 1;
MaxIter = 1000; %Máximo número de iteraciones
OrientacionXYZ = zeros(MaxIter,3);
VelocidadAngularXYZ = zeros(MaxIter,3);
AceleracionXYZ = zeros(MaxIter,3);
CampoMagneticoXYZ = zeros(MaxIter,3);

pause(2); %esperamos 2 segundos a recibir datos.

for i=1:1:MaxIter
    % disp('Aceleracion:'); disp(m.Acceleration)
    % disp('Velocidad Angular:'); disp(m.AngularVelocity)
    % disp('Campo Magnetico:'); disp(m.MagneticField)
    % disp('Orientacion:'); disp(m.Orientation)
    
    m.Logging = 1; % Nos aseguramos que se pueden recibir datos
    
    VelocidadAngularXYZ(i,:) = m.AngularVelocity;
    AceleracionXYZ(i,:) = m.Acceleration;
    OrientacionXYZ(i,:) = m.Orientation;
    CampoMagneticoXYZ(i,:) = m.MagneticField;
    
    d = datetime('now','Format','dd-MM-yyyy HH:mm:ss');
    Timestamps(iter) = d;
    AceleracionX(iter) = m.Acceleration(1);
    AceleracionY(iter) = m.Acceleration(2);
    AceleracionZ(iter) = m.Acceleration(3);
    OrientacionX(iter) = m.Orientation(1);
    OrientacionY(iter) = m.Orientation(2);
    OrientacionZ(iter) = m.Orientation(3);

    % introducimos los datos de localización
    Latitud(iter)  = -40;
    Longitud(iter) = 23;
    Altitud(iter)  = 100;
    
    iter = iter + 1;
    if iter == MaxIteraciones
       bucle = false;
    end

end

%% Acceso a ThingSpeak
% esta escritura genera un Twitt de aviso
thingSpeakWrite(ChannelIDWebCam,CambioImagen,'Writekey',writeAPIKeyWebCam);
pause(15);

dataField1 = AceleracionX';
dataField2 = AceleracionY';
dataField3 = AceleracionZ';
dataField4 = OrientacionX';
dataField5 = OrientacionY';
dataField6 = OrientacionZ';

Localizacion(1,:) = Latitud;
Localizacion(2,:) = Longitud;
Localizacion(3,:) = Altitud;

dataTimeTable = table(Timestamps', dataField1,dataField2,dataField3,dataField4,dataField5,dataField6);
respuesta = thingSpeakWrite(ChannelIDSensores1,dataTimeTable, 'Location', Localizacion','Writekey',writeAPIKeySensores1);
%respuesta = thingSpeakWrite(ChannelIDSensores1,[100, 200, 300, 400, 500, 600], 'Fields',[1 2 3 4 5 6],'Location', [-40, 23, 35],'Writekey',writeAPIKeySensores1);
pause(15); %esperar a consolidar datos en el canal

%LecturaDatos = thingSpeakread(ChannelIDSensores1,'Readkey',readAPIKeySensores1);
%LecturaDatos = thingSpeakRead(ChannelIDSensores1,'Readkey',readAPIKeySensores1,'Output', 'table');
%[LecturaDatos, rime] = thingSpeakRead(ChannelIDSensores1,'Readkey',readAPIKeySensores1);
%[data, time] = thingSpeakRead(ChannelIDSensores1, 'Fields', [1,2,3,4,5,6], 'NumDays', 2);
%[data, time] = thingSpeakRead(ChannelIDSensores1, 'Fields', [1,2,3,4,5,6], 'NumPoints', 10);

%% Se comprueba que los datos se han copiado correctamente en el canal
[data, time] = thingSpeakRead(ChannelIDSensores1, 'Fields', [1,2,3,4,5,6], 'NumPoints', iter,'Output', 'table');

%% Activación del campo Field7 del canal C1 para que a través del control React se copien los datos al canal 2
EstadoCanal7 = 1; 
thingSpeakWrite(ChannelIDSensores1,EstadoCanal7,'Fields', 7,'Writekey',writeAPIKeySensores1);
pause(15);

%% Quedamos a la escucha para determinar cuándo se han copiado los datos en canal C2, leyendo el campo 7,
%  de este canal que debe estar a 1. A continuación se leen estos datos.
[Campo8Canal1, time] = thingSpeakRead(ChannelIDSensores1, 'Fields', 8);

% Mientras no se cambie esta bandera seguimos esperando hasta un máximo de
% iteraciones
% 
MaxIter = 10; iter = 1;
while (Campo8Canal1 == 0) && (iter < MaxIter)
  pause(5); iter = iter + 1;
  [Campo7Canal1, time] = thingSpeakRead(ChannelIDSensores1, 'Fields', 8);
end  

[data, InfoCanal] = thingSpeakRead(ChannelIDSensores2, 'Fields', [1,2,3,4,5,6], 'Output', 'table','NumPoints', 100);
disp('Datos Copiados a canal C2 desde C1 ='); disp(data);
disp('Información del Canal C2='); disp(InfoCanal);
%

%% Representar los datos de los sensores en local
[av, tav] = angvellog(m);
[o, to] = orientlog(m);
yAngVel = av(:,2);
roll = o(:, 3);
plot(tav, yAngVel, to, roll);
legend('Velocidad Angular Y', 'Roll');
xlabel('Tiempo relativo (s)');

% Conexión a tiempos absolutos
tInit = datetime(m.InitialTimestamp, 'InputFormat', 'dd-MM-yyyy HH:mm:ss.SSS');
tAngVel = tInit + seconds(tav);
tOrient = tInit + seconds(to);

% Representación de múltiples sensores sobre tiempo absoluto
yAngVelDeg = yAngVel * 180/pi;
plot(tAngVel, yAngVelDeg, tOrient, roll);
legend('Y Velocidad Angular', 'Roll');
xlabel('Tiempo absoluto (s)');

%% Fusión de sensores 
% Fusión Acelerómetro-Magnetómetro
viewer = fusiondemo.OrientationViewer;

qe = ecompass(AceleracionXYZ, CampoMagneticoXYZ); 
title('Acelerómetro-Magnetómetro')
for ii=1:size(AceleracionXYZ,1)
viewer(qe(ii));
pause(0.01);
end

% Fusión Acelerómetro-Giróscopo
Fs = 200;
ifilt = imufilter('SampleRate', Fs);
title('Acelerómetro-Giróscopo')
for ii=1:size(AceleracionXYZ,1)
qimu = ifilt(AceleracionXYZ(ii,:), OrientacionXYZ(ii,:));
viewer(qimu);
pause(0.01);
end

% Fusión Acelerómetro-Giróscopo-Magentómetro
ifilt = ahrsfilter('SampleRate', Fs);
title('Acelerómetro-Giróscopo-Magentómetro')
for ii=1:size(AceleracionXYZ,1)
qahrs = ifilt(AceleracionXYZ(ii,:), OrientacionXYZ(ii,:), CampoMagneticoXYZ(ii,:));
viewer(qahrs);
pause(0.01);
end

%% Desconexión de la comunicación con el Galaxy
% connector off % Desconexión del envío de sensores por Matlab