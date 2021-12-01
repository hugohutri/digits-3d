function save_data(data_to_be_saved, path, filename)
    full_file_name = string(path + "/" + filename); 

    
    data = [];
    for image_data = data_to_be_saved
        data = [data image_data(:)];
    end

    size(data);
    save(full_file_name, 'data')       
end