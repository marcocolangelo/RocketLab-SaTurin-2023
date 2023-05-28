%% Initialization 
clear all; close all; clc 
 T = readtable("D:\Desktop\RocketLab2023\RocketnRoll_MATLAB_2023\lanci_prova\lancio_2\prova_lancio_2.TXT"); % input IMU data
% T = readtable("dataLog00169.TXT"); % input IMU data
%% Input parameters
accel_fs = 1; % lpf accelerometer [Hz]
gyro_fs = 1.5; % lpf gyroscope [Hz]
clr=[0.3 0.3 0.3]; % color of non-filtered data
%% Parameters processing
i_t0 = 2340;
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

% ACCELERATIONS (BODY AXES)
figure(1)
hold on
plot(t,accel_f(:,1),'r','LineWidth',2)
plot(t,accel_raw(:,1),'.-','MarkerSize',1,'Color',clr)
plot(t,accel(1,:),'r--','LineWidth',2)
xlabel('t [s]')
ylabel('a_x [m/s^2]')
xlim([t(1),t(end)])
legend('filtered','raw','filtered and corrected with offset')
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


t = t(i_t0:i_tf);
accel = accel(:,i_t0:i_tf);
gyro = gyro(:,i_t0:i_tf);
%% Data Integration
% Acceleration Integration
n = length(t);
accel_tot = zeros(3,n);
vel = zeros(3,n); % velocity initial condition (body axes)
quat = ones(4,n); % Quaternion [q0,q1,q2,q3]
quat(:,1) = [1; 0; 0; 0]; % initial condition 
%quat(:,1) = [0.707; 0; 0.707; 0]; % initial condition 
eul = zeros(3,n); % Euler Angles initial condition [Yaw (psi) - Pitch (theta) - Roll (phi)]
% eul(2,1) = pi/2;
pos = zeros(3,n); % position initial condition
for k=1:(n-1)
    A = -0.5*[     0      gyro(1,k)  gyro(2,k) gyro(3,k);
             -gyro(1,k)      0     -gyro(3,k) gyro(2,k);
             -gyro(2,k)  gyro(3,k)     0     -gyro(1,k);
             -gyro(3,k) -gyro(2,k)  gyro(1,k)    0     ];
    quat(:,k+1) = quat(:,k)+A*quat(:,k)*(t(k+1)-t(k)); % quaternion
    norm_quat = sqrt(sum(quat(:,k+1).^2,1));
    quat(:,k+1) = quat(:,k+1)./norm_quat;
    eul(1,k+1) = atan2(2*(quat(2,k+1)*quat(3,k+1)+quat(1,k+1)*quat(4,k+1)),(quat(1,k+1)^2+quat(2,k+1)^2-quat(3,k+1)^2-quat(4,k+1)^2)); % yaw (psi)
    eul(2,k+1) = asin(-2*(quat(2,k+1)*quat(4,k+1)-quat(1,k+1)*quat(3,k+1))); % pitch (theta)
    eul(3,k+1) = atan2(2*(quat(3,k+1)*quat(4,k+1)+quat(1,k+1)*quat(2,k+1)),(quat(1,k+1)^2-quat(2,k+1)^2-quat(3,k+1)^2+quat(4,k+1)^2)); % roll (phi)
%     accel_tot(1,k) = accel(1,k)+gyro(2,k)*vel(3,k)-gyro(3,k)*vel(2,k)+9.8*sin(eul(2,k));
%     accel_tot(2,k) = accel(2,k)+gyro(3,k)*vel(1,k)-gyro(1,k)*vel(3,k)-9.8*cos(eul(2,k))*sin(eul(3,k));
%     accel_tot(3,k) = accel(3,k)+gyro(1,k)*vel(2,k)-gyro(2,k)*vel(1,k)-9.8*cos(eul(2,k))*cos(eul(3,k));
    accel_tot(1,k) = accel(1,k)+9.8*sin(eul(2,k));
    accel_tot(2,k) = accel(2,k)-9.8*cos(eul(2,k))*sin(eul(3,k));
    accel_tot(3,k) = accel(3,k)-9.8*cos(eul(2,k))*cos(eul(3,k));

    %vel(:,k+1) = vel(:,k)+accel(:,k)*(t(k+1)-t(k)); % velocity (body axes)
% if abs(accel_norm(k+1,:) - accel_norm(k,:)) < 0.05 && abs(accel_norm(k+1)) < 0.3
%    vel(:,k+1) = vel(:,k);
% else
    vel(:,k+1) = vel(:,k)+accel_tot(:,k)*(t(k+1)-t(k)); % velocity (body axes)
% end    

[b_vel, a_vel] = butter(9,0.0305,'high');
  vel = filtfilt(b_vel,a_vel,vel');
  vel = vel';

    L = [cos(eul(2,k+1))*cos(eul(1,k+1)), -cos(eul(3,k+1))*sin(eul(1,k+1))+sin(eul(3,k+1))*sin(eul(2,k+1))*cos(eul(1,k+1)), sin(eul(3,k+1))*sin(eul(1,k+1))+cos(eul(3,k+1))*sin(eul(2,k+1))*cos(eul(1,k+1));
         cos(eul(2,k+1))*sin(eul(1,k+1)), cos(eul(3,k+1))*cos(eul(1,k+1))+sin(eul(3,k+1))*sin(eul(2,k+1))*sin(eul(1,k+1)), -sin(eul(3,k+1))*cos(eul(1,k+1))+cos(eul(3,k+1))*sin(eul(2,k+1))*sin(eul(1,k+1));
         -sin(eul(2,k+1)), sin(eul(3,k+1))*cos(eul(2,k+1)), cos(eul(3,k+1))*cos(eul(2,k+1))];
    vel_earth(:,k+1) = L*vel(:,k+1);
    % vel_earth(:,k+1) = vel(:,k+1);
    pos(:,k+1) = pos(:,k)+vel_earth(:,k)*(t(k+1)-t(k));
end

  [b_pos, a_pos] = butter(9,0.011,'high');
  pos = filtfilt(b_pos,a_pos,pos');
  pos = pos';

%% Figures

%
figure()
hold on
plot(t',vel_earth(1,:),'b','linewidth',2);
plot(t',vel_earth(2,:),'g','linewidth',2);
plot(t',vel_earth(3,:),'r','linewidth',2);
title('Velocity')
legend('Vx','Vy','Vz');
grid on

figure()
hold on
plot(t',pos(1,:),'b','linewidth',2);
plot(t',pos(2,:),'g','linewidth',2);
plot(t',pos(3,:),'r','linewidth',2);
xlabel('t [s]')
ylabel('position [m]')
title('Position')
legend('x','y','z');
grid on

figure()
plot(t',pos(3,:),'r','linewidth',2);
title('Altitude vs time')
xlabel('t [s]');
ylabel('z [m]');
yline(0);

figure()
plot3(pos(1,:),pos(2,:),pos(3,:),'m','linewidth',2);
%plot3(pos(:,1),pos(:,2),pos(:,3),'m','linewidth',2);
hold on
% plot3(pos(1,1),pos(1,2),pos(1,3),'xb','linewidth',2);
% plot3(pos(end,1),pos(end,2),pos(end,3),'or','linewidth',2);
title('Trajectory');
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
grid on
axis equal

figure()
hold on
plot(t',eul(1,:)*180/pi,'b','linewidth',2);
plot(t',eul(2,:)*180/pi,'g','linewidth',2);
plot(t',eul(3,:)*180/pi,'r','linewidth',2);
title('Euler Angles (Attitude)')
xlabel('t [s]')
ylabel('angle [°]')
legend('\psi','\theta','\phi');
grid on

figure()
plot(t',pos(2,:))
title('y')
