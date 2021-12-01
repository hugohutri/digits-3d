function [data, classes, max_length] = load_data()
    global TRAIN_DATA_DIRECTORY;
    global TRAIN_DATA_SIZE;
    global TRAIN_DATA_CLASS_INDEX;

    files = dir(TRAIN_DATA_DIRECTORY);
    
    data = cell(TRAIN_DATA_SIZE, 1, 1);
    classes = zeros(TRAIN_DATA_SIZE, 1);
    max_length = 0;
    
    data_index = 1;
    for file_index = 1:length(files)
        % Get filename.
        file = files(file_index).name;
        
        % Skip CSV files and meta folders.
        if (endsWith(file, ".csv") || file == "." || file == "..")
            continue
        end
        
        % Extract class from filename.
        class = str2double(file(TRAIN_DATA_CLASS_INDEX));
        classes(data_index) = class;
        
        % Load file
        full_file_name = TRAIN_DATA_DIRECTORY + "/" + file;
        load(full_file_name, "pos");
        data{data_index} = pos;
        
        % Update max_length if necessary.
        if max_length < length(pos)
            max_length = length(pos);
        end
        
        data_index = data_index + 1;
    end
end