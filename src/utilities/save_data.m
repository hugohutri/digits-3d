function save_data(data_to_be_saved, classes, path, filename)
    % Save data from preprosessing
    % 
    % USAGE:
    %   save_data(data_to_be_saved, classes, path, filename);

    full_file_name = path + "/" + filename; 

    % Create a matrix where 
    % height = amount of pixels, and 
    % width = amount of data samples 
    data = zeros(numel(data_to_be_saved{1}), length(data_to_be_saved));
    for i = 1:length(data_to_be_saved)
        image_data = data_to_be_saved{i};

        % Transform the image matrix into a vector
        data(:,i) = image_data(:);
    end

    size_of_saved_file = size(data)
    save(full_file_name, 'data', "classes")       
end