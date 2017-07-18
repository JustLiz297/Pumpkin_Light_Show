%% Open port %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; close all; clear all;  
a = arduino('COM3', 'UNO');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tic;                            % start a timer
duration=600;                    % duration in seconds
i=0;                            % initialize loop counter

ButtonState=false; % initialize variable
ButtonStatePrev=false; % initialize variable
ButtonPin='D2';
configurePin(a, ButtonPin, 'Pullup'); %sets so you don't need resisters to the gnd path
configurePin(a,'A0','analogInput');
Bluepin='D3';
Redpin='D6';
Orangepin='D5';
Eyes='D9';
brightness_steps = 3;
while toc<duration;              % start a loop that will run for duration
    while toc < duration
        writePWMDutyCycle(a, 'D3', 0)
        i=i+1;                      % increment counter each iteration
        time(i)=toc;                % builds array of elapsed time values
        brightness = 1;
        j(i)= readVoltage(a, 'A1');  % builds an array of voltages from analog
        if j(i) >= 1
            writePWMDutyCycle(a, 'D3', 1/(5*(j(i))))
        end
    
        figure(1);                  % declare a figure
        plot(time,j,'r');            % plot data value
            xlabel('time');
            ylabel('voltage');
            axis([0 100 0 5]);
            title('Voltage through Trim Potentiometer');
            legend('Voltage');
        pause(0.1);                % set sampling rate
        isButton = readDigitalPin(a, ButtonPin); %reading button 
        if isButton && ~ButtonStatePrev  % was button turned on and previously off
            ButtonState = ~ButtonState; % switch button output
            ButtonStatePrev=true;  % button was previously on
        elseif ~isButton
            ButtonStatePrev=false; % button was previously off
        end
        if ButtonState ~= true
            break;
        end
    end
    while ButtonState ~= true; 
        fid = fopen('pumpkinvoltage.txt', 'w');
        fprintf(fid, 'Voltage Through Trim Potentiometer\n\n');
        fprintf(fid,'%2.5f\n', j);
        fclose(fid);
        while toc<duration;
            i = 0;
            i=i+1;                      % increment counter each iteration
            time(i)=toc;                % builds array of elapsed time values 
            v(i)= readVoltage(a, 'A0');  % builds an array of voltages from analog
            %figure(2);                  % declare a figure
            %plot(time,v,'r');            % plot data value
            if v(i)< 3;
                for i = 0:brightness_steps
                    writePWMDutyCycle(a, Bluepin, i/brightness_steps);
                    pause(0.1);
                end
                for i =brightness_steps:-1:0
                    writePWMDutyCycle(a, Bluepin, i/brightness_steps);
                    pause(0.1);
                end
                for i = 0:brightness_steps
                    writePWMDutyCycle(a, Orangepin, i/brightness_steps);
                    pause(0.1);
                end
   
                for i = brightness_steps:-1:0
                    writePWMDutyCycle(a, Orangepin, i/brightness_steps);
                    pause(0.1);
                end
                for i = 0:brightness_steps
                    writePWMDutyCycle(a, Redpin, i/brightness_steps);
                    pause(0.1);
                end
                for i = brightness_steps:-1:0
                    writePWMDutyCycle(a, Redpin, i/brightness_steps);
                    pause(0.1);
                end
                for i = 0:brightness_steps
                    writePWMDutyCycle(a, Eyes, i/brightness_steps);
                    pause(0.1);
                end
                for i = brightness_steps:-1:0
                    writePWMDutyCycle(a, Eyes, i/brightness_steps);
                    pause(0.1);
                end 
                writePWMDutyCycle (a, Bluepin, 0);
                writePWMDutyCycle (a, Redpin, 0);
                writePWMDutyCycle (a, Orangepin, 0);
                writePWMDutyCycle (a, Eyes, 0);
            end
            pause(0.1);
        end
    end
end
