% OSU Coding Project 
% Tim, Andrew, Riley, Solomon
% ver: 04162021
function [] = main()

    clc
    clear

    addpath("module");

    % Game Parameters
    SYS_FPS = 10;
    WIDTH = 1000;
    HEIGHT = 800;
    STEP = 1/SYS_FPS;

    running = true;
    window = [];
    windowAxis = [];
    
    world = [];
    
    function NewWindow()
        % left, bottom, width, height
        screen = get(0, "ScreenSize");
        window = figure("Position", [ ...
                (screen(3)-WIDTH) / 2, ...
                (screen(4)-HEIGHT) / 2, ... 
                WIDTH, ...
                HEIGHT],...
                'Name', 'GAME', 'MenuBar', 'none', 'Toolbar', 'none' );
        set(window, 'Resize', 'off');
        
        %set(window, "KeyReleaseFcn", @keyUp);
        windowAxis = axes( 'Parent', window, 'Units', 'pixels', ...
                  'Position', [ 0, 0, WIDTH, HEIGHT ], ...
                  'xlim', [0 WIDTH], 'ylim', [0, HEIGHT], ...
                  'DataAspectRatio', [1, 1, 1] );
        axis manual; 
        set(windowAxis, 'color', [0,0,0], 'YTick', [], 'XTick', []);

        hold on;
    end

    function InitSys()
        world = c_world(WIDTH, HEIGHT, window);
    end

    function close()
        running = false;
    end

    NewWindow();
    InitSys();
    timer = now();
    while running
        world.Update();
        nextFrame = STEP - (now() - timer)/86400;
        if nextFrame > 0
            pause(nextFrame);
        end
        timer = now();
    end
    
    close(window);

end
