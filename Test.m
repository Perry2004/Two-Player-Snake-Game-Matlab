clear
clc
close all

[y, Fs] = audioread('./Bettermusic.mp3');
player = audioplayer(y, Fs, 16);
play(player);

[y2, Fs2] = audioread('./Deathsound.mp3');
player2 = audioplayer(y2, Fs2, 16);
play(player2);

player.StopFcn = @restart;

function restart(src, ~) 
    play(src);
    disp('restarted');
end