clc
clear
close all
initTimer = tic;

% make those variables global so they can be modified by the callback function
global snake1Dir snake2Dir %#ok<*GVMIS>

% zoom level set to 3 makes the scene to be biggest possible
% increase zoom level will cause no difference but decrease the efficiency
engine = simpleGameEngine('./newtest.png', 16, 16, 3, [46 43 42]);

% initialze the music
[y, Fs] = audioread('./Bettermusic.mp3');
player = audioplayer(y, Fs, 16);
play(player);
player.StopFcn = @restart;

% picture id
blank = 1;
snake1 = 7;
snake2 = 10;
snake1Body = 9;
snake2Body = 14;
apple = 4;
snake1left = 5;
snake1up = 6;
snake1right = 7;
snake1down = 8;
snake2left = 10;
snake2right = 11;
snake2up = 12;
snake2down = 13;

% generate a 30x30 boardw
board = ones(30, 30);

% initial snake length
snake1Length = 1;
snake2Length = 1;

% default snake spawn positions
snake1PosR = 1;
snake1PosC = 1;
snake2PosR = 30;
snake2PosC = 30;

% default snake direction, 4 possible directions: u: up, d: down, l: left, r: right
snake1Dir = 'r';
snake2Dir = 'l';

% (head) locations in the last frame of the snake's head
snake1LastPosR = snake1PosR;
snake1LastPosC = snake1PosC;
snake2LastPosR = snake2PosR;
snake2LastPosC = snake2PosC;

% snake previous positions stored in arrays, will be used as snake body
snake1PrevPosR = snake1PosR;
snake1PrevPosC = snake1PosC;
snake2PrevPosR = snake2PosR;
snake2PrevPosC = snake2PosC;

% snake spawn position
board(snake1PosR, snake1PosC) = snake1;
board(snake2PosR, snake2PosC) = snake2;

% initialize apple at a random position
lastApplePos = randi([1 30 * 30], 1, 1);
board(lastApplePos) = apple;

% generate a new apple every x frames if the apple is not eaten, make it a final so it can be restored.
APPLE_REFRESH_INTERVAL = 50;
appleRefreshCounter = APPLE_REFRESH_INTERVAL;

% LOG initialization time
disp("init: " + toc(initTimer));

initDrawTimer = tic;
drawScene(engine, board);

% LOG initial draw time
disp("init draw: " + toc(initDrawTimer));

%display controls
xlabel('Green Snake Controls: W=Up, A=Left, S=Down, D=Right. Purple Snake Controls: Up Arrow=Up, Left Arrow=Left, Down Arrow=Down, Right Arrow=Right.')

% pause until the user presses a key
title("Press 1 for Easy, 2 for Normal, 3 for Expert, or Enter at your own Risk! Press space to exit.");
key = getKeyboardInput(engine);

% reenter if the input is invalid (not 1, 2, 3, enter, or space)
while true

    if ~(strcmp(key, '1') || strcmp(key, '2') || strcmp(key, '3') || strcmp(key, 'return') || strcmp(key, 'space'))
        title("Invalid input. Press 1 for Easy, 2 for Normal, 3 for Expert")
        key = getKeyboardInput(engine);
    else
        break;
    end

end

%decides difficulty by taking users selection and deciding a
%refreshInterval
if strcmp(key, '1') == true
    refreshInterval = 0.25;
elseif strcmp(key, '2') == true
    refreshInterval = 0.18;
elseif strcmp(key, '3') == true
    refreshInterval = 0.1;
elseif strcmp(key, 'return') == true
    refreshInterval = .05;
end


engine.my_figure.KeyPressFcn = @changeDir;

% LOG game start
title("Game started")
disp("game started")

while 1

    while 1
        timer = tic;

        % clear results from last frame
        board(snake1LastPosR, snake1LastPosC) = blank;
        board(snake2LastPosR, snake2LastPosC) = blank;

        % reset snake body (snake previous positions)
        board(snake1PrevPosR, snake1PrevPosC) = blank;
        board(snake2PrevPosR, snake2PrevPosC) = blank;

        % test if the snake will hit itself
        if willHitSelf(snake1PosR, snake1PosC, snake1Dir, snake1PrevPosR, snake1PrevPosC)
            % LOG hit self message
            title("Green Snake Hit Self");
            disp("Green Snake Hit Self");
            break;
        end

        if willHitSelf(snake2PosR, snake2PosC, snake2Dir, snake2PrevPosR, snake2PrevPosC)
            % LOG
            title("Purple Snake Hit Self");
            disp("Purple Snake Hit Self");
            break;
        end

        % test if the snake will hit the other snake
        if strcmp(willHitOtherSnake(snake1PosR, snake1PosC, snake1Dir, snake1PrevPosR, snake1PrevPosC, snake2PosR, snake2PosC, snake2Dir, snake2PrevPosR, snake2PrevPosC), 'snake1')
            title("Green Snake Hit Purple Snake");
            disp("Green Snake Hit Purple Snake");
            break;
        elseif strcmp(willHitOtherSnake(snake1PosR, snake1PosC, snake1Dir, snake1PrevPosR, snake1PrevPosC, snake2PosR, snake2PosC, snake2Dir, snake2PrevPosR, snake2PrevPosC), 'snake2')
            title("Purple Snake Hit Green Snake");
            disp("Purple Snake Hit Green Snake");
            break;
        end

        % move snakes
        % move snake1 based on direction if it can move
        if (willHitWall(snake1PosR, snake1PosC, snake1Dir))

            if snake1Dir == 'u'
                snake1PosR = snake1PosR - 1;
            elseif snake1Dir == 'd'
                snake1PosR = snake1PosR + 1;
            elseif snake1Dir == 'l'
                snake1PosC = snake1PosC - 1;
            elseif snake1Dir == 'r'
                snake1PosC = snake1PosC + 1;
            end

        else
            % LOG hit wall message
            title("Green Snake Hit Wall");
            disp("Green Snake Hit Wall");
            break;
        end

        % move snake2 based on direction if it can move
        if (willHitWall(snake2PosR, snake2PosC, snake2Dir))
            % move snake2 based on direction
            if snake2Dir == 'u'
                snake2PosR = snake2PosR - 1;
            elseif snake2Dir == 'd'
                snake2PosR = snake2PosR + 1;
            elseif snake2Dir == 'l'
                snake2PosC = snake2PosC - 1;
            elseif snake2Dir == 'r'
                snake2PosC = snake2PosC + 1;
            end

        else
            % LOG
            title("Purple Snake Hit Wall");
            disp("Purple Snake Hit Wall");
            break;
        end

        %This changes the way the snake head faces based on direction.
        if snake1Dir == 'u'
            snake1 = snake1up;
        elseif snake1Dir == 'd'
            snake1 = snake1down;
        elseif snake1Dir == 'l'
            snake1 = snake1left;
        elseif snake1Dir == 'r'
            snake1 = snake1right;
        end

        if snake2Dir == 'u'
            snake2 = snake2up;
        elseif snake2Dir == 'd'
            snake2 = snake2down;
        elseif snake2Dir == 'l'
            snake2 = snake2left;
        elseif snake2Dir == 'r'
            snake2 = snake2right;
        end

        % one more layer of check boundary to prevent exceptions in further code
        if snake1PosR < 1 || snake1PosR > 30 || snake1PosC < 1 || snake1PosC > 30
            % LOG
            title("Green Snake Hit Wall");
            disp("Green Snake Hit Wall");
            break;
        end

        if snake2PosR < 1 || snake2PosR > 30 || snake2PosC < 1 || snake2PosC > 30
            % LOG
            title("Purple Snake Hit Wall");
            disp("Purple Snake Hit Wall");
            break;
        end

        % check if the snake head is at the apple position. if so, increase snake length by 1
        snakeWithApple = 0;

        if board(snake1PosR, snake1PosC) == apple
            snakeWithApple = 'snake1';
        elseif board(snake2PosR, snake2PosC) == apple
            snakeWithApple = 'snake2';
        end

        if snakeWithApple ~= 0

            if strcmp(snakeWithApple, 'snake1')
                snake1Length = snake1Length + 1;
            elseif strcmp(snakeWithApple, 'snake2')
                snake2Length = snake2Length + 1;
            end

            % LOG snake length change

            if strcmp(snakeWithApple, 'snake1')
                disp("Green Snake Length: " + snake1Length);
                title("\fontsize {14} Green Snake Length: " + snake1Length);
            elseif strcmp(snakeWithApple, 'snake2')
                disp("Purple Snake Length: " + snake2Length);
                xlabel("\fontsize {14} Purple Snake Length: " + snake2Length);
            end

            % update snake body (snake previous positions)
            snake1PrevPosR = [snake1PrevPosR snake1PosR];
            snake1PrevPosC = [snake1PrevPosC snake1PosC];
            snake2PrevPosR = [snake2PrevPosR snake2PosR];
            snake2PrevPosC = [snake2PrevPosC snake2PosC];

            % after eating the apple, generate a new apple at a random position
            randomPos = randi([1 30 * 30], 1, 1);
            % reset the apple refresh counter back to original value
            appleRefreshCounter = APPLE_REFRESH_INTERVAL;

            % if the apple is generated at the snake's body, regenerate the apple
            while board(randomPos) == snake1 || board(randomPos) == snake2
                randomPos = randi([1 30 * 30], 1, 1);
                lastApplePos = randomPos;
            end

            board(randomPos) = apple;

        else
            % if the apple is not eaten, generate a new apple every x frames
            if appleRefreshCounter == 0
                board(lastApplePos) = blank;
                randomPos = randi([1 30 * 30], 1, 1);

                % regenerate the apple if it is generated at the snake's body
                while board(randomPos) == snake1 || board(randomPos) == snake2
                    randomPos = randi([1 30 * 30], 1, 1);
                end

                lastApplePos = randomPos;
                board(randomPos) = apple;

                % LOG apple refreshed location
                disp("apple refreshed at: " + randomPos);

                % reset apple generate counter
                appleRefreshCounter = APPLE_REFRESH_INTERVAL;
            else
                appleRefreshCounter = appleRefreshCounter - 1;
            end

        end

        % update snake last positions
        snake1LastPosR = snake1PosR;
        snake1LastPosC = snake1PosC;
        snake2LastPosR = snake2PosR;
        snake2LastPosC = snake2PosC;

        % update snake previous positions based on snake length (only keey last n positions)
        snake1PrevPosR = [snake1PrevPosR snake1LastPosR]; %#ok<*AGROW> suppress warning, the size of the array cannot be known in advance
        snake1PrevPosC = [snake1PrevPosC snake1LastPosC];
        snake2PrevPosR = [snake2PrevPosR snake2LastPosR];
        snake2PrevPosC = [snake2PrevPosC snake2LastPosC];

        % cut to keep only snake length number of positions
        snake1PrevPosR = snake1PrevPosR(end - snake1Length + 1:end);
        snake1PrevPosC = snake1PrevPosC(end - snake1Length + 1:end);
        snake2PrevPosR = snake2PrevPosR(end - snake2Length + 1:end);
        snake2PrevPosC = snake2PrevPosC(end - snake2Length + 1:end);

        % draw snake body based on snake length, use the snakePrevPos to draw the snake body
        for i = 1:snake1Length
            board(snake1PrevPosR(i), snake1PrevPosC(i)) = snake1Body;
        end

        for i = 1:snake2Length
            board(snake2PrevPosR(i), snake2PrevPosC(i)) = snake2Body;
        end

        % update snake positions
        board(snake1PosR, snake1PosC) = snake1;
        board(snake2PosR, snake2PosC) = snake2;

        drawSceneTimer = tic;

        drawScene(engine, board);

        % DEBUG monitor drawScene() performance
        if toc(drawSceneTimer) > refreshInterval
            % LOG monitor drawScene() performance
            disp("drawScene() takes too long: " + toc(drawSceneTimer));
        end

        % % pause to keep constant frame rate
        computationTime = toc(timer);
        pause(refreshInterval - computationTime);
    end

    % play deathsound when snake dies
    [y2, Fs2] = audioread('./Deathsound.mp3');
    playerDeath = audioplayer(y2, Fs2, 16); %#ok<*TNMLP>
    play(playerDeath);

    % show game over message
    G = 15;
    A = 16;
    M = 17;
    E = 18;
    O = 19;
    V = 20;
    R = 21;
    board(1:30, 1:30) = blank;
    board(1, 1) = G;
    board(1, 2) = A;
    board(1, 3) = M;
    board(1, 4) = E;
    board(1, 6) = O;
    board(1, 7) = V;
    board(1, 8) = E;
    board(1, 9) = R;

    drawScene(engine, board);

    pause(3);

    %resets purple snake score counter after each game
    xlabel('Green Snake Controls: W=Up, A=Left, S=Down, D=Right. Purple Snake Controls: Up Arrow=Up, Left Arrow=Left, Down Arrow=Down, Right Arrow=Right.')

    % check if the user want to play again
    % pause until the user presses a key
    title("Press 1 for Easy, 2 for Normal, 3 for Expert, or Enter if you Dare! Press space to quit");
    key = getKeyboardInput(engine);

    % reenter if the input is invalid (not 1, 2, or 3)
    while true

        if ~(strcmp(key, '1') || strcmp(key, '2') || strcmp(key, '3') || strcmp(key, 'space') || strcmp(key, 'return'))
            title("Invalid input. Press 1 for Easy, 2 for Normal, 3 for Expert, or Enter if you Dare! Press space to quit.")
            key = getKeyboardInput(engine);
        else
            break;
        end

    end

    %decides difficulty by taking users selection and deciding a
    %refreshInterval
    if strcmp(key, '1') == true
        refreshInterval = 0.25;
    elseif strcmp(key, '2') == true
        refreshInterval = 0.18;
    elseif strcmp(key, '3') == true
        refreshInterval = 0.1;
    elseif strcmp(key, 'return') == true
        refreshInterval = .05;
    elseif strcmp(key, 'space') == true
        break;
    end

    % reset arguments
    % generate a 30x30 board
    board = ones(30, 30);

    % initial snake length
    snake1Length = 1;
    snake2Length = 1;

    % default snake spawn positions
    snake1PosR = 1;
    snake1PosC = 1;
    snake2PosR = 30;
    snake2PosC = 30;

    % default snake direction, 4 possible directions: u: up, d: down, l: left, r: right
    snake1Dir = 'r';
    snake2Dir = 'l';

    % (head) locations in the last frame of the snake's head
    snake1LastPosR = snake1PosR;
    snake1LastPosC = snake1PosC;
    snake2LastPosR = snake2PosR;
    snake2LastPosC = snake2PosC;

    % snake previous positions stored in arrays, will be used as snake body
    snake1PrevPosR = snake1PosR;
    snake1PrevPosC = snake1PosC;
    snake2PrevPosR = snake2PosR;
    snake2PrevPosC = snake2PosC;

    % snake spawn position
    board(snake1PosR, snake1PosC) = snake1;
    board(snake2PosR, snake2PosC) = snake2;

    % initialize apple at a random position
    lastApplePos = randi([1 30 * 30], 1, 1);
    board(lastApplePos) = apple;

    % generate a new apple every x frames if the apple is not eaten, make it a final so it can be restored.
    APPLE_REFRESH_INTERVAL = 50;
    appleRefreshCounter = APPLE_REFRESH_INTERVAL;

    % LOG initialization time
    disp("init: " + toc(initTimer));

    initDrawTimer = tic;
    drawScene(engine, board);

    % LOG initial draw time
    disp("init draw: " + toc(initDrawTimer));

    title("Game start")
    % LOG
    disp("game restart ");

end

close all
clear

%% function testing whether the snake can move to the next position
function willHitWall = willHitWall(snakePosR, snakePosC, snakeDir)

    willHitWall = true;

    % test if the snake will hit the wall
    if snakeDir == 'u'
        snakePosR = snakePosR - 1;

        if snakePosR < 1 || snakePosR > 30
            willHitWall = false;
        end

    elseif snakeDir == 'd'
        snakePosR = snakePosR + 1;

        if snakePosR < 1 || snakePosR > 30
            willHitWall = false;
        end

    elseif snakeDir == 'l'
        snakePosC = snakePosC - 1;

        if snakePosC < 1 || snakePosC > 30
            willHitWall = false;
        end

    end

end

%% function testing whether the snake will hit itself
function willHitSelf = willHitSelf(snakePosR, snakePosC, snakeDir, snakePrevPosR, snakePrevPosC)

    willHitSelf = false;

    % test if the snake will hit itself
    if snakeDir == 'u'
        snakePosR = snakePosR - 1;

        for i = 1:length(snakePrevPosR)

            if snakePosR == snakePrevPosR(i) && snakePosC == snakePrevPosC(i)
                willHitSelf = true;
                break;
            end

        end

    elseif snakeDir == 'd'
        snakePosR = snakePosR + 1;

        for i = 1:length(snakePrevPosR)

            if snakePosR == snakePrevPosR(i) && snakePosC == snakePrevPosC(i)
                willHitSelf = true;
                break;
            end

        end

    elseif snakeDir == 'l'
        snakePosC = snakePosC - 1;

        for i = 1:length(snakePrevPosR)

            if snakePosR == snakePrevPosR(i) && snakePosC == snakePrevPosC(i)
                willHitSelf = true;
                break;
            end

        end

    elseif snakeDir == 'r'
        snakePosC = snakePosC + 1;

        for i = 1:length(snakePrevPosR)

            if snakePosR == snakePrevPosR(i) && snakePosC == snakePrevPosC(i)
                willHitSelf = true;
                break;
            end

        end

    end

end

%% function testing whether the snake will hit the other snake
function willHitOtherSnake = willHitOtherSnake(snakePosR, snakePosC, snakeDir, snakePrevPosR, snakePrevPosC, otherSnakePosR, otherSnakePosC, otherSnakeDir, otherSnakePrevPosR, otherSnakePrevPosC)

    willHitOtherSnake = false;

    % get position at next frame
    % update snake position
    if snakeDir == 'u'
        snakePosR = snakePosR - 1;
    elseif snakeDir == 'd'
        snakePosR = snakePosR + 1;
    elseif snakeDir == 'l'
        snakePosC = snakePosC - 1;
    elseif snakeDir == 'r'
        snakePosC = snakePosC + 1;
    end

    % update snake body positions (previous positions)
    if snakeDir == 'u'
        snakePrevPosR = [snakePosR + 1, snakePrevPosR(1:end - 1)];
        snakePrevPosC = [snakePosC, snakePrevPosC(1:end - 1)];
    elseif snakeDir == 'd'
        snakePrevPosR = [snakePosR - 1, snakePrevPosR(1:end - 1)];
        snakePrevPosC = [snakePosC, snakePrevPosC(1:end - 1)];
    elseif snakeDir == 'l'
        snakePrevPosR = [snakePosR, snakePrevPosR(1:end - 1)];
        snakePrevPosC = [snakePosC + 1, snakePrevPosC(1:end - 1)];
    elseif snakeDir == 'r'
        snakePrevPosR = [snakePosR, snakePrevPosR(1:end - 1)];
        snakePrevPosC = [snakePosC - 1, snakePrevPosC(1:end - 1)];
    end

    % update other snake position
    if otherSnakeDir == 'u'
        otherSnakePosR = otherSnakePosR - 1;
    elseif otherSnakeDir == 'd'
        otherSnakePosR = otherSnakePosR + 1;
    elseif otherSnakeDir == 'l'
        otherSnakePosC = otherSnakePosC - 1;
    elseif otherSnakeDir == 'r'
        otherSnakePosC = otherSnakePosC + 1;
    end

    % update other snake body positions (previous positions)
    if otherSnakeDir == 'u'
        otherSnakePrevPosR = [otherSnakePosR + 1, otherSnakePrevPosR(1:end - 1)];
        otherSnakePrevPosC = [otherSnakePosC, otherSnakePrevPosC(1:end - 1)];
    elseif otherSnakeDir == 'd'
        otherSnakePrevPosR = [otherSnakePosR - 1, otherSnakePrevPosR(1:end - 1)];
        otherSnakePrevPosC = [otherSnakePosC, otherSnakePrevPosC(1:end - 1)];
    elseif otherSnakeDir == 'l'
        otherSnakePrevPosR = [otherSnakePosR, otherSnakePrevPosR(1:end - 1)];
        otherSnakePrevPosC = [otherSnakePosC + 1, otherSnakePrevPosC(1:end - 1)];
    elseif otherSnakeDir == 'r'
        otherSnakePrevPosR = [otherSnakePosR, otherSnakePrevPosR(1:end - 1)];
        otherSnakePrevPosC = [otherSnakePosC - 1, otherSnakePrevPosC(1:end - 1)];
    end

    %Allows for Collision between the snake heads
    if snakePosR == otherSnakePosR && snakePosC == otherSnakePosC
        willHitOtherSnake = 'snake1';
    end

    % perform collision detection
    % use for loop since including vector comparison
    for i = 1:length(otherSnakePrevPosR)

        if snakePosR == otherSnakePrevPosR(i) && snakePosC == otherSnakePrevPosC(i)
            willHitOtherSnake = 'snake1';
            break;
        end

    end

    % test snake body
    if willHitOtherSnake == false

        for i = 1:length(snakePrevPosR)

            if snakePrevPosR(i) == otherSnakePosR && snakePrevPosC(i) == otherSnakePosC
                willHitOtherSnake = 'snake2';
                break;
            end

        end

    end

end

%% function to handle keyboard input and change snake direction
function changeDir(~, event)
    global snake1Dir snake2Dir
    key = event.Key;

    % LOG
    disp("key pressed: " + key);

    if strcmp(key, 'uparrow')
        snake2Dir = 'u';
    elseif strcmp(key, 'downarrow')
        snake2Dir = 'd';
    elseif strcmp(key, 'leftarrow')
        snake2Dir = 'l';
    elseif strcmp(key, 'rightarrow')
        snake2Dir = 'r';
    elseif strcmp(key, 'w')
        snake1Dir = 'u';
    elseif strcmp(key, 's')
        snake1Dir = 'd';
    elseif strcmp(key, 'a')
        snake1Dir = 'l';
    elseif strcmp(key, 'd')
        snake1Dir = 'r';
    end

end

function restart(src, ~)
    play(src);
    disp('music restarted');
end
