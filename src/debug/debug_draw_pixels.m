function debug_draw_pixels(data, classes)
    global DEBUG;
    global DEBUG_DRAW_EVERY;
    global DEBUG_DRAW_CLASSES;

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
    
    previous_class = NaN;
     % Go through all the data points.
    for data_index = 1:length(subset_data)
        current_class = subset_classes(data_index);

        % Draw only specific classes
        if (~ismember(current_class, DEBUG_DRAW_CLASSES))
            continue
        end

        % Change plot
        if (previous_class ~= current_class)
            % Set new class as previous class.
            previous_class = current_class;
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
        colormap(gray);

        axis tight
        axis off
        % Update sub plot index.
        subplot_index = subplot_index + 1;
    end
end