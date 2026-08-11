function hComm = initialize_flyOpenRig()

flyOpenRig_user_setting;

% %initialize LED controller
% The open rig runs with no LED backlight. We still construct the LEDController
% object so the ~30 LED/divider calls scattered through the GUI remain valid
% no-ops, but the (fixed) constructor falls back to serialPort = 0 when no
% controller is connected instead of crashing.
fprintf('Opening LED controller...\n');
LEDCtrl = LEDController(serial_port_for_LED_Controller);
hComm.LEDCtrl = LEDCtrl;
hComm.LEDCtrl.reset();
%hComm.LEDCtrl.synCamera(frameRate);

% hFlyBubbleCtrl = ModularClient(serial_port_for_flyBubble_controller);
% hComm.LEDCtrl = hFlyBubbleCtrl;
% hComm.LEDCtrl.open();
% hComm.LEDCtrl.getDeviceId();
% 
% %add calibration parameters to the controller
% hComm.LEDCtrl.setPropertiesToDefaults({'ALL'});
% hComm.LEDCtrl.irBacklightPowerToIntensityRatio('setValue',irBacklightPowerToIntensityRatio);
% hComm.LEDCtrl.visibleBacklightPowerToIntensityRatio('setValue',visibleBacklightPowerToIntensityRatio);

%Run the camera server program bia
cmdString = ['cmd /C "',biasFile, '" && exit &'];
system(cmdString);

for i = 1:1
    try
        %initialize the camera
        flea3{i} = BiasControl(camera(i).ip,camera(i).port);
        %flea3.initializeCamera(frameRate, movieFormat, ROI, triggerMode);
        flea3{i}.connect();
        flea3{i}.loadConfiguration(defaultJsonFile(i).name);
        
        flea3{i}.disableLogging();
        flea3{i}.setWindowGeometry(windowGeometry(i));
        hComm.flea3{i} = flea3{i};
        hComm.flea3IsActive(i) = true;
        
    catch
        hComm.flea3{i} = 0;
        hComm.flea3IsActive(i) = false;
    end
end
%
% %initialize precon sensor
% The open rig runs with no precon temperature/humidity sensor. We skip opening
% it entirely (avoiding a blocking COM-port handshake wait on a missing port)
% and set THSensor = 0. Every precon reference in the GUI is already guarded by
% ~(hComm.THSensor == 0), so temp/humidity polling and the overheat shutdown are
% simply inactive.
hComm.THSensor = 0;