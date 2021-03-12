% Thomas Lea-Redmond 1908527
% for CM2208 coursework submission 12/03/2021

classdef Graphic_Equaliser < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        WavesMenu                    matlab.ui.container.Menu
        LoadfromFileMenu_Wave        matlab.ui.container.Menu
        SavetoFileMenu_Wave          matlab.ui.container.Menu
        diff_Waveform                matlab.ui.control.UIAxes
        ApplicationVariablesMenu     matlab.ui.container.Menu
        LoadfromFileMenu             matlab.ui.container.Menu
        SavetoFileMenu               matlab.ui.container.Menu
        Menu                         matlab.ui.container.Menu
        LoadMenu                     matlab.ui.container.Menu
        SaveMenu                     matlab.ui.container.Menu
        equ_Waveform                 matlab.ui.control.UIAxes
        original_Waveform            matlab.ui.control.UIAxes
        lbl_band_1                   matlab.ui.control.Label
        VolumeControlPanel           matlab.ui.container.Panel
        VolumeControlSwitch          matlab.ui.control.Switch
        VolumeMultiplierSliderLabel  matlab.ui.control.Label
        VolumeMultiplierSlider       matlab.ui.control.Slider
        EditField_VolumeMultiplier   matlab.ui.control.NumericEditField
        CutVariantDropDown           matlab.ui.control.DropDown
        CutVariantDropDownLabel      matlab.ui.control.Label
        CutButton                    matlab.ui.control.Button
        slider_Band_1                matlab.ui.control.Slider
        editField_Band_1             matlab.ui.control.NumericEditField
        slider_Band_2                matlab.ui.control.Slider
        editField_Band_2             matlab.ui.control.NumericEditField
        slider_Band_3                matlab.ui.control.Slider
        editField_Band_3             matlab.ui.control.NumericEditField
        slider_Band_4                matlab.ui.control.Slider
        editField_Band_4             matlab.ui.control.NumericEditField
        slider_Band_5                matlab.ui.control.Slider
        editField_Band_5             matlab.ui.control.NumericEditField
        slider_Band_6                matlab.ui.control.Slider
        editField_Band_6             matlab.ui.control.NumericEditField
        slider_Band_7                matlab.ui.control.Slider
        editField_Band_7             matlab.ui.control.NumericEditField
        slider_Band_8                matlab.ui.control.Slider
        editField_Band_8             matlab.ui.control.NumericEditField
        slider_Band_9                matlab.ui.control.Slider
        editField_Band_9             matlab.ui.control.NumericEditField
        slider_Band_10               matlab.ui.control.Slider
        editField_Band_10            matlab.ui.control.NumericEditField
        lbl_band_2                   matlab.ui.control.Label
        lbl_band_3                   matlab.ui.control.Label
        lbl_band_4                   matlab.ui.control.Label
        lbl_band_5                   matlab.ui.control.Label
        lbl_band_6                   matlab.ui.control.Label
        lbl_band_7                   matlab.ui.control.Label
        lbl_band_8                   matlab.ui.control.Label
        lbl_band_9                   matlab.ui.control.Label
        lbl_band_10                  matlab.ui.control.Label
        PlayButton                   matlab.ui.control.Button
        StopButton                   matlab.ui.control.Button
        PlayButton_mod               matlab.ui.control.Button
        StopButton_mod               matlab.ui.control.Button
        PlayButton_diff              matlab.ui.control.Button
        StopButton_diff              matlab.ui.control.Button
    end

    
    properties (Access = private)
        y       % wave data loaded from file - amplitude
        Fs      % wave data loaded from file - frequency
        
        mod_y   % modified wave data
        % frequency unccersary as it would be the same
        
        % reference to frequency midpoints of settings
        fcb_Values = [1000 3000 5000 7000 9000 11000 13000 15000 17000 19000];
    end

    methods (Access = private)
        
        function plotLoaded(app)
            % plot new chart onto axis
            
            app.y = app.y(:,1); % set to left channel if option exists
            
            plot(app.original_Waveform, app.y, 'b');
            
            hline = refline(app.original_Waveform, 0,0);   % creates refence line of y=0
            hline.Color = 'k';                  % specify colour = black for visibility
        end
        
        % using shelving function from lecture notes
        function [b, a]  = shelving(~, G, fc, fs, Q, type)
            %
            % Derive coefficients for a shelving filter with a given amplitude and
            % cutoff frequency.  All coefficients are calculated as described in 
            % Zolzer's DAFX book (p. 50 -55).  
            %
            % Usage:     [B,A] = shelving(G, Fc, Fs, Q, type);
            %
            %            G is the logrithmic gain (in dB)
            %            FC is the center frequency
            %            Fs is the sampling rate
            %            Q adjusts the slope be replacing the sqrt(2) term
            %            type is a character string defining filter type
            %                 Choices are: 'Bass_Shelf' or 'Treble_Shelf'

            
            K = tan((pi * fc)/fs);
            V0 = 10^(G/20);
            root2 = 1/Q; %sqrt(2)
            
            %Invert gain if a cut
            if(V0 < 1)
                V0 = 1/V0;
            end
            
            %%%%%%%%%%%%%%%%%%%%
            %    BASE BOOST
            %%%%%%%%%%%%%%%%%%%%
            if(( G > 0 ) && (strcmp(type,'Bass_Shelf')))
               
                b0 = (1 + sqrt(V0)*root2*K + V0*K^2) / (1 + root2*K + K^2);
                b1 =             (2 * (V0*K^2 - 1) ) / (1 + root2*K + K^2);
                b2 = (1 - sqrt(V0)*root2*K + V0*K^2) / (1 + root2*K + K^2);
                a1 =                (2 * (K^2 - 1) ) / (1 + root2*K + K^2);
                a2 =             (1 - root2*K + K^2) / (1 + root2*K + K^2);
            
            %%%%%%%%%%%%%%%%%%%%
            %    BASE CUT
            %%%%%%%%%%%%%%%%%%%%
            elseif (( G < 0 ) && (strcmp(type,'Bass_Shelf')))
                
                b0 =             (1 + root2*K + K^2) / (1 + root2*sqrt(V0)*K + V0*K^2);
                b1 =                (2 * (K^2 - 1) ) / (1 + root2*sqrt(V0)*K + V0*K^2);
                b2 =             (1 - root2*K + K^2) / (1 + root2*sqrt(V0)*K + V0*K^2);
                a1 =             (2 * (V0*K^2 - 1) ) / (1 + root2*sqrt(V0)*K + V0*K^2);
                a2 = (1 - root2*sqrt(V0)*K + V0*K^2) / (1 + root2*sqrt(V0)*K + V0*K^2);
            
            %%%%%%%%%%%%%%%%%%%%
            %   TREBLE BOOST
            %%%%%%%%%%%%%%%%%%%%
            elseif (( G > 0 ) && (strcmp(type,'Treble_Shelf')))
            
                b0 = (V0 + root2*sqrt(V0)*K + K^2) / (1 + root2*K + K^2);
                b1 =             (2 * (K^2 - V0) ) / (1 + root2*K + K^2);
                b2 = (V0 - root2*sqrt(V0)*K + K^2) / (1 + root2*K + K^2);
                a1 =              (2 * (K^2 - 1) ) / (1 + root2*K + K^2);
                a2 =           (1 - root2*K + K^2) / (1 + root2*K + K^2);
            
            %%%%%%%%%%%%%%%%%%%%
            %   TREBLE CUT
            %%%%%%%%%%%%%%%%%%%%
            
            elseif (( G < 0 ) && (strcmp(type,'Treble_Shelf')))
            
                b0 =               (1 + root2*K + K^2) / (V0 + root2*sqrt(V0)*K + K^2);
                b1 =                  (2 * (K^2 - 1) ) / (V0 + root2*sqrt(V0)*K + K^2);
                b2 =               (1 - root2*K + K^2) / (V0 + root2*sqrt(V0)*K + K^2);
                a1 =             (2 * ((K^2)/V0 - 1) ) / (1 + root2/sqrt(V0)*K + (K^2)/V0);
                a2 = (1 - root2/sqrt(V0)*K + (K^2)/V0) / (1 + root2/sqrt(V0)*K + (K^2)/V0);
            
            %%%%%%%%%%%%%%%%%%%%
            %   All-Pass
            %%%%%%%%%%%%%%%%%%%%
            else
                b0 = V0;
                b1 = 0;
                b2 = 0;
                a1 = 0;
                a2 = 0;
            end
            
            %return values
            a = [  1, a1, a2];
            b = [ b0, b1, b2];
        end
        
        function cut(app)
            
            if app.y == 0
                warndlg("No Waveform loaded");
                return
            end

            Q = 3;
            type = app.CutVariantDropDown.Value;
            
            
            G_Values = [app.editField_Band_1.Value app.editField_Band_2.Value app.editField_Band_3.Value app.editField_Band_4.Value app.editField_Band_5.Value app.editField_Band_6.Value app.editField_Band_7.Value app.editField_Band_8.Value app.editField_Band_9.Value app.editField_Band_10.Value];
 
            b = 0;
            a = 0;
            
            for c = 1:10
                G = G_Values(c);
                fcb = app.fcb_Values(c);

                [tempB, tempA] = shelving(app, G, fcb, app.Fs, Q, type);
                b = b + tempB;
                a = a + tempA;
            end
            
            disp(a);
            yb = filter(b, a, app.y);
            
            if app.VolumeControlSwitch.Value == "On"
                yb = VolumeControl(app, yb);
            end
            % recycling memory
            clear app.equ_Waveform;
            tempA = 0;
            tempB = 0;
            G_Values = 0;
            b = 0;
            a = 0;
            
            plot(app.equ_Waveform, yb,'r'); % plot new
            hline2 = refline(app.equ_Waveform, 0,0);   % creates refence line of y=0
            hline2.Color = 'k';                  % specify colour = black for visibility
            
            viewDifference(app, yb);
            app.mod_y = yb;
        end
        
        function viewDifference(app, yb)
            clear app.diff_Waveform;
            plot(app.diff_Waveform, (yb - app.y), 'g');
            
            refLineDiff = refline(app.diff_Waveform, 0, 0);
            refLineDiff.Color = 'k';
            
            
        end
        
        function yb = VolumeControl(app, yb)
            multiplier = app.EditField_VolumeMultiplier.Value;
            
            yb = yb * multiplier;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: CutButton
        function CutButtonPushed(app, event)
            cut(app);
            warning = msgbox("Operation Completed");
        end

        % Value changed function: slider_Band_1
        function slider_Band_1ValueChanged(app, event)
            value = app.slider_Band_1.Value;
            app.editField_Band_1.Value = value;
        end

        % Value changed function: editField_Band_1
        function editField_Band_1ValueChanged(app, event)
            value = app.editField_Band_1.Value;
            app.slider_Band_1.Value = value;
        end

        % Value changed function: slider_Band_2
        function slider_Band_2ValueChanged(app, event)
            value = app.slider_Band_2.Value;
            app.editField_Band_2.Value = value;
        end

        % Value changed function: slider_Band_3
        function slider_Band_3ValueChanged(app, event)
            value = app.slider_Band_3.Value;
            app.editField_Band_3.Value = value;
        end

        % Value changed function: slider_Band_4
        function slider_Band_4ValueChanged(app, event)
            value = app.slider_Band_4.Value;
            app.editField_Band_4.Value = value;
        end

        % Value changed function: slider_Band_5
        function slider_Band_5ValueChanged(app, event)
            value = app.slider_Band_5.Value;
            app.editField_Band_5.Value = value;
        end

        % Value changed function: slider_Band_6
        function slider_Band_6ValueChanged(app, event)
            value = app.slider_Band_6.Value;
            app.editField_Band_6.Value = value;
        end

        % Value changed function: slider_Band_7
        function slider_Band_7ValueChanged(app, event)
            value = app.slider_Band_7.Value;
            app.editField_Band_7.Value = value;
        end

        % Value changed function: slider_Band_8
        function slider_Band_8ValueChanged(app, event)
            value = app.slider_Band_8.Value;
            app.editField_Band_8.Value = value;
        end

        % Value changed function: slider_Band_9
        function slider_Band_9ValueChanged(app, event)
            value = app.slider_Band_9.Value;
            app.editField_Band_9.Value = value;
        end

        % Value changed function: slider_Band_10
        function slider_Band_10ValueChanged(app, event)
            value = app.slider_Band_10.Value;
            app.editField_Band_10.Value = value;
        end

        % Value changed function: editField_Band_2
        function editField_Band_2ValueChanged(app, event)
            value = app.editField_Band_2.Value;
            app.slider_Band_2.Value = value;
        end

        % Value changed function: editField_Band_3
        function editField_Band_3ValueChanged(app, event)
            value = app.editField_Band_3.Value;
            app.slider_Band_3.Value = value;
        end

        % Value changed function: editField_Band_4
        function editField_Band_4ValueChanged(app, event)
            value = app.editField_Band_4.Value;
            app.slider_Band_4.Value = value;
        end

        % Value changed function: editField_Band_5
        function editField_Band_5ValueChanged(app, event)
            value = app.editField_Band_5.Value;
            app.slider_Band_5.Value = value;
        end

        % Value changed function: editField_Band_6
        function editField_Band_6ValueChanged(app, event)
            value = app.editField_Band_6.Value;
            app.slider_Band_6.Value = value;
        end

        % Value changed function: editField_Band_7
        function editField_Band_7ValueChanged(app, event)
            value = app.editField_Band_7.Value;
            app.slider_Band_7.Value = value;
        end

        % Value changed function: editField_Band_8
        function editField_Band_8ValueChanged(app, event)
            value = app.editField_Band_8.Value;
            app.slider_Band_8.Value = value;
        end

        % Value changed function: editField_Band_9
        function editField_Band_9ValueChanged(app, event)
            value = app.editField_Band_9.Value;
            app.slider_Band_9.Value = value;
        end

        % Value changed function: editField_Band_10
        function editField_Band_10ValueChanged(app, event)
            value = app.editField_Band_10.Value;
            app.slider_Band_10.Value = value;
        end

        % Value changed function: EditField_VolumeMultiplier
        function EditField_VolumeMultiplierValueChanged(app, event)
            value = app.EditField_VolumeMultiplier.Value;
            app.VolumeMultiplierSlider.Value = value;
        end

        % Value changed function: VolumeMultiplierSlider
        function VolumeMultiplierSliderValueChanged(app, event)
            value = app.VolumeMultiplierSlider.Value;
            app.EditField_VolumeMultiplier.Value = value;
        end

        % Menu selected function: LoadfromFileMenu
        function LoadfromFileMenuSelected(app, event)
            filename = uigetfile("*.mat");
            
            if filename ~= 0
                load(filename);
            else
                warning = msgbox('ERROR: User selected cancellation, or nonexistent file chosen');
                return;
            end
            
            try
                % update all edit fields from files
                app.editField_Band_1.Value = value1;
                app.editField_Band_2.Value = value2;
                app.editField_Band_3.Value = value3;
                app.editField_Band_4.Value = value4;
                app.editField_Band_5.Value = value5;
                app.editField_Band_6.Value = value6;
                app.editField_Band_7.Value = value7;
                app.editField_Band_8.Value = value8;
                app.editField_Band_9.Value = value9;
                app.editField_Band_10.Value = value10;
                app.EditField_VolumeMultiplier.Value = value11;
                
                % update sliders values to match
                app.slider_Band_1.Value = value1;
                app.slider_Band_2.Value = value2;
                app.slider_Band_3.Value = value3;
                app.slider_Band_4.Value = value4;
                app.slider_Band_5.Value = value5;
                app.slider_Band_6.Value = value6;
                app.slider_Band_7.Value = value7;
                app.slider_Band_8.Value = value8;
                app.slider_Band_9.Value = value9;
                app.slider_Band_10.Value = value10;
                app.VolumeMultiplierSlider.Value = value11;
                
                warning = msgbox(filename + " successfully loaded");
            catch
                % most likely tried to load wrong file
                warning = msgbox("An error has occured loading in the variables.");
            end
            % save on system memory
            clear;
            
        end

        % Menu selected function: SavetoFileMenu
        function SavetoFileMenuSelected(app, event)
            [filename, path] = uiputfile("*.mat", "Save As");
            
            if filename ~= 0
                dataFile = fullfile(path, filename);
                value1 = app.editField_Band_1.Value;
                value2 = app.editField_Band_2.Value;
                value3 = app.editField_Band_3.Value;
                value4 = app.editField_Band_4.Value;
                value5 = app.editField_Band_5.Value;
                value6 = app.editField_Band_6.Value;
                value7 = app.editField_Band_7.Value;
                value8 = app.editField_Band_8.Value;
                value9 = app.editField_Band_9.Value;
                value10 = app.editField_Band_10.Value;
                value11 = app.EditField_VolumeMultiplier.Value;
                
                save(filename, 'value1', 'value2', 'value3', 'value4', 'value5', 'value6', 'value7', 'value8', 'value9', 'value10', 'value11', '-mat');
                warning = msgbox(filename + " successfully saved");
            else
                warning = msgbox('ERROR: User selected cancellation');
                return;
            end
            
            
        end

        % Menu selected function: LoadfromFileMenu_Wave
        function LoadfromFileMenu_WaveSelected(app, event)
            filename = uigetfile('*.wav; *.flac; *.mp3; *.m4a');
            % note using m4a for audio mp4 files mp4 is for video and audio
            if filename ~= 0
                % y     sampled data
                % Fs    sampling rate
                try
                    [app.y, app.Fs] = audioread(filename);
                catch
                    warning = msgbox("Attempt to load " + filename + " failed");
                end
            else
                % there has been an error.
                % window closed by user or incompatible type
                warning = msgbox('ERROR: User selected cancellation, or nonexistent file chosen');
                return;
            end
            
            plotLoaded(app);
        end

        % Menu selected function: SavetoFileMenu_Wave
        function SavetoFileMenu_WaveSelected(app, event)
            % get filename and path from user same as other methods
            
            % if modified file empty => no data to be written
            if isempty(app.mod_y)
                warning = msgbox("ERROR: No data to write");
                return;
            end
            
            [filename, path] = uiputfile("newfile.wav");
            % error handling - filename not set
            if filename == 0
                warning = msgbox('ERROR: User selected cancellation');
                return;
            end
            
            try
                % attempt to write to file using same frequency as normal
                % and modified audio
                audiowrite(filename, app.mod_y, app.Fs);
            catch
                % something bad has happened error - ends function
                warning = msgbox("An error has occured writing the file");
                return;
            end
            % write worked - file successful notify user    
            warning = msgbox("Data has been saved to " + filename);
        end

        % Callback function
        function OriginalSoundMenuSelected(app, event)
            if isempty(app.y)
                warning = msgbox("ERROR: No data to play");
                return;
            end
            
            sound(app.y, app.Fs);
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            if isempty(app.y)
                warning = msgbox("There is no audio to play");
                return;
            end
            
            sound(app.y, app.Fs, 16);
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            clear sound;
        end

        % Button pushed function: PlayButton_mod
        function PlayButton_modPushed(app, event)
            if isempty(app.mod_y)
                warning = msgbox("There is no audio to play");
                return;
            end
            
            sound(app.mod_y, app.Fs, 16);
        end

        % Button pushed function: PlayButton_diff
        function PlayButton_diffPushed(app, event)
            if isempty(app.mod_y) | app.y == app.mod_y
                warning = msgbox("There is no audio to play");
                return;
            end
            
            sound(app.mod_y, app.Fs, 16);
        end

        % Button pushed function: StopButton_mod
        function StopButton_modPushed(app, event)
            clear sound;
        end

        % Button pushed function: StopButton_diff
        function StopButton_diffPushed(app, event)
            clear sound;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1134 777];
            app.UIFigure.Name = 'MATLAB App';

            % Create WavesMenu
            app.WavesMenu = uimenu(app.UIFigure);
            app.WavesMenu.Text = 'Waves';

            % Create LoadfromFileMenu_Wave
            app.LoadfromFileMenu_Wave = uimenu(app.WavesMenu);
            app.LoadfromFileMenu_Wave.MenuSelectedFcn = createCallbackFcn(app, @LoadfromFileMenu_WaveSelected, true);
            app.LoadfromFileMenu_Wave.Text = 'Load from File';

            % Create SavetoFileMenu_Wave
            app.SavetoFileMenu_Wave = uimenu(app.WavesMenu);
            app.SavetoFileMenu_Wave.MenuSelectedFcn = createCallbackFcn(app, @SavetoFileMenu_WaveSelected, true);
            app.SavetoFileMenu_Wave.Text = 'Save to File';

            % Create diff_Waveform
            app.diff_Waveform = uiaxes(app.UIFigure);
            title(app.diff_Waveform, 'Difference Between Original and Modified Waveform')
            xlabel(app.diff_Waveform, 'n')
            ylabel(app.diff_Waveform, 'Decibel (dB)')
            zlabel(app.diff_Waveform, 'Z')
            app.diff_Waveform.Position = [107 167 640 162];

            % Create ApplicationVariablesMenu
            app.ApplicationVariablesMenu = uimenu(app.UIFigure);
            app.ApplicationVariablesMenu.Text = 'Application Variables';

            % Create LoadfromFileMenu
            app.LoadfromFileMenu = uimenu(app.ApplicationVariablesMenu);
            app.LoadfromFileMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadfromFileMenuSelected, true);
            app.LoadfromFileMenu.Text = 'Load from File';

            % Create SavetoFileMenu
            app.SavetoFileMenu = uimenu(app.ApplicationVariablesMenu);
            app.SavetoFileMenu.MenuSelectedFcn = createCallbackFcn(app, @SavetoFileMenuSelected, true);
            app.SavetoFileMenu.Text = 'Save to File';

            % Create Menu
            app.Menu = uimenu(app.UIFigure);

            % Create LoadMenu
            app.LoadMenu = uimenu(app.Menu);
            app.LoadMenu.Text = 'Load';

            % Create SaveMenu
            app.SaveMenu = uimenu(app.Menu);
            app.SaveMenu.Text = 'Save';

            % Create equ_Waveform
            app.equ_Waveform = uiaxes(app.UIFigure);
            title(app.equ_Waveform, 'Modified Waveform')
            xlabel(app.equ_Waveform, 'n')
            ylabel(app.equ_Waveform, 'Decibel (dB)')
            zlabel(app.equ_Waveform, 'Z')
            app.equ_Waveform.Position = [107 347 640 162];

            % Create original_Waveform
            app.original_Waveform = uiaxes(app.UIFigure);
            title(app.original_Waveform, 'Original Waveform')
            xlabel(app.original_Waveform, 'n ')
            ylabel(app.original_Waveform, 'Decibel (dB)')
            zlabel(app.original_Waveform, 'Z')
            app.original_Waveform.YTick = [-1 -0.5 0 0.5 1];
            app.original_Waveform.YTickLabel = {'-1'; '-0.5'; '0'; '0.5'; '1'};
            app.original_Waveform.Position = [107 539 640 162];

            % Create lbl_band_1
            app.lbl_band_1 = uilabel(app.UIFigure);
            app.lbl_band_1.Position = [764 662 38 22];
            app.lbl_band_1.Text = '1 KHz';

            % Create VolumeControlPanel
            app.VolumeControlPanel = uipanel(app.UIFigure);
            app.VolumeControlPanel.Title = 'Volume Control';
            app.VolumeControlPanel.Position = [170 50 514 87];

            % Create VolumeControlSwitch
            app.VolumeControlSwitch = uiswitch(app.VolumeControlPanel, 'slider');
            app.VolumeControlSwitch.Position = [32 30 45 20];

            % Create VolumeMultiplierSliderLabel
            app.VolumeMultiplierSliderLabel = uilabel(app.VolumeControlPanel);
            app.VolumeMultiplierSliderLabel.HorizontalAlignment = 'right';
            app.VolumeMultiplierSliderLabel.Position = [118 19 97 43];
            app.VolumeMultiplierSliderLabel.Text = 'Volume Multiplier';

            % Create VolumeMultiplierSlider
            app.VolumeMultiplierSlider = uislider(app.VolumeControlPanel);
            app.VolumeMultiplierSlider.Limits = [0 2];
            app.VolumeMultiplierSlider.ValueChangedFcn = createCallbackFcn(app, @VolumeMultiplierSliderValueChanged, true);
            app.VolumeMultiplierSlider.Position = [229 50 140 3];
            app.VolumeMultiplierSlider.Value = 1;

            % Create EditField_VolumeMultiplier
            app.EditField_VolumeMultiplier = uieditfield(app.VolumeControlPanel, 'numeric');
            app.EditField_VolumeMultiplier.Limits = [0 2];
            app.EditField_VolumeMultiplier.ValueChangedFcn = createCallbackFcn(app, @EditField_VolumeMultiplierValueChanged, true);
            app.EditField_VolumeMultiplier.HorizontalAlignment = 'center';
            app.EditField_VolumeMultiplier.Position = [391 29 66 22];
            app.EditField_VolumeMultiplier.Value = 1;

            % Create CutVariantDropDown
            app.CutVariantDropDown = uidropdown(app.UIFigure);
            app.CutVariantDropDown.Items = {'Bass_Shelf', 'Treble_Shelf'};
            app.CutVariantDropDown.Position = [894 146 100 22];
            app.CutVariantDropDown.Value = 'Bass_Shelf';

            % Create CutVariantDropDownLabel
            app.CutVariantDropDownLabel = uilabel(app.UIFigure);
            app.CutVariantDropDownLabel.HorizontalAlignment = 'right';
            app.CutVariantDropDownLabel.Position = [814 146 65 22];
            app.CutVariantDropDownLabel.Text = 'Cut Variant';

            % Create CutButton
            app.CutButton = uibutton(app.UIFigure, 'push');
            app.CutButton.ButtonPushedFcn = createCallbackFcn(app, @CutButtonPushed, true);
            app.CutButton.Position = [848 105 100 22];
            app.CutButton.Text = 'Cut';

            % Create slider_Band_1
            app.slider_Band_1 = uislider(app.UIFigure);
            app.slider_Band_1.Limits = [-10 10];
            app.slider_Band_1.ValueChangedFcn = createCallbackFcn(app, @slider_Band_1ValueChanged, true);
            app.slider_Band_1.Position = [823 683 150 3];

            % Create editField_Band_1
            app.editField_Band_1 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_1.Limits = [-10 10];
            app.editField_Band_1.ValueChangedFcn = createCallbackFcn(app, @editField_Band_1ValueChanged, true);
            app.editField_Band_1.HorizontalAlignment = 'center';
            app.editField_Band_1.Position = [993 662 48 22];

            % Create slider_Band_2
            app.slider_Band_2 = uislider(app.UIFigure);
            app.slider_Band_2.Limits = [-10 10];
            app.slider_Band_2.ValueChangedFcn = createCallbackFcn(app, @slider_Band_2ValueChanged, true);
            app.slider_Band_2.Position = [823 631 150 3];

            % Create editField_Band_2
            app.editField_Band_2 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_2.Limits = [-10 10];
            app.editField_Band_2.ValueChangedFcn = createCallbackFcn(app, @editField_Band_2ValueChanged, true);
            app.editField_Band_2.HorizontalAlignment = 'center';
            app.editField_Band_2.Position = [993 610 48 22];

            % Create slider_Band_3
            app.slider_Band_3 = uislider(app.UIFigure);
            app.slider_Band_3.Limits = [-10 10];
            app.slider_Band_3.ValueChangedFcn = createCallbackFcn(app, @slider_Band_3ValueChanged, true);
            app.slider_Band_3.Position = [823 581 150 3];

            % Create editField_Band_3
            app.editField_Band_3 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_3.Limits = [-10 10];
            app.editField_Band_3.ValueChangedFcn = createCallbackFcn(app, @editField_Band_3ValueChanged, true);
            app.editField_Band_3.HorizontalAlignment = 'center';
            app.editField_Band_3.Position = [993 560 48 22];

            % Create slider_Band_4
            app.slider_Band_4 = uislider(app.UIFigure);
            app.slider_Band_4.Limits = [-10 10];
            app.slider_Band_4.ValueChangedFcn = createCallbackFcn(app, @slider_Band_4ValueChanged, true);
            app.slider_Band_4.Position = [823 529 150 3];

            % Create editField_Band_4
            app.editField_Band_4 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_4.Limits = [-10 10];
            app.editField_Band_4.ValueChangedFcn = createCallbackFcn(app, @editField_Band_4ValueChanged, true);
            app.editField_Band_4.HorizontalAlignment = 'center';
            app.editField_Band_4.Position = [993 508 48 22];

            % Create slider_Band_5
            app.slider_Band_5 = uislider(app.UIFigure);
            app.slider_Band_5.Limits = [-10 10];
            app.slider_Band_5.ValueChangedFcn = createCallbackFcn(app, @slider_Band_5ValueChanged, true);
            app.slider_Band_5.Position = [823 483 150 3];

            % Create editField_Band_5
            app.editField_Band_5 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_5.Limits = [-10 10];
            app.editField_Band_5.ValueChangedFcn = createCallbackFcn(app, @editField_Band_5ValueChanged, true);
            app.editField_Band_5.HorizontalAlignment = 'center';
            app.editField_Band_5.Position = [993 462 48 22];

            % Create slider_Band_6
            app.slider_Band_6 = uislider(app.UIFigure);
            app.slider_Band_6.Limits = [-10 10];
            app.slider_Band_6.ValueChangedFcn = createCallbackFcn(app, @slider_Band_6ValueChanged, true);
            app.slider_Band_6.Position = [823 431 150 3];

            % Create editField_Band_6
            app.editField_Band_6 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_6.Limits = [-10 10];
            app.editField_Band_6.ValueChangedFcn = createCallbackFcn(app, @editField_Band_6ValueChanged, true);
            app.editField_Band_6.HorizontalAlignment = 'center';
            app.editField_Band_6.Position = [993 410 48 22];

            % Create slider_Band_7
            app.slider_Band_7 = uislider(app.UIFigure);
            app.slider_Band_7.Limits = [-10 10];
            app.slider_Band_7.ValueChangedFcn = createCallbackFcn(app, @slider_Band_7ValueChanged, true);
            app.slider_Band_7.Position = [823 381 150 3];

            % Create editField_Band_7
            app.editField_Band_7 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_7.Limits = [-10 10];
            app.editField_Band_7.ValueChangedFcn = createCallbackFcn(app, @editField_Band_7ValueChanged, true);
            app.editField_Band_7.HorizontalAlignment = 'center';
            app.editField_Band_7.Position = [993 360 48 22];

            % Create slider_Band_8
            app.slider_Band_8 = uislider(app.UIFigure);
            app.slider_Band_8.Limits = [-10 10];
            app.slider_Band_8.ValueChangedFcn = createCallbackFcn(app, @slider_Band_8ValueChanged, true);
            app.slider_Band_8.Position = [823 329 150 3];

            % Create editField_Band_8
            app.editField_Band_8 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_8.Limits = [-10 10];
            app.editField_Band_8.ValueChangedFcn = createCallbackFcn(app, @editField_Band_8ValueChanged, true);
            app.editField_Band_8.HorizontalAlignment = 'center';
            app.editField_Band_8.Position = [993 308 48 22];

            % Create slider_Band_9
            app.slider_Band_9 = uislider(app.UIFigure);
            app.slider_Band_9.Limits = [-10 10];
            app.slider_Band_9.ValueChangedFcn = createCallbackFcn(app, @slider_Band_9ValueChanged, true);
            app.slider_Band_9.Position = [823 282 150 3];

            % Create editField_Band_9
            app.editField_Band_9 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_9.Limits = [-10 10];
            app.editField_Band_9.ValueChangedFcn = createCallbackFcn(app, @editField_Band_9ValueChanged, true);
            app.editField_Band_9.HorizontalAlignment = 'center';
            app.editField_Band_9.Position = [993 261 48 22];

            % Create slider_Band_10
            app.slider_Band_10 = uislider(app.UIFigure);
            app.slider_Band_10.Limits = [-10 10];
            app.slider_Band_10.ValueChangedFcn = createCallbackFcn(app, @slider_Band_10ValueChanged, true);
            app.slider_Band_10.Position = [823 230 150 3];

            % Create editField_Band_10
            app.editField_Band_10 = uieditfield(app.UIFigure, 'numeric');
            app.editField_Band_10.Limits = [-10 10];
            app.editField_Band_10.ValueChangedFcn = createCallbackFcn(app, @editField_Band_10ValueChanged, true);
            app.editField_Band_10.HorizontalAlignment = 'center';
            app.editField_Band_10.Position = [993 209 48 22];

            % Create lbl_band_2
            app.lbl_band_2 = uilabel(app.UIFigure);
            app.lbl_band_2.Position = [764 610 38 22];
            app.lbl_band_2.Text = '3 KHz';

            % Create lbl_band_3
            app.lbl_band_3 = uilabel(app.UIFigure);
            app.lbl_band_3.Position = [764 560 38 22];
            app.lbl_band_3.Text = '5 KHz';

            % Create lbl_band_4
            app.lbl_band_4 = uilabel(app.UIFigure);
            app.lbl_band_4.Position = [764 508 38 22];
            app.lbl_band_4.Text = '7 KHz';

            % Create lbl_band_5
            app.lbl_band_5 = uilabel(app.UIFigure);
            app.lbl_band_5.Position = [764 462 38 22];
            app.lbl_band_5.Text = '9 KHz';

            % Create lbl_band_6
            app.lbl_band_6 = uilabel(app.UIFigure);
            app.lbl_band_6.Position = [764 410 44 22];
            app.lbl_band_6.Text = '11 KHz';

            % Create lbl_band_7
            app.lbl_band_7 = uilabel(app.UIFigure);
            app.lbl_band_7.Position = [764 362 45 22];
            app.lbl_band_7.Text = '13 KHz';

            % Create lbl_band_8
            app.lbl_band_8 = uilabel(app.UIFigure);
            app.lbl_band_8.Position = [764 310 45 22];
            app.lbl_band_8.Text = '15 KHz';

            % Create lbl_band_9
            app.lbl_band_9 = uilabel(app.UIFigure);
            app.lbl_band_9.Position = [764 261 45 22];
            app.lbl_band_9.Text = '17 KHz';

            % Create lbl_band_10
            app.lbl_band_10 = uilabel(app.UIFigure);
            app.lbl_band_10.Position = [764 209 45 22];
            app.lbl_band_10.Text = '19 KHz';

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [20 632 68 22];
            app.PlayButton.Text = 'Play';

            % Create StopButton
            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [20 601 68 22];
            app.StopButton.Text = 'Stop';

            % Create PlayButton_mod
            app.PlayButton_mod = uibutton(app.UIFigure, 'push');
            app.PlayButton_mod.ButtonPushedFcn = createCallbackFcn(app, @PlayButton_modPushed, true);
            app.PlayButton_mod.Position = [20 441 68 22];
            app.PlayButton_mod.Text = 'Play';

            % Create StopButton_mod
            app.StopButton_mod = uibutton(app.UIFigure, 'push');
            app.StopButton_mod.ButtonPushedFcn = createCallbackFcn(app, @StopButton_modPushed, true);
            app.StopButton_mod.Position = [20 410 68 22];
            app.StopButton_mod.Text = 'Stop';

            % Create PlayButton_diff
            app.PlayButton_diff = uibutton(app.UIFigure, 'push');
            app.PlayButton_diff.ButtonPushedFcn = createCallbackFcn(app, @PlayButton_diffPushed, true);
            app.PlayButton_diff.Position = [20 261 68 22];
            app.PlayButton_diff.Text = 'Play';

            % Create StopButton_diff
            app.StopButton_diff = uibutton(app.UIFigure, 'push');
            app.StopButton_diff.ButtonPushedFcn = createCallbackFcn(app, @StopButton_diffPushed, true);
            app.StopButton_diff.Position = [20 230 68 22];
            app.StopButton_diff.Text = 'Stop';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Graphic_Equaliser

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end