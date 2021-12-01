function [filtered_data, filtered_classes] = debug_filter_data(data, classes, number)
    filtered_data_length = sum(classes == number);
    filtered_data = cell(filtered_data_length, 1, 1);
    subset_index = 1;
    for data_index = 1:length(data)
        if (classes(data_index) == number)
            filtered_data{subset_index} = data{data_index};
            subset_index = subset_index + 1; 
        end
    end
    filtered_classes = ones(filtered_data_length, 1) * number;
end















