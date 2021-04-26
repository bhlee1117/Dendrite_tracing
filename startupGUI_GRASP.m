function [filename_movies] = startupGUI_GRASP(ss)

GUIreturns.userExit = false;

globalOptions = [];
candidateOptions = [];
refinementOptions = [];
trackingOptions = [];

candidateData_loaded = [];
refinementData_loaded = [];
movieSize_loaded = [];
firstFrame_lastFrame_loaded = [];
outputPath_loaded = -1;

filename_movies ={};

% -- Preparing the GUI --
h_main = openfig('startupGUI_Layout_GRASP.fig');
set(h_main,'handleVisibility','on'); % Make figure visible to Matlab (might not be the case)
set(h_main,'CloseRequestFcn',@onAppClose); % For cleanup
movegui(h_main,'center');
hold all
title(ss)
axis off

h_all = guihandles(h_main);

% Setup GUI elements
set(h_all.button_addMovies, 'Callback', @callback_addMovies);
set(h_all.button_removeMovie, 'Callback', @callback_removeMovie);
%set(h_all.button_load, 'Callback', @callback_loadSettings);
set(h_all.button_start, 'Callback',@callback_exit);


% % GUI main
uiwait(h_main);
drawnow; % makes figure disappear instantly (otherwise it looks like it is existing until script finishes)

% Load settings from a file
    function callback_loadSettings(hObj,event)        
        [infile, path] = uigetfile({'*.mat','TNT settings'});
        if isfloat(infile);
            return;
        end; % User clicked cancel
        
        outputPath_loaded = path;
        
        % Note: Loading has to be done this way, as variables "can not be
        % added to a static workspace" (e.g. the one of this GUI).
        warning off
        allOptions = load([path,infile],'globalOptions', 'candidateOptions','refinementOptions','trackingOptions','filename_movie','candidateData','refinementData','movieSize','firstFrame_lastFrame');
        warning on
        globalOptions   = allOptions.globalOptions;
        candidateOptions = allOptions.candidateOptions;
        refinementOptions   = allOptions.refinementOptions;
        if isfield(allOptions,'trackingOptions')
            trackingOptions  = allOptions.trackingOptions;
        end
        if isfield(allOptions,'candidateData')
            candidateData_loaded  = allOptions.candidateData;
        end
        if isfield(allOptions,'refinementData')
            refinementData_loaded  = allOptions.refinementData;
        end
        if isfield(allOptions,'movieSize')
            movieSize_loaded  = allOptions.movieSize;
        end
        if isfield(allOptions,'firstFrame_lastFrame')
            firstFrame_lastFrame_loaded  = allOptions.firstFrame_lastFrame;
        end
        
        filename_movies = {allOptions.filename_movie};
        
        callback_exit();
    end

% Opens a file chooser dialog to choose multiple input (movie) files
% for processing. Note: filenames will be seperated by ';'
    function callback_addMovies(hObj,event)
        % Get current text field to set starting path of uigetfile
        filename_movies = get(h_all.listbox_movieList,'String');
        
        % We have to do this, since repopulating a listbox does not
        % automatically reset its value..
        if numel(filename_movies) == 0
            set(h_all.listbox_movieList,'Value',1);
        end
        
        path = pwd;
        if ~isempty(filename_movies)
            [path,~,~] = fileparts(filename_movies{end});
        end
        [movieList, path] = uigetfile([path,filesep,'*.tif'],'MultiSelect','on');
        if( isfloat(movieList) ); return; end; % User pressed cancel.
        
        % atach path to every entry in the list then add to listbox
        if iscell(movieList)
            for i=1:length(movieList)
                movieList{i} =  [path,movieList{i}];
            end
            % Add to listbox
            filename_movies = [filename_movies; movieList.'];
        elseif ischar(movieList)
            movieList = [path,movieList];
            % Add to listbox
            filename_movies = [filename_movies; {movieList}];
        end
        
        set(h_all.listbox_movieList,'String',filename_movies);
        
        % Enable the Start button
        if numel(filename_movies) > 0
            set(h_all.button_start,'Enable','on');
        end
    end

% Remove a movie from the movie list
    function callback_removeMovie(hObj,event)
        selected_entry = get(h_all.listbox_movieList,'Value');
        filename_movies = get(h_all.listbox_movieList,'String');
        
        % When listbox is empty, do nothing
        if numel(filename_movies) == 0
           return; 
        end
        
        % When last selected item is deleted, select the one before it
        if selected_entry == numel(filename_movies)
            set(h_all.listbox_movieList,'Value',selected_entry-1);
        end
        
        filename_movies(selected_entry) = [];
        set(h_all.listbox_movieList,'String',filename_movies);
        
        % Disable the Start button
        if numel(filename_movies) == 0
            set(h_all.button_start,'Enable','off');
        end
    end



    function callback_exit(hObj, event)
        delete(h_main);
    end

% Called when closing the application via the 'X' button (or via close)
    function onAppClose(hObj, event)
        GUIreturns.userExit = true;
        delete(h_main);
    end

end
