function debug_draw_vectors(data)
    global DEBUG;
    global DEBUG_DRAW_EVERY;
    
    if (DEBUG ~= 1)
        return;
    end
    
     % Go through all the data points.
    for data_index = 1:length(data)
        % Get one sample from data using index.
        entry = data{data_index};
        if (mod(data_index, DEBUG_DRAW_EVERY) == 0)
            figure
            plot(entry(:, 1), entry(:, 2));
        end
    end
end