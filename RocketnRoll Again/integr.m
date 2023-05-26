function integr(t,accel_f,gyro_f)
%% Data Integration
% Acceleration Integration with Euler (explicit) method
n = length(t);
vel = zeros(n,3);
for k=1:(n-1)
    vel(k+1,:) = vel(k,:)+accel_f(k,:)*(t(k+1)-t(k));
end
vel(1,:) = 0;
% Acceleration Integration with cumtrapz function
% vel = cumtrapz(t,accel_f,1); % 1 perchÃ© le tre componenti sono le colonne, quindi si integrano le colonne (dimensione "1" per matlab)
% Figures
figure(8)
plot(t,vel(:,1),'r','LineWidth',2);
xlabel('t [s]')
ylabel('v_x [m/s]')
xlim([t(1),t(end)])
figure(9)
plot(t,vel(:,2),'g','LineWidth',2);
xlabel('t [s]')
ylabel('v_y [m/s]')
xlim([t(1),t(end)])
figure(10)
plot(t,vel(:,3),'b','LineWidth',2);
xlabel('t [s]')
ylabel('v_z [m/s]')
xlim([t(1),t(end)])
% Velocity Integration with Euler (explicit) method
s = zeros(n,3);
for k=1:(n-1)
    s(k+1,:) = s(k,:)+vel(k,:)*(t(k+1)-t(k));
end
% Velocity Integration with cumtrapz function
% s = cumtrapz(t,vel,1);
% Figures
figure(11)
plot(t,s(:,1),'r','LineWidth',2);
xlabel('t [s]')
ylabel('x [m]')
xlim([t(1),t(end)])
figure(12)
plot(t,s(:,2),'g','LineWidth',2);
xlabel('t [s]')
ylabel('y [m]')
xlim([t(1),t(end)])
figure(13)
plot(t,s(:,3),'b','LineWidth',2);
xlabel('t [s]')
ylabel('z [m]')
xlim([t(1),t(end)])
% 3D trajectory
figure(14)
plot3(s(:,1),s(:,2),s(:,3),'m','LineWidth',2);
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
grid on
% Angular Rates Integration with Euler Explicit method
attitude = zeros(n,3); % WARNING: initial condition must be corrected with  
                       % the initial rocket attitude, according to the 
                       % reference frame
for k=1:(n-1)
    attitude(k+1,:) = attitude(k,:)+gyro_f(k,:)*(t(k+1)-t(k));
end
% Angular Rates Integration with cumtrapz function
% attitude = cumtrapz(t,gyro_f,1);
% Figures

% figure(15)
% plot(t,attitude(:,1),'r','LineWidth',2);
% xlabel('t [s]')
% ylabel('\theta [deg]')
% xlim([t(1),t(end)])
% figure(16)
% plot(t,attitude(:,2),'g','LineWidth',2);
% xlabel('t [s]')
% ylabel('\phi [deg]')
% xlim([t(1),t(end)])
% figure(17)
% plot(t,attitude(:,3),'b','LineWidth',2);
% xlabel('t [s]')
% ylabel('\psi [deg]')
% xlim([t(1),t(end)])

