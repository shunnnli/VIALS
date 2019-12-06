function [aligned,freq_mat,total_trial] = align(seq, iti, bin_size,instanFreq)

    aligned = [];
    lick_id = 0;
    last_reward = 0;
    last_rid = 0;
    reward_id = 1;
    lick_start = 0;
    lick_end = 0;
    lick_interval = 0;
    total_trial = 0;
    
    freq_mat = [];
    winlick = 0;
    winabove = 0;
    winsize = instanFreq(1,1);
    freq_cutoff = instanFreq(1,2);
    
    for cur_row = 1:size(seq, 1)
        if cur_row == 1
            start_time = seq(cur_row,2);
            winopen = start_time;
            winclose = winopen + winsize;
        end
        
        if seq(cur_row,2) > winclose
            winfreq = winlick / (winsize/1000);
            if winfreq >= freq_cutoff
                winabove = winabove + 1;
            end
            winopen_corrected = winopen - start_time;
            new_row = [winopen_corrected winlick winfreq];
            freq_mat = [freq_mat; new_row];

            diff = seq(cur_row,2) - winclose;
            add = ceil(diff/winsize);
            winopen = winopen + add*winsize;
            winclose = winclose + add*winsize;
            winlick = 0;
        end
        
        if seq(cur_row,1) == 0 || seq(cur_row,1) == 1
            continue

        elseif seq(cur_row,1) == 5000
            reward_id = reward_id + 1;
            last_reward = seq(cur_row,2);
            total_trial = total_trial + 1;

        elseif seq(cur_row,1) == 2000	
            lick_start = seq(cur_row,2);
            lick_interval = lick_start - lick_end;

        elseif seq(cur_row,1) == 2001	
            lick_end = seq(cur_row,2);
            lick_duration = lick_end - lick_start;
            
            if lick_duration > 1000
                continue
            end
            
            if lick_start - last_reward < iti/2
                start_aligned = lick_start - last_reward;
            else	
                start_aligned = lick_start - (last_reward + iti);
            end
           
            start_binned = round(start_aligned / bin_size) * bin_size;
            if abs(start_aligned) < iti/2
                if start_aligned > 0
                    if last_rid < reward_id
                        last_rid = reward_id;
                    end
                    lick_id = lick_id + 1;
                    output_aligned = [lick_id start_aligned start_binned ...
                        reward_id lick_duration lick_interval last_reward lick_start];
                else
                    if last_rid < reward_id + 1
                        last_rid = reward_id + 1;
                    end
                    lick_id = lick_id + 1;
                    output_aligned = [lick_id start_aligned start_binned ...
                        reward_id+1 lick_duration lick_interval last_reward lick_start];
                end
                aligned = [aligned; output_aligned];
            end
            
            if seq(cur_row,2) <= winclose && seq(cur_row,2) > winopen
                winlick = winlick + 1;
            elseif seq(cur_row,2) > winclose
                disp('Window close error!');
                disp(cur_row);
            end

        elseif seq(cur_row,1) == 8000
            continue
        end
    end
end