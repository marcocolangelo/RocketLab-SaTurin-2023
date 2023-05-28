%% Initialization 

clear all; close all; clc 
T = readtable("prova_lancio_2.TXT"); % input IMU data
% T = readtable("dataLog00169.TXT"); % input IMU data

%% Input parameters

accel_fs = 1; % lpf accelerometer [Hz]
gyro_fs = 1.5; % lpf gyroscope [Hz]
clr=[0.3 0.3 0.3]; % color of non-filtered data




%% Parameters processing

i_t0 = 2740;
i_tf = 4350;
% IMU data sorting
accel_raw = T{:,{'aX','aY','aZ'}}; % [mg]
gyro_raw = T{:,{'gX','gY','gZ'}}; % [dps]
% IMU data conversion
accel_raw = accel_raw/1000*9.81; % [m/s^2]
n = length(accel_raw);
%t = (T.micros - T.micros(1))*(1e-6); % time [s]

somma=0;
 for i=1:n
     t(i) = somma + 0.1;
     somma = somma +0.1;
 end
 
% IMU auxiliary variables
fs=0.1; % sampling frequency [Hz]
% IMU data filtering
[b_accel,a_accel] = butter(9,0.09); % design order 9 Butterworth filter accelerometer
[b_gyro,a_gyro] = butter(9,0.09); % design order 9 Butterworth filter accelerometer
accel_f = filtfilt(b_accel,a_accel,accel_raw);
gyro_f = filtfilt(b_gyro,a_gyro,gyro_raw);

%accel_offset = 0*mean(accel_f(1:20,:)); % [m/s^2]
gyro_offset =[-0.25,-0.2,-0.2]; % [deg/s]
accel_offset = [-1.2, -9.95+9.81, -0.75];
%gyro_offset = [0.1178   -0.0785    0.1692];

% IMU data correction
accel = accel_f - accel_offset; % [m/s^2]
gyro = gyro_f - gyro_offset; % [deg/s]
gyro = gyro*pi/180; % [rad/s]
accel_norm = sqrt(sum(accel.^2,2));

accel = accel';
gyro = gyro';


%% Rappresentazione dei dati registrati

figure(1)
hold on
plot(t,accel_f(:,1),'r','LineWidth',2)
plot(t,accel_raw(:,1),'.-','MarkerSize',1,'Color',clr)
plot(t,accel(1,:),'r--','LineWidth',2)
xlabel('t [s]')
ylabel('a_x [m/s^2]')
xlim([t(1),t(end)])
legend('filtered','raw','filtered and corrected with offset')
title('IMU Axes')
%
figure(2)
hold on
plot(t,accel_f(:,2),'g','LineWidth',2)
plot(t,accel_raw(:,2),'.-','MarkerSize',1,'Color',clr)
plot(t,accel(2,:),'g--','LineWidth',2)
xlabel('t [s]')
ylabel('a_y [m/s^2]')
xlim([t(1),t(end)])
legend('filtered','raw')
title('IMU Axes')
%
figure(3)
hold on
plot(t,accel_f(:,3),'b','LineWidth',2)
plot(t,accel_raw(:,3),'.-','MarkerSize',1,'Color',clr)
plot(t,accel(3,:),'b--','LineWidth',2)
xlabel('t [s]')
ylabel('a_z [m/s^2]')
xlim([t(1),t(end)])
legend('filtered','raw','filtered and corrected with offset')
title('IMU Axes')

figure()
plot(t,accel_norm,'m','linewidth',2);
title('accel norm')
% ANGULAR RATES (BODY AXES)
figure(5)
hold on
plot(t,gyro_f(:,1),'r','LineWidth',3)
plot(t,gyro_raw(:,1),'.-','MarkerSize',1,'Color',clr)
xlabel('t [s]')
ylabel('\omega_x [deg/s]')
%xlim([t0 tf])
xlim([t(1),t(end)])
legend('filtered','raw')
%
figure(6)
hold on
plot(t,gyro_f(:,2),'g','LineWidth',2)
plot(t,gyro_raw(:,2),'.-','MarkerSize',1,'Color',[0.7 0.7 0.7])
xlabel('t [s]')
ylabel('\omega_y [deg/s]')
%xlim([t0 tf])
xlim([t(1),t(end)])
legend('filtered','raw')
title('IMU Axes')
%
figure(7)
hold on
plot(t,gyro_f(:,3),'b','LineWidth',2)
plot(t,gyro_raw(:,3),'.-','MarkerSize',1,'Color',clr)
xlabel('t [s]')
ylabel('\omega_z [deg/s]')
%xlim([t0 tf])
xlim([t(1),t(end)])
legend('filtered','raw')
title('IMU Axes')

%% Riorganizzazione delle componenti dell'accelerazione

accel_x = accel(1,:);
accel_y = accel(3,:);
accel_z = -accel(2,:);
accel = [accel_x; accel_y; accel_z];

t = t(i_t0:i_tf);
accel = accel(:,i_t0:i_tf);
accel_norm = accel_norm(i_t0:i_tf);
gyro = gyro(:,i_t0:i_tf);

figure()
hold on
plot(t',accel(1,:),'b','linewidth',2);
plot(t',accel(2,:),'g','linewidth',2);
plot(t',accel(3,:),'r','linewidth',2);
title('Acceleration components')
legend('ax','ay','az');
grid on

figure()
hold on
plot(t',accel_norm,'b','linewidth',2);
title('Acceleration Norm (during launch)')
legend('ax','ay','az');
grid on

%% Calcolo accelerazioni dovuto al solo moto del razzo (sottrazione del contributo della gravità

n = length(t);

for i=1:n
    theta(i) = atan(accel(3,i)./accel(1,i));
    accel_z_motion(i) = accel(3,i)-9.81*sin(theta(i));
%     if sin(theta(i))>0
%         accel_z_motion(i) = accel(3,i)-9.81;
%     else
%         accel_z_motion(i) = accel(3,i)+9.5;
%     end 
end

figure()
plot(t',theta*180/pi,'g','linewidth',2)
grid on
title('Pitch Angle (\theta)')
xlabel('t [s]')
ylabel('\theta [deg]')

%% Calcolo variazione della quota

vel_z = zeros(1,n);
pos_z = zeros(1,n);

for k=1:n-1
    vel_z(k+1) = vel_z(k)+accel_z_motion(k)*(t(k+1)-t(k));
    pos_z(k+1) = pos_z(k)+vel_z(k)*(t(k+1)-t(k));
end

figure()
plot(t',accel_z_motion,'r','linewidth',2);
title('Vertical Acceleration (due to motion)')
xlabel('t [s]')
ylabel('a_z [m/s^2]')
grid on

figure()
plot(t',vel_z,'c','linewidth',2);
title('Vertical velocity')
xlabel('t [s]')
ylabel('V_z [m/s]')
grid on

figure()
plot(t',pos_z,'m','linewidth',2);
title('Altitude')
xlabel('t [s]')
ylabel('z [m]')
grid on


    

