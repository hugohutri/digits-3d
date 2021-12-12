function train_model(data, classes, number_to_specialize, figure_queue, save_name)
    %% Class manipulation for specialist learning
    % Manipulate classes so that special number has class 2
    % and rest numbers have class 1.
    new_classes = zeros(size(classes));
    for i = 1:length(classes)
        if (classes(i) == number_to_specialize)
            new_classes(i) = 2;
        else
            new_classes(i) = 1;
        end
    end
    classes = new_classes;

    %% Defining constants
    % Calculate pixel amount based on the data height
    pixel_amount = height(data);
    other_data_size = sum(classes == 1);
    target_data_size = sum(classes == 2);

    % Adjustable constants.
    target_sample_amount = 80; % Train sample amount
    number_of_test = 20; % Test sample amount
    number_of_train = other_data_size + target_sample_amount;
    
    % NN size.
    input_size = pixel_amount;
    hidden_size = 128;
    hidden_layers = 3;
    output_size = 2;
    
    % Learning learn rate
    initial_learn_rate = 0.6;
    learn_rate_modifier = 50;
    learn_rate = initial_learn_rate;
    
    % Error weights
    target_error = 10;
    other_error = 1;
    error_pot = target_sample_amount * target_error + other_data_size * other_error;
    
    % Maximum amount of epochs.
    max_epochs = 300;
    
    % Stop learning, if test success rate drops bellow threshold
    % and epochs are greater than epoch limit.
    test_limit_percentage = 80;
    test_limit_epoch = 170;
    last_x_average = 30;
    
    % Child count parameters.
    child_count = 110;
    num_top_child = child_count;
    
    % New parameters.
    mutation_rate = 6;
    mutation_multpl = 10;

    %% Samples

    train_other_data = data(:, classes == 1);
    train_other_class = ones(other_data_size, 1);

    special_data = data(:,classes == 2);

    %example = reshape(sample_data(:, sample_of_each * 9 -10), [16 16]);
    %imshow(example)



    %% The real training part begings here
    

    % Suffling the data to train and test
    train_special_data_index = randsample(1:target_data_size, target_sample_amount);
    train_special_data = special_data(:, train_special_data_index);
    train_special_class = ones(target_sample_amount, 1) * 2;

    test_special_data_index = setdiff(1:target_data_size, train_special_data_index);
    test_special_data = special_data(:, test_special_data_index);
    test_special_class = ones(number_of_test, 1) * 2;
    
    % Define final training data
    train_data = [train_other_data, train_special_data];
    train_class = [train_other_class; train_special_class];


    base_NN = create_NN(input_size, hidden_size, hidden_layers, output_size);

    % Overall best child ever created
    best_child = NaN;
    best_child_score = number_of_train;
    
    % Overall best child taking into account test data
    best_child = NaN;
    all_time_best_accuracy = 0;

    % List for monitoring performance etc
    best_epoch_accuracies = [];
    best_epoch_test_accuracies = [];
    epoch_durations = [];


    % Initialize data and variables that are needed for the execution.
    train_data_constant = parallel.pool.Constant(train_data);
    train_class_constant = parallel.pool.Constant(train_class);
    test_special_data_constant = parallel.pool.Constant(test_special_data);
    test_special_class_constant = parallel.pool.Constant(test_special_class);
    child_train_scores = zeros(1, child_count);
    child_test_scores = zeros(1, child_count);

    % First epoch child list
    child_list = create_children(base_NN, child_count, learn_rate, [-1e1, 1e1], false);
    for epoch = 1:max_epochs
        % Start timer
        t_start = tic;

        % Evaluate each child
        child_list_constant = parallel.pool.Constant(child_list);
        for n = 1:child_count
            child_train_scores(n) = 0;
            child_test_scores(n) = 0;

            for m = 1:number_of_train

                % result = Evaluate_NN(child, input)
                result = evaluate_NN(child_list_constant.Value(n), ...
                                     train_data_constant.Value(:, m), hidden_layers);

                [~,I] = max(result);

                % If it's not correct
                % Triple minus for wrong target classification.
                if (train_class_constant.Value(m) == 2)
                    child_train_scores(n) = child_train_scores(n) + ((I ~= train_class_constant.Value(m)) * target_error);
                else
                    child_train_scores(n) = child_train_scores(n) + ((I ~= train_class_constant.Value(m)) * other_error);
                end
            end
            
            for m = 1:number_of_test

                % result = Evaluate_NN(child, input)
                result = evaluate_NN(child_list_constant.Value(n), ...
                                     test_special_data_constant.Value(:, m), hidden_layers);

                [~,I] = max(result);

                % If it's not correct
                child_test_scores(n) = child_test_scores(n) + (I ~= test_special_class_constant.Value(m));
            end
        end

        % Rank the children
        [sorted_child, sorted_child_index] = sort(child_train_scores);

        top_children = child_list( sorted_child_index(1:num_top_child) );

        if sorted_child(1) < best_child_score

            best_child_score = sorted_child(1);
            best_child = child_list( sorted_child_index(1) );
        end
        
        % Next epoch child list.
        child_list = create_cross_children(top_children, base_NN, mutation_rate, mutation_multpl);
        
        top_accuracies = (1 - (sorted_child(1:3) ./ error_pot)) * 100;
        top_test_accuracies = (1 - (child_test_scores(sorted_child_index(1:3)) ./ number_of_test)) * 100;
        
        % Check is the best ever child.
        if (top_accuracies(1) > all_time_best_accuracy && top_test_accuracies(1) >= test_limit_percentage)
            fprintf("NEW EINSTAIN DETECTED ON #%d ON EPOCH #%d WITH SCORE: %0.1f%%\n", number_to_specialize, epoch, top_accuracies(1))
            all_time_best_child = best_child;
            all_time_best_accuracy = top_accuracies(1);
            
            % Saving
            save("../../data/model/" + save_name + ".mat", "all_time_best_child");
        end
        
        % Stopping the timer
        t_delta = toc(t_start);
        
        if (length(best_epoch_test_accuracies) > last_x_average)
            test_accurasies_last_x = sum(best_epoch_test_accuracies(end - (last_x_average - 1):end)) / last_x_average;
        end
        
        epoch_durations = [epoch_durations t_delta];

        % PLOTTING

        best_epoch_accuracies = [best_epoch_accuracies, top_accuracies(1)];
        best_epoch_test_accuracies = [best_epoch_test_accuracies, top_test_accuracies(1)];
        
        % Send data for drawing.
        parameters = cell(5, 1, 1);
        parameters{1} = number_to_specialize;
        parameters{2} = epoch;
        parameters{3} = best_epoch_accuracies;
        parameters{4} = best_epoch_test_accuracies;
        parameters{5} = epoch_durations;
        send(figure_queue, parameters);
        
        % If test accuracy is perfect, training can be ended immidiately.
        if (top_accuracies(1) == 100 && top_test_accuracies(1) == 100)
            break
        end
        
        % Prevent over learning by stopping training, if evaluation drops
        % bellow 80% after 50 epochs. 50 epoch limit is introduced, so
        % learning isn't cut too quickly.
        if (epoch > test_limit_epoch && test_accurasies_last_x < test_limit_percentage)
            break;
        end
        
        % Calculate new learning rate.
        learn_rate = initial_learn_rate * (learn_rate_modifier / top_accuracies(1));
    end
end
