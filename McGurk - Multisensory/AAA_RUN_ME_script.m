clear all
Screen('Preference', 'SkipSyncTests', 1); 
InitializePsychSound;
% enter subjects information
subjID = input('Subject ID (e.g., 01xyz): ','s');
data.subjID = str2num(subjID);

sex = 'm';
if data.subjID > 50
    sex = 'f';
end
%sex = input('Subject sex (m or f): ','s');
data.sex=sex;

age = input('Subject age: ','s');
data.age = str2num(age);

date = date;
data.date = date;

%make AV order
modality = [3 3 3];
phonemes = ['b' 'g' 'd'];
phonMod = [1 2 3];
weights = [5 5 5];  %changed from 20 20 20 to 5 5 5
maxTrialsAV = sum(weights);
order = zeros(maxTrialsAV,2);
for i = 1:length(modality)
    order(sum(weights(1:i))-weights(i)+1:sum(weights(1:i)),2) = modality(i);
    order(sum(weights(1:i))-weights(i)+1:sum(weights(1:i)),1) = phonMod(i);
end
%randomize AV trial orders
newOrder=randperm(maxTrialsAV);
for i=1:maxTrialsAV
    stimOrderAV(i,:)=order(newOrder(i),:);
end
clear newOrder order

%make unisensory order
%modality = [1 2 1 2];
%phonemes = ['b' 'g' 'd'];
%phonMod = [1 1 2 2];
%weights = [7 7 7 7];
%maxTrialsU = sum(weights);
%order = zeros(maxTrialsU,2);
%for i = 1:length(modality)
%    order(sum(weights(1:i))-weights(i)+1:sum(weights(1:i)),1) = modality(i);
%    order(sum(weights(1:i))-weights(i)+1:sum(weights(1:i)),2) = phonMod(i);
%end
%
%randomize trial orders
%newOrder=randperm(maxTrialsU);
%for i=1:maxTrialsU
%    stimOrderU(i,:)=order(newOrder(i),:);
%end
%clear newOrder order

maxTrials = maxTrialsAV;% maxTrialsU;
stimOrder = stimOrderAV;
%stimOrder(length(stimOrderAV(:,1))+1:maxTrials,:) = stimOrderU;

data.stimOrder=stimOrder;
data.stimOrder_guide.Column1= 'modality: 1=A, 2=V, 3=AV';
data.stimOrder_guide.Column2 = 'temporal offset, + is VA, negative is AV';
data.stimOrder_guide.Column3 = 'order, 0 = sync, 1 = V first, 2 = A first';

%create file name to save
repeat=1;
while 1
    fname=sprintf('%s%sDATA%s%s_avMcGurk_%d.mat',pwd,filesep,filesep,subjID,repeat);
    if exist(fname)==2,
        repeat=repeat+1;
    else
        break;
    end
end

[outRect hz win0 rect0 cWhite0 cBlack0 cGrey0 scr0]= OpenScreenTwo;

%visual stimuli % stimulus RECT
load fixation400
fixSize = 400;
fixRect = [1 1 fixSize fixSize];
cross = Screen('MakeTexture',win0,fixation);
load stimuli
audioHz = 44000;

%adjust timing to make ba correct
change = 0;%6000;
ga_aud=[ga_aud(change+1:length(ga_aud)) zeros(1,change)];
ba_aud=[ba_aud(change+1:length(ba_aud)) zeros(1,change)];

%increase volume
ba_aud = ba_aud*1.5;
ga_aud = ga_aud*1.5;
tha_aud = tha_aud*1.5;

%create audio noise
audioNoiseLevel = .05;
audioNoise = randn(1,floor(length(ba_aud)/10));
noise = audioplayer(audioNoise*audioNoiseLevel,4400);

%create audio files
%ba_aud = ba_aud/1.5 + audioNoise/30;
%ga_aud = ga_aud/1.5 + audioNoise/30;
%tha_aud = tha_aud/1.5 + audioNoise/30;
ba_audio = audioplayer(ba_aud,audioHz);
ga_audio = audioplayer(ga_aud,audioHz);
tha_audio = audioplayer(tha_aud,audioHz);

videoFrames = 60;
for i = 1:videoFrames
    ba_v(i) = Screen('MakeTexture',win0,ba_video(:,:,i));
    ga_v(i) = Screen('MakeTexture',win0,ga_video(:,:,i));
    tha_v(i) = Screen('MakeTexture',win0,tha_video(:,:,i));
    %bga_v(i) = Screen('MakeTexture',win0,bga_video(:,:,i));
end

%hello testing
stimSize=length(ba_video(:,1,1));
stimRect = [1 1 stimSize stimSize];
rectS=CenterRect([1 1 stimSize stimSize],rect0);

%allTrials(trial, modality, stimlevel, stimulus, onset time, word time,
%offset time, response, corect response, mark)
allTrials=zeros(1,10);

% create responses
allKeys='bgd';
ba = 'b';
ga = 'g';
tha = 't';
da = 'd';
la = 'l';

key='';
while 1,
    %wait screen
    Screen('DrawText',win0,'You will be presented with a speaker saying a syllable.',50,50,cWhite0);
    Screen('DrawText',win0,'Please report what syllable the speaker said.',50,100,cWhite0);
    Screen('DrawText',win0,'If she said "ba", press "b".',50,150,cWhite0);
    Screen('DrawText',win0,'If she said "ga", press "g".',50,200,cWhite0);
    Screen('DrawText',win0,'If she said "da", press "d".',50,250,cWhite0);
    Screen('DrawText',win0,'If she said "tha", press "t".',50,300,cWhite0);
    Screen('DrawText',win0,'Press the spacebar to continue.',50,450,cWhite0);
    Screen('DrawText',win0,'Average completion time (60) = 3 minutes.',50,600,cWhite0);
    Screen('Flip',win0);
    if CharAvail
        key=GetChar;
    end
        if findstr(key,' '),
        break;
    end;
end

%%%Begin experiment
tic;

Screen('FillRect',win0,0, rect0);
Screen('CopyWindow', cross, win0, fixRect, rectS)
Screen('Flip',win0);
HideCursor;

ans=0;
trial=1;

while trial<=maxTrials
    
    %TAKE A BREAK EVERY 100 TRIALS
    if trial > 1
        if mod(trial,100) == 0
            Screen('DrawText',win0,'Take a break if needed. Press the spacebar to continue.',50,450,cWhite0);
            Screen('Flip',win0);
            
            key='';
            while 1,
                key=GetChar;
                if findstr(key,' '),
                    break;
                end;
            end
        end
    end
    
%    if trial == length(stimOrderAV(:,1))+1
%        Screen('DrawText',win0,'Trials are now switching from audiovisual to either audio OR visual. Press the spacebar to continue.',50,450,cWhite0);
%        Screen('Flip',win0);
%                key='';
%        while 1,
%            key=GetChar;
%            if findstr(key,' '),
%                break;
%            end;
%        end
%    end
    
    FlushEvents('keydown');
    % update variable allTrials with next trials info
    allTrials(trial,1)=trial;
    allTrials(trial,2)=stimOrder(trial,1);
    allTrials(trial,3)=stimOrder(trial,2);
    %allTrials(trial,4)=stimOrder(trial,3);
    
    %find correct answer for upcomming trial
    corAns(trial) = stimOrder(trial,1);
    allTrials(trial,11)=corAns(trial);
    data.responses(trial,1)=corAns(trial);
    
    % put up ready screen
    Screen('CopyWindow', cross, win0, fixRect, rectS)
    Screen('Flip',win0);
    
    WaitSecs(.5+rand);
    
    FlushEvents('keydown');
    response = 0;
    
 %A
    if stimOrder(trial,2)== 1
        clear audioFile
        %choose proper stimulus files
        if stimOrder(trial,1) == 1
            audioFile = ba_audio;
        elseif stimOrder(trial,1) == 2
            audioFile = ga_audio;
        elseif stimOrder(trial,1) == 3
            audioFile = tha_audio;
        end
        Screen('CopyWindow', cross, win0, fixRect, rectS)
        Screen('Flip',win0);
        %WaitSecs(0.001);
        play(audioFile);%play(noise);
        timeA = toc;
        Screen('CopyWindow', cross, win0, fixRect, rectS)
        Screen('Flip',win0);
        timeV = toc;
        Screen('CopyWindow', cross, win0, fixRect, rectS)
        Screen('Flip',win0);
        for i = 2:videoFrames
            Screen('CopyWindow', cross, win0, fixRect, rectS)
            Screen('Flip',win0);
            if response == 0
                if CharAvail
                    RT=toc;
                    response = 1;
                end
            end
            Screen('CopyWindow', cross, win0, fixRect, rectS)
            Screen('Flip',win0);
            if response == 0
                if CharAvail
                    RT=toc;
                    response = 1;
                end
            end
        end
        realDelay = (timeA-timeV)*1000;
    end
    
        %V 
    if stimOrder(trial,2)== 2
        %choose proper stimulus files
        if stimOrder(trial,1) == 1
            video = ba_v;
        elseif stimOrder(trial,1) == 2
            video = ga_v;
        elseif stimOrder(trial,1) == 3
            video = tha_v;
        end
        Screen('CopyWindow', cross, win0, fixRect, rectS)
        Screen('Flip',win0);
        %WaitSecs(0.001);
        timeA = toc;
        Screen('CopyWindow', video(1), win0, stimRect, rectS)
        Screen('Flip',win0);
        timeV = toc;
        Screen('CopyWindow', video(1), win0, stimRect, rectS)
        Screen('Flip',win0);
        for i = 2:videoFrames
            Screen('CopyWindow', video(i), win0, stimRect, rectS)
            Screen('Flip',win0);
            if response == 0
                if CharAvail
                    RT=toc;
                    response = 1;
                end
            end
            Screen('CopyWindow', video(i), win0, stimRect, rectS)
            Screen('Flip',win0);
            if response == 0
                if CharAvail
                    RT=toc;
                    response = 1;
                end
            end
        end
        realDelay = (timeA-timeV)*1000;
    end
    
    %AV 
    if stimOrder(trial,2)== 3
        clear audioFile
        %choose proper stimulus files
        if stimOrder(trial,1) == 1
            audioFile = ba_audio;
            video = ba_v;
        elseif stimOrder(trial,1) == 2
            audioFile = ga_audio;
            video = ga_v;
        elseif stimOrder(trial,1) == 3
            audioFile = tha_audio;
            video = tha_v;
        end
        Screen('CopyWindow', cross, win0, fixRect, rectS)
        Screen('Flip',win0);
        WaitSecs(0.0055);
        play(audioFile);%play(noise);
        timeA = toc;
        Screen('CopyWindow', video(1), win0, stimRect, rectS)
        Screen('Flip',win0);
        timeV = toc;
        for j = 1:2
            Screen('CopyWindow', video(1), win0, stimRect, rectS)
            Screen('Flip',win0);
        end
        for i = 2:videoFrames
            for j = 1:3
                Screen('CopyWindow', video(i), win0, stimRect, rectS)
                Screen('Flip',win0);
                if response == 0
                    if CharAvail
                        RT=toc;
                        response = 1;
                    end
                end
            end
        end
        realDelay = (timeA-timeV)*1000;
    end
    
    Screen('CopyWindow', cross, win0, fixRect, rectS)
    Screen('Flip',win0);
    
    allTrials(trial,5)=timeA;
    allTrials(trial,6)=timeV;
    allTrials(trial,7)=realDelay;
    allTrials(trial,8) = allTrials(trial,7)-allTrials(trial,3);
    
    data.timing(trial,1)=allTrials(trial,5);
    data.timing(trial,2)=allTrials(trial,6);
    data.timing(trial,3)=allTrials(trial,7);
    
    %present response screen
    WaitSecs(.25);
    Screen('DrawText',win0,'What did she say? b, g, d, or th?',outRect(3)/2-140,outRect(4)/2+50,cWhite0);
    Screen('Flip',win0);
    
    %collect response
    ans=0;
    while ans==0
        while CharAvail
            key=GetChar;
            %key = 'b';
            if key=='b'
                if response == 0
                    RT=toc;
                end                    
                allTrials(trial,9)=RT;
                ans(trial)=1;
                allTrials(trial,12)=ans(trial);
                if allTrials(trial,11)==allTrials(trial,12)
                    mark(trial)=1;
                else
                    mark(trial)=0;
                end
            elseif key=='g'
                if response == 0
                    RT=toc;
                end
                allTrials(trial,9)=RT;
                ans(trial)=2;
                allTrials(trial,12)=ans(trial);
                if allTrials(trial,11)==allTrials(trial,12)
                    mark(trial)=1;
                else
                    mark(trial)=0;
                end
            elseif key=='d'
                if response == 0
                    RT=toc;
                end
                allTrials(trial,9)=RT;
                ans(trial)=3;
                allTrials(trial,12)=ans(trial);
                if allTrials(trial,11)==allTrials(trial,12)
                    mark(trial)=1;
                else
                    mark(trial)=0;
                end
            elseif key=='t'
                if response == 0
                    RT=toc;
                end
                allTrials(trial,9)=RT;
                ans(trial)=4;
                allTrials(trial,12)=ans(trial);
                if allTrials(trial,11)==3
                    mark(trial)=1;
                else
                    mark(trial)=0;
                end
            elseif key=='l'
                if response == 0
                    RT=toc;
                end
                allTrials(trial,9)=RT;
                ans(trial)=5;
                allTrials(trial,12)=ans(trial);
                if allTrials(trial,11)==3
                    mark(trial)=1;
                else
                    mark(trial)=0;
                end
            end
        end
    end
    
    allTrials(trial,10)=allTrials(trial,9)-min([allTrials(trial,5) allTrials(trial,6)]);
    
    data.responses(trial,2)=ans(trial);
    if allTrials(trial,11)==allTrials(trial,12)
        mark(trial)=1;
    else
        mark(trial)=0;
    end
    allTrials(trial,13)=mark(trial);
    data.responses(trial,3)=mark(trial);
    
    data.timing(trial,4)=allTrials(trial,9);
    FlushEvents('keydown');
    
    data.allTrials=allTrials;
    
    save(fname,'data','allTrials');
    
    trial=trial+1;
end

Screen('FillRect',win0,160, rect0);
Screen('DrawText',win0,'saving...',300,rect0(4)/2,0);
Screen('Flip',win0);

clear SF trim  trial key ans mark corAns rectS ba_audio ba_video ga_audio ga_video tha_video tha_audio bga_audio bga_video bga_aud ga_aud ba_aud tha_aud audioFile audioNoise fixation noise video;

save(fname);

ShowCursor;

Screen('FillRect',win0,0, rect0);
Screen('DrawText',win0,'Thanks for your participation. Press spacebar to exit.',100,rect0(4)/2,255);
Screen('Flip',win0);

key='';
while 1,
    key=GetChar;
    if findstr(key,' '),
        break;
    end;
end

Screen('closeAll');

for i = 1:3
    I = find(allTrials(:,11) == i);
    temp = allTrials(I,:);
    J = find(temp(:,12) > 2);
    accuracies(i,1) = length(J)/length(I);
    clear temp I J
end

plot([1:3],[accuracies(1) accuracies(3) accuracies(2)]);
save(fname);

graph = 'should peak in the middle'