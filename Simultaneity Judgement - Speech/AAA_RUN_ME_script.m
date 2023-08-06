clear allInitializePsychSound;% enter subjects informationsubjID = input('Subject ID (e.g., 01xyz): ','s');data.subjID = str2num(subjID);sex = 'm';if data.subjID > 50    sex = 'f';end%sex = input('Subject sex (m or f): ','s');data.sex=sex;age = input('Subject age: ','s');data.age = str2num(age);date = date;data.date = date;%make order%offsets = [0];offsets = [400 300 250 200 150 100 50 0 -50 -100 -150 -200 -250 -300 -400];phonemes = ['b' 'g'];weights = [10 10];trials = sum(weights);perCondition(1 : weights(1)) = 1;perCondition(weights(1)+1 : weights(1)+weights(2)) = 2;maxTrials = length(offsets)* trials;order = zeros(maxTrials,3);for i = 1:length(offsets)    order(i*trials-trials+1:i*trials,2) = offsets(i);    order(i*trials-trials+1:i*trials,1) = perCondition;    if offsets(i) == 0        order(i*trials-trials+1:i*trials,3) = 0;    elseif offsets(i) > 0        order(i*trials-trials+1:i*trials,3) = 1;    elseif offsets(i) < 0        order(i*trials-trials+1:i*trials,3) = 2;    endend%randomize trial ordersnewOrder=randperm(maxTrials);for i=1:maxTrials    stimOrder(i,:)=order(newOrder(i),:);endclear newOrder orderdata.stimOrder=stimOrder;data.stimOrder_guide.Column1= 'modality: 1=A, 2=V, 3=AV';data.stimOrder_guide.Column2 = 'temporal offset, + is VA, negative is AV';data.stimOrder_guide.Column3 = 'order, 0 = sync, 1 = V first, 2 = A first';%create file name to saverepeat=1;while 1    fname=sprintf('%s%sDATA%s%s_percSync_%d.mat',pwd,filesep,filesep,subjID,repeat);    if exist(fname)==2,        repeat=repeat+1;    else        break;    endend[outRect hz win0 rect0 cWhite0 cBlack0 cGrey0 scr0]= OpenScreenTwo;HideCursor;%visual stimuli % stimulus RECTload fixation400fixSize = 400;fixRect = [1 1 fixSize fixSize];cross = Screen('MakeTexture',win0,fixation);load stimuliaudioHz = 44000;%adjust timing to make ba correctchange = 0;%6000;ga_aud=[ga_aud(change+1:length(ga_aud)) zeros(1,change)];ba_aud=[ba_aud(change+1:length(ba_aud)) zeros(1,change)];%increase volumeba_aud = ba_aud*1.5;ga_aud = ga_aud*1.5;tha_aud = tha_aud*1.5;%create audio noiseaudioNoiseLevel = .03;audioNoise = randn(1,floor(length(ba_aud)/10));noise = audioplayer(audioNoise*audioNoiseLevel,4400);%create audio filesba_audio = audioPlayer(ba_aud,audioHz);ga_audio = audioPlayer(ga_aud,audioHz);tha_audio = audioPlayer(tha_aud,audioHz);videoFrames = 60;for i = 1:videoFrames    ba_v(i) = Screen('MakeTexture',win0,ba_video(:,:,i));    ga_v(i) = Screen('MakeTexture',win0,ga_video(:,:,i));    tha_v(i) = Screen('MakeTexture',win0,tha_video(:,:,i));    %bga_v(i) = Screen('MakeTexture',win0,bga_video(:,:,i));endstimSize=length(ba_video(:,1,1));stimRect = [1 1 stimSize stimSize];rectS=centerRect([1 1 stimSize stimSize],rect0);%allTrials(trial, modality, stimlevel, stimulus, onset time, word time,%offset time, response, corect response, mark)allTrials=zeros(1,10);% create responsesallKeys='12';sync = '1';async = '2';key='';while 1,    %wait screen    Screen('DrawText',win0,'You will be presented with a speaker saying a syllable.',50,50,cWhite0);    Screen('DrawText',win0,'If the audio and visual were SYNCHRONOUS, ',50,100,cWhite0);    Screen('DrawText',win0,'if the were properly lined up, press 1.',75,150,cWhite0);    Screen('DrawText',win0,'If the audio and visual were ASYNCHRONOUS,',50,250,cWhite0);    Screen('DrawText',win0,'if they were NOT properly lined up, press 2.',75,300,cWhite0);    Screen('DrawText',win0,'Press the spacebar to continue.',50,450,cWhite0);    Screen('Flip',win0);    if CharAvail        key=GetChar;    end    if findstr(key,' '),        break;    end;end%%%Begin experimenttic;Screen('FillRect',win0,0, rect0);Screen('CopyWindow', cross, win0, fixRect, rectS)Screen('Flip',win0);ans=0;trial=1;while trial<=maxTrials        %TAKE A BREAK EVERY 100 TRIALS    if trial > 1        if mod(trial,100) == 0            Screen('DrawText',win0,'Take a break if needed. Press the spacebar to continue.',50,450,cWhite0);            Screen('Flip',win0);                        key='';            while 1,                key=GetChar;                if findstr(key,' '),                    break;                end;            end        end    end        flushevents('keydown');    % update variable allTrials with next trials info    allTrials(trial,1)=trial;    allTrials(trial,2)=stimOrder(trial,1);    allTrials(trial,3)=stimOrder(trial,2);    allTrials(trial,4)=stimOrder(trial,3);        %find correct answer for upcomming trial    if stimOrder(trial,3) ==0        corAns(trial) = 1;    else        corAns(trial) = 2    end    allTrials(trial,11)=corAns(trial);    data.responses(trial,1)=corAns(trial);        % put up ready screen    Screen('CopyWindow', cross, win0, fixRect, rectS)    Screen('Flip',win0);        waitsecs(.5+rand);        flushevents('keydown');    response = 0;        %Audio preceding Visual    if stimOrder(trial,3)== 2        %choose proper stimulus files        if stimOrder(trial,1) == 1            audio = ba_audio;            video = ba_v;        elseif stimOrder(trial,1) == 2            audio = ga_audio;            video = ga_v;        elseif stimOrder(trial,1) == 3            audio = tha_audio;            video = tha_v;        end        delay = stimOrder(trial,2);        numDelay = round(delay/hz); %hz is the framerate        Screen('CopyWindow', cross, win0, fixRect, rectS)%make sure you are aligned with a refresh        Screen('Flip',win0);        waitsecs(.001);        play(audio);%%play(noise);        timeA = toc;        waitsecs(abs(delay)/1000-.0125);%Screen('WaitBlanking',win0,numDelay)%numDelay is # frames to pause        for i = 1:videoFrames            if response == 0                if CharAvail                    RT=toc;                    response = 1;                end            end            Screen('CopyWindow', video(i), win0, stimRect, rectS)            Screen('Flip',win0);            if i == 1                timeV = toc;            end            for j = 1:2                if response == 0                    if CharAvail                        RT=toc;                        response = 1;                    end                end                Screen('CopyWindow', video(i), win0, stimRect, rectS)                Screen('Flip',win0);            end        end        realDelay = (timeA-timeV)*1000;    end        %AV synchronus or video preceding    if stimOrder(trial,3)< 2        clear audioFile        %choose proper stimulus files        if stimOrder(trial,1) == 1            audio = ba_aud;            video = ba_v;        elseif stimOrder(trial,1) == 2            audio = ga_aud;            video = ga_v;        elseif stimOrder(trial,1) == 3            audio = tha_aud;            video = tha_v;        end                %add audio delay        if stimOrder(trial,2) == 0            audioFile = audio;        elseif stimOrder(trial,2) > 0            audioFile = [zeros(1,audioHz*(stimOrder(trial,2)/1000)) audio];        end                audioFile = audioplayer(audioFile,audioHz);                Screen('CopyWindow', cross, win0, fixRect, rectS)        Screen('Flip',win0);        waitsecs(0.0055);        play(audioFile);%%play(noise);        timeA = toc;        Screen('CopyWindow', video(1), win0, stimRect, rectS)        Screen('Flip',win0);        timeV = toc;        for j = 1:2            Screen('CopyWindow', video(1), win0, stimRect, rectS)            Screen('Flip',win0);        end        for i = 2:videoFrames            for j = 1:3                Screen('CopyWindow', video(i), win0, stimRect, rectS)                Screen('Flip',win0);                if response == 0                    if CharAvail                        RT=toc;                        response = 1;                    end                end            end        end        realDelay = (timeA-timeV)*1000;    end        Screen('CopyWindow', cross, win0, fixRect, rectS)    Screen('Flip',win0);        allTrials(trial,5)=timeA;    allTrials(trial,6)=timeV;    allTrials(trial,7)=realDelay;    allTrials(trial,8) = allTrials(trial,7)-allTrials(trial,3);        data.timing(trial,1)=allTrials(trial,5);    data.timing(trial,2)=allTrials(trial,6);    data.timing(trial,3)=allTrials(trial,7);        %present response screen    waitsecs(.25);     Screen('CopyWindow', cross, win0, fixRect, rectS)     Screen('DrawText',win0,'same time = 1           different time = 2',outRect(3)/2-180,outRect(4)/2+50,cWhite0);    Screen('Flip',win0);        %collect response    ans=0;    while ans==0        while CharAvail            key=GetChar;            %key = 'm';            if key=='1'                if response == 0                    RT=toc;                end                allTrials(trial,9)=RT;                ans(trial)=1;                allTrials(trial,12)=ans(trial);                if allTrials(trial,11)==allTrials(trial,12)                    mark(trial)=1;                else                    mark(trial)=0;                end            elseif key=='2'                if response == 0                    RT=toc;                end                allTrials(trial,9)=RT;                ans(trial)=2;                allTrials(trial,12)=ans(trial);                if allTrials(trial,11)==allTrials(trial,12)                    mark(trial)=1;                else                    mark(trial)=0;                end            end        end    end        allTrials(trial,10)=allTrials(trial,9)-min([allTrials(trial,5) allTrials(trial,6)]);        data.responses(trial,2)=ans(trial);    if allTrials(trial,11)==allTrials(trial,12)        mark(trial)=1;    else        mark(trial)=0;    end    allTrials(trial,13)=mark(trial);    data.responses(trial,3)=mark(trial);        data.timing(trial,4)=allTrials(trial,9);    flushevents('keydown');        data.allTrials=allTrials;        save(fname,'data','allTrials');        trial=trial+1;endScreen('FillRect',win0,160, rect0);Screen('DrawText',win0,'saving...',300,rect0(4)/2,0);Screen('Flip',win0);clear SF trim  trial key ans mark corAns rectS ba_audio ba_video ga_audio ga_video tha_video tha_audio bga_audio bga_video bga_aud ga_aud ba_aud tha_aud audioFile audioNoise fixation noise video;save(fname);showCursor;Screen('FillRect',win0,0, rect0);Screen('DrawText',win0,'Thanks for your participation. Press spacebar to exit.',100,rect0(4)/2,255);Screen('Flip',win0);key='';while 1,    key=GetChar;    if findstr(key,' '),        break;    end;endScreen('closeAll');for i = 1:length(offsets)accuracies(i,1) = offsets(i);I = find(allTrials(:,3) == offsets(i));accuracies(i,2) = 1-mean(allTrials(I,13));if accuracies(i,1) == 0    accuracies(i,2) = mean(allTrials(I,13));endendfigure(1);plot(accuracies(:,1), accuracies(:,2))for i = 1:ceil(length(accuracies(:,1))/2)avgAcc(i,1) = accuracies (i,1);avgAcc(i,2) = mean([accuracies(i,2) accuracies(length(accuracies(:,2))-i+1,2)]);end%figure(2);%plot(avgAcc(:,1), avgAcc(:,2))save(fname);graph = 'should peak in the middle'