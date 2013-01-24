% Object Configuration.
% Create an analog input object with one channel.
clear;
[y, fs, nbits] = wavread('thirty.wav');
player = audioplayer(y, fs);
ai = analoginput('winsound');
addchannel(ai, 1);
% Configure the analog input object.
set(ai, 'SampleRate', 44100);
timePeriod = 0.1;
%%
% Configure the analog input object to trigger manually twice.
set(ai, 'SamplesPerTrigger', timePeriod*ai.sampleRate);
tic
count = 300;
avg = zeros(count+1,1);
localavg = zeros(count,1);
lcount = 0;
out = zeros(count,1);
for i = 1:count
    start(ai);
    wait(ai, timePeriod);
    [d,time] = getdata(ai, ai.SamplesPerTrigger);
    localavg(i) = mean(d.^2);
    avg(i+1) = avg(i) + (localavg(i) - avg(i)) / 20;
    thres = max(0.4 * avg(i+1), 0.001);
    if localavg(i) > avg(i+1) + thres
        disp('1');
        if i > 10
            out(i) = 1;
            if(isplaying(player))
                pause(player);
            end
            lcount = 20;
        end
    else
        if lcount <= 0
            disp('0');
            out(i) = 0;
            if(~isplaying(player))
                resume(player);
            end
        else
            lcount = lcount - 1;
            disp('01');
            out(i) = 1;
        end
    end
end
toc
thres = max(0.1 * avg, 0.001);
plot(avg); hold on; plot(localavg,'r'); plot(thres+avg,'m'); plot(out/10,'k');
stop(player);