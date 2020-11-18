function [layer,quality] = propagate_layer(layer,quality,geoinfo,window,x_in,y_in,leftright)
%propagate_layer automatically propagates a radar layer
%   Detailed explanation goes here
    lmid = round(window/2);

    x_trace = x_in;
    
    [~, nx]=size(geoinfo.echogram);
    while ismember(x_trace, 1:nx)

        if x_trace == x_in
            disp('Pick.')
            y_trace = y_in;
            quality(x_trace) = 1;
        elseif any(geoinfo.seeds(current_window,x_trace)) % Check if any seed is in window.
            [lind, ~, value] = find(geoinfo.peakim(current_window,x_trace)); % Q: Does value refer to the strongest seed?
            if length(lind)==1
                disp('One seed - yay')
                y_trace = current_window(lind);
                quality(x_trace)=2;
            else
                disp('###closest seed')
                wdist = abs(lind - lmid);
                lind = lind(value == max(value(wdist == min(wdist)))); % Find closest seed with biggest value. Q: Is biggest the best?
                y_trace = current_window(lind);
                quality(x_trace)=3;
            end
        else
            [~,lind,~,p] = findpeaks(mag2db(geoinfo.echogram(current_window,x_trace))); %need to do this on the bare data.
            if length(lind)==1
                disp('One peak')
                y_trace = current_window(lind);
                quality(x_trace)=4;
            elseif length(lind)>1
                disp('***largest & closest peak.')     
                wdist = 1-abs(2*(lind - lmid)/(window-1));%zwischen 0 und 1, with 1 being closer, so it will have more weight in next step
                lprobability = wdist+p/mean(p); %not perfect, but gives a tool to weigh proximity relativ to brightness 
                [~, indprob] = max(lprobability);
                y_trace = current_window(lind(indprob));
                quality(x_trace)=5;
            else
                disp('No peak. Use previous index for now.')
                % y_trace does not change
                quality(x_trace)=6;
            end  
        end
        layer(x_trace) = y_trace;

        current_window=ceil(y_trace-window/2):floor(y_trace+window/2);

        x_trace = x_trace + leftright; %moves along the traces progressively, according to selected direction
    end
end

