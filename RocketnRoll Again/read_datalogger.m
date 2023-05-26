%% Initialization 
clear all; close all; clc 

%%leggi il datalog e mettilo nella tabella T
T = readtable("D:\Desktop\RocketLab2023\RocketnRoll_MATLAB_2023\lanci_prova\lancio_3\prova_lancio_3.TXT"); % input IMU data
% I dati letti includono l'accelerazione (aX, aY, aZ), la velocità angolare (gX, gY, gZ) e il campo magnetico (mX, mY, mZ) provenienti dall'IMU.

%% Input parameters
%Vengono     definiti diversi parametri di input, come gli offset dell'accelerometro e del giroscopio, 
% le frequenze di campionamento dell'accelerometro e del giroscopio, 
% il tempo iniziale e finale per l'analisi dei dati e il colore dei dati non filtrati.

%gli offset sono inizializzati a 0, verifica perchè e se c'è bisogno di
%modificare

%qui una mia prova sugli offset
%accel_offset = 1*[-67.5394, -298.6972, -400.5486]; % [mg]
%gyro_offset = 0*[-0.2258, 0.7314, -0.8506]; % [dps]



accel_fs = 10; % lpf accelerometer [Hz]
gyro_fs = 15; % lpf gyroscope [Hz]
t0=0; % initial time [s]
tf=inf; % final time [s]

clr=[0.3 0.3 0.3]; % color of non-filtered data
%% Parameters processing
% IMU data sorting

%vengono prese dalla tabella le colonne dedicate per ogni singola variabile
%ma tutte le righe vengono prelevate
accel_raw = T{:,{'aX','aY','aZ'}}; % [mg]
gyro_raw = T{:,{'gX','gY','gZ'}}; % [dps]
%mag = T{:,{'mX','mY','mZ'}}; %[uT]

accel_raw = (accel_raw/1000) *9.8; % [m/s^2]

ax_mean =mean(accel_raw(1:1000,1));
ay_mean = mean(accel_raw(1:1000,2));
az_mean = mean(accel_raw(1:1000,3));
gx_mean=mean(T.gX(1:1000));
gy_mean=mean(T.gY(1:1000));
gz_mean=mean(T.gZ(1:1000));

accel_offset=0*[ax_mean,ay_mean,az_mean];
gyro_offset=0*[gx_mean,gy_mean,gz_mean];

% IMU data correction
axy_dim=3;
samples=size(accel_raw);
gyro = gyro_raw - gyro_offset;
accel_new = accel_raw - accel_offset; % [m/s^2]

% IMU data conversion -> in accel ora cambiano solo le unità di misura


%micros è una colonna della tabella T e sta per MICROSECONDI, ovvero il
%microsecondo in cui i dati della riga vengono acquisiti
%t = (T.micros - T.micros(1))*(1e-6); % time [s]

somma=0;
for i=1:n
    t(i) = somma + 0.1;
    somma = somma +0.1;
end


fs=round(1/t(2)); % sampling frequency [Hz] -> per far questo prende il secondo elemento di t 
                  %  (il primo è quello a cui si inizia per cui non è significativo)
                  %e calcola dunque la frequenza di campionamento del
                  %modulo

% IMU data filtering
[b_accel,a_accel] = butter(9,accel_fs/(fs)); % design order 9 Butterworth filter accelerometer
[b_gyro,a_gyro] = butter(9,gyro_fs/(fs)); % design order 9 Butterworth filter accelerometer

%[b,a] = butter(n,Wn) restituisce i coefficienti della funzione di trasferimento di un ennesimo ordine 
% filtro Butterworth digitale lowpass con frequenza di taglio normalizzata Wn.

%Vengono progettati e applicati filtri di Butterworth per filtrare i dati dell'accelerometro e del giroscopio.  
% La funzione butter viene utilizzata per progettare i filtri Butterworth di ordine 9 
% con le frequenze di taglio specificate 
% (accel_fs per l'accelerometro e gyro_fs per il giroscopio) in rapporto alla frequenza di campionamento (fs). 

%L'ordine del filtro influisce sulla pendenza della transizione tra la banda passante e la banda di stop del filtro.
%Ordini più alti producono filtri con una pendenza di transizione più ripida, che attenuano le frequenze indesiderate più rapidamente
%Una pendenza di transizione più ripida indica che il filtro attenua rapidamente le frequenze al di fuori della sua banda passante, mentre una pendenza di transizione meno ripida indica una diminuzione graduale dell'attenuazione.

%b_accel e a_accel sono due vettori di coefficienti che definiscono un
%filtro di Butterworth per l'accelerometro . Il vettore b_accel contiene i coefficienti del numeratore del filtro di Butterworth, mentre il vettore a_accel contiene i coefficienti del denominatore.

% La funzione filtfilt viene utilizzata per applicare i filtri in avanti e all'indietro ai dati, 
% garantendo che il filtro sia a fase lineare.

tot=0;
media=0;
flag=0;
n_samples=samples(1);

% for i=1:3
%     flag=0;
%     tot = 0;
%     media = accel_raw(1,i);
%     for j=1:n_samples
%         tot = tot + accel_raw(j,i);
%         if (j>1 && abs(accel_raw(j,i) - accel_raw(j-1,i))> 10)
%             means(i)=media
%             stop_mean_index(i) = j
%             flag=1
%             break
%         end
%         media = tot/j;
%     end
%     if flag==0
%        means(i)=media
%        stop_mean_index(i) = j
%     end
% 
% end





% mean_accel_new = mean(accel_new);
% accel_new = accel_new - mean_accel_new;

% IMU auxiliary variables
%calcolata la norma dell'accelerazione

accel_f = filtfilt(b_accel,a_accel,accel_new);
gyro_f = filtfilt(b_gyro,a_gyro,gyro);

accel_f = accel_f - mean(accel_f)
accel_norm = sqrt(sum(accel_f.*accel_f,2)); % acceleration norm [m/s^2]
accel_norm_f = filtfilt(b_accel,a_accel,accel_norm);

%%implementazione delle matrici di rotazione
% Inizializza le variabili per memorizzare gli angoli di heading, la velocità e la posizione dell'oggetto
n = size(accel_f, 1); % numero di istanti di tempo
theta = zeros(n, 3); % angoli di heading per ciascuno dei 3 assi (x, y, z)
v = zeros(n, 3); % velocità dell'oggetto per ciascuna delle 3 dimensioni (x, y, z)
p = zeros(n, 3); % posizione dell'oggetto per ciascuna delle 3 dimensioni (x, y, z)
dt = t(2)-t(1);
% Calcola gli angoli di heading, la velocità e la posizione per ogni istante di tempo
for i = 2:n
    % Calcola gli angoli di heading integrando la velocità angolare fornita dal giroscopio
    theta(i,:) = theta(i-1,:) + gyro_f(i,:) * dt;
    
    % Calcola la matrice di rotazione per ruotare il vettore delle accelerazioni nel sistema di coordinate globale
    Rx = [1 0 0; 0 cos(theta(i,1)) -sin(theta(i,1)); 0 sin(theta(i,1)) cos(theta(i,1))];
    Ry = [cos(theta(i,2)) 0 sin(theta(i,2)); 0 1 0; -sin(theta(i,2)) 0 cos(theta(i,2))];
    Rz = [cos(theta(i,3)) -sin(theta(i,3)) 0; sin(theta(i,3)) cos(theta(i,3)) 0; 0 0 1];
    R = Rz * Ry * Rx;
    
    % Ruota il vettore delle accelerazioni nel sistema di coordinate globale
    a = (R * accel_f(i,:)')';
    %accel_orient(i,:)=a;
    % Calcola la velocità e la posizione integrando l'accelerazione
    v(i,:) = v(i-1,:) + a * dt;
   
end

vx_mean =mean(v(1:1000,1));
vy_mean = mean(v(1:1000,2));
vz_mean = mean(v(1:1000,3));

v_off=[vx_mean,vy_mean,vz_mean];
v_new = v - v_off;

[b_vel,a_vel] = butter(9,10/(fs*21));
v_f = filtfilt(b_vel,a_vel,v_new);

for i=2:n
    p(i,:) = p(i-1,:) + v_f(i,:) * dt;
end

[b_p,a_p] = butter(9,10/(fs));
p_f = filtfilt(b_p,a_p,p);

%accel_orient = accel_orient(1:150,:);

% Plotta la traiettoria specifica dell'oggetto
plot3(p_f(:,1), p_f(:,2), p_f(:,3))
grid on;
axis equal;
xlabel('asse x')
ylabel('asse y')
zlabel('asse z')

%%integr(t,accel_f,gyro_f)

% % %% Figures
 figure(2)
 hold on
 plot(t,accel_f(:,1),'r','LineWidth',3)
 %plot(t,accel_raw(:,1),'.-','MarkerSize',1,'Color',clr)
 xlabel('t [s]')
 ylabel('a_x [m/s^2]')
 xlim([t0 tf])
 %legend('filtered','raw')


 figure(3)
hold on
plot(t,accel_f(:,2),'g','LineWidth',3)
%plot(t,accel_raw(:,2),'.-','MarkerSize',1,'Color',clr)
xlabel('t [s]')
ylabel('a_y [m/s^2]')
xlim([t0 tf])
%legend('filtered','raw')
%
figure(4)
hold on
plot(t,accel_f(:,3),'b','LineWidth',3)
%plot(t,accel_raw(:,3),'.-','MarkerSize',1,'Color',clr)
xlabel('t [s]')
ylabel('a_z [m/s^2]')
xlim([t0 tf])
%legend('filtered','raw')
%
figure(5)
hold on
plot(t,accel_norm_f,'b','LineWidth',3)
%plot(t,accel_norm,'.-','MarkerSize',1,'Color',clr)
xlabel('t [s]')
ylabel('|a| [m/s^2]')
xlim([t0 tf])
%legend('filtered','raw')
%
figure(6)
hold on
plot(t,gyro_f(:,1),'r','LineWidth',3)
%plot(t,gyro(:,1),'.-','MarkerSize',1,'Color',clr)
xlabel('t [s]')
ylabel('\omega_x [deg/s]')
xlim([t0 tf])
%legend('filtered','raw')
%
figure(7)
hold on
plot(t,gyro_f(:,2),'g','LineWidth',3)
%plot(t,gyro(:,2),'.-','MarkerSize',1,'Color',[0.7 0.7 0.7])
xlabel('t [s]')
ylabel('\omega_y [deg/s]')
xlim([t0 tf])
%legend('filtered','raw')
%
figure(8)
hold on
plot(t,gyro_f(:,3),'b','LineWidth',3)
%plot(t,gyro(:,3),'.-','MarkerSize',1,'Color',clr)
xlabel('t [s]')
ylabel('\omega_z [deg/s]')
xlim([t0 tf])
%legend('filtered','raw')

figure(9)
hold on
plot(t,v_f(:,1),'r','LineWidth',3)
%plot(t,gyro(:,1),'.-','MarkerSize',1,'Color',clr)

%legend('filtered','raw')
%
figure(9)
hold on
plot(t,v_f(:,2),'g','LineWidth',3)
%plot(t,gyro(:,2),'.-','MarkerSize',1,'Color',[0.7 0.7 0.7])

%legend('filtered','raw')
%
figure(9)
hold on
plot(t,v_f(:,3),'b','LineWidth',3)
%plot(t,gyro(:,3),'.-','MarkerSize',1,'Color',clr)

legend('vx','vy','vz')