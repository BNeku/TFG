
%% Determinar el n�mero m�nimo de datos capturados
% https://es.mathworks.com/help/matlabmobile/ug/sensor-data-streaming-tutorial.html
% https://es.mathworks.com/help/matlabmobile/ug/use-logged-sensor-data.html

%% Activar la habilitaci�n para la captura de datos sensoriales durante el tiempo que dura el bucle
m.Logging = 1;

pause(2); % En mobile App s�lo se admiten esperas con pause con 2 segundos como m�ximo
pause(2); pause(2); pause(2); pause(2)

%% Desactivar la captura
m.Logging = 0;

%% Recuperar los datos almacenados
[aceleracion, taceleracion] = accellog(m);   % Logged acceleration data
[vangular, tvangular] = angvellog(m);        % Logged angular velocity data    
[orientacion, torientacion] = orientlog(m);  % Logged orientation data
[magenetico, tmagnetico] = magfieldlog(m);   % Logged magnetic field data
[posisicion, tposicion] = poslog(m);         % Logged position data

yAngVel = vangular(:,2);
roll = orientacion(:, 3);
plot(tvangular, yAngVel, torientacion, roll);
legend('Velocidad Angular Y', 'Roll');
xlabel('Tiempo relativo (s)');


%% Clasificaci�n de la acci�n mediante el sensor aceleraci�n
[M,N] = size(aceleracion);

if M == 0
  disp('No se han capturado datos: repetir');
else
  X = aceleracion';
  Actividades = classify(RedTFG,X)
end

discardlogs(m);



