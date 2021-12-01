function debug_draw_pixels(data, classes)
    global DEBUG;
    global DEBUG_DRAW_EVERY;
    
    if (DEBUG ~= 1)
        return;
    end
    
    % Draw based on the draw every amount.
    subset_data = cell(ceil(length(data) / DEBUG_DRAW_EVERY), 1, 1);
    subset_index = 1;
    for data_index = 1:DEBUG_DRAW_EVERY:length(data)
        subset_data{subset_index} = data{data_index};
        subset_index = subset_index + 1;
    end
    subset_classes = classes(1:DEBUG_DRAW_EVERY:end);
    
    % Set to some fake class that is not realistic.
    previous_class = -1000;
     % Go through all the data points.
    for data_index = 1:length(subset_data)
        % Change plot
        if (previous_class ~= subset_classes(data_index))
            % Set new class as previous class.
            previous_class = subset_classes(data_index);
            % Calculate new sample amount.
            sample_amount = sum(subset_classes(:) == previous_class);
            % Create new figure.
            figure
            % Reset subplot index.
            subplot_index = 1;
            % Calculate new subplot dimensions.
            subplot_dimension = ceil(sqrt(sample_amount));
        end
        
        % Get one sample from data using index.
        entry = subset_data{data_index};
        % Move to next subplot.
        subaxis(subplot_dimension, subplot_dimension, subplot_index, 'Spacing', 0.01, 'Padding', 0, 'Margin', 0.02);

        % Plot new image to sub plot.
        image(rot90(entry * 255))

        axis tight
        axis off
        % Update sub plot index.
        subplot_index = subplot_index + 1;
    end
end