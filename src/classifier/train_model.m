function train_model(data, classes, number_to_specialize)
    %% Defining constants
    % Calculate pixel amount based on the data height
    pixel_amount = height(data);

    % Adjustable constants.
    target_sample_amount = 80; % Train sample amount
    number_of_test = 20; % Test sample amount
    number_of_train = target_sample_amount * 2;
    
    % NN size.
    input_size = pixel_amount;
    hidden_size = 128;
    hidden_layers = 3;
    output_size = 2;
    
    % Maximum amount of epochs.
    max_epochs = 250;
    
    % Learning learn rate
    initial_learn_rate = 0.4;
    learn_rate = initial_learn_rate;
    
    % Stop learning, if test success rate drops bellow 80 %
    % and epochs are greater than epoch limit.
    test_limit_percentage = 80;
    test_limit_epoch = 100;
    
    % Child count parameters.
    child_count = 110;
    num_top_child = child_count;
    
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

    % Samples
    all_data_size = sum(classes == 1);
    target_data_size = sum(classes == 2);

    train_other_class = ones(target_sample_amount, 1);

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


    base_NN = create_NN(input_size, hidden_size, hidden_layers, output_size);

    % Overall best child ever created
    best_child = NaN;
    best_child_score = number_of_train;

    % List for monitoring performance etc
    best_epoch_accuracies = [];
    best_epoch_test_accuracies = [];
    epoch_durations = [];


    % Initialize data and variables that are needed for the execution.
    train_special_data_constant = parallel.pool.Constant(train_special_data);
    train_special_class_constant = parallel.pool.Constant(train_special_class);
    test_special_data_constant = parallel.pool.Constant(test_special_data);
    test_special_class_constant = parallel.pool.Constant(test_special_class);
    other_data_constant = parallel.pool.Constant(data(:, classes == 1));
    other_class_constant = parallel.pool.Constant(train_other_class);
    child_train_scores = zeros(1, child_count);
    child_test_scores = zeros(1, child_count);

    % First epoch child list
    child_list = create_children(base_NN, child_count, learn_rate, [-1e1, 1e1], false);
    for epoch = 1:max_epochs
        fprintf("Starting epoch\n")

        % Start timer
        t_start = tic;
        
        % Input new random data into learning algorithm.
        train_other_data_index = randsample(1:all_data_size, target_sample_amount);
        train_other_data = other_data_constant.Value(:, train_other_data_index);
        
        % Combine new train data.
        train_data = [train_other_data, train_special_data_constant.Value];
        train_class = [other_class_constant.Value; train_special_class_constant.Value];

        % Evaluate each child
        child_list_constant = parallel.pool.Constant(child_list);
        train_data_constant = parallel.pool.Constant(train_data);
        train_class_constant = parallel.pool.Constant(train_class);
        parfor n = 1:child_count
            child_train_scores(n) = 0;
            child_test_scores(n) = 0;

            for m = 1:number_of_train

                % result = Evaluate_NN(child, input)
                result = evaluate_NN(child_list_constant.Value(n), ...
                                     train_data_constant.Value(:, m), hidden_layers);

                [~,I] = max(result);

                % If it's not correct
                child_train_scores(n) = child_train_scores(n) + (I ~= train_class_constant.Value(m));
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
        % fprintf("Children evaluated\n")

        
        % Saving
        save("../../data/model/NN_" + number_to_specialize + ".mat", "best_child");


        % Rank the children
        [sorted_child, sorted_child_index] = sort(child_train_scores);

        top_children = child_list( sorted_child_index(1:num_top_child) );

        if sorted_child(1) < best_child_score

            best_child_score = sorted_child(1);
            best_child = child_list( sorted_child_index(1) );
        end
        
        % Next epoch child list.
        child_list = create_all_children(top_children, best_child, learn_rate, base_NN);

        % Stopping the timer
        t_delta = toc(t_start);

        if epoch == 1

            full_duration = seconds(t_delta * max_epochs);
            full_duration.Format = 'hh:mm';

            fprintf("Training has been started with %d iterations\n", max_epochs);
            fprintf("Estimated complete duration %s hh:mm\n\n", full_duration);
        end

        fprintf('[%s]\n', datestr(now,'hh:MM:ss'))
        fprintf("Epoch: %d/%d, with learn rate: %0.3f\n", epoch, max_epochs, learn_rate)
        
        top_accuracies = (1 - (sorted_child(1:3) ./ number_of_train)) * 100;
        fprintf("Top accuracies: %0.1f%%, %0.1f%%, %0.1f%%\n",top_accuracies)
        
        top_test_accuracies = (1 - (child_test_scores(sorted_child_index(1:3)) ./ number_of_test)) * 100;
        fprintf("Top test accuracies: %0.1f%%, %0.1f%%, %0.1f%%\n",top_test_accuracies)
        
        if (length(best_epoch_test_accuracies) > 10)
            test_accurasies_last_10_average = sum(best_epoch_test_accuracies(end - 9:end)) / 10;
            fprintf("Test accuracy last 10: %0.1f%%\n", test_accurasies_last_10_average)
        end
        
        fprintf("Epoch duration: %0.3fs\n", t_delta)
        
        epoch_durations = [epoch_durations t_delta];

        fprintf("\n")

        % PLOTTING

        best_epoch_accuracies = [best_epoch_accuracies, top_accuracies(1)];
        best_epoch_test_accuracies = [best_epoch_test_accuracies, top_test_accuracies(1)];
        hold on;
       

        % Plot accuracy
        subplot(3,1,1);
        plot(1:epoch, best_epoch_accuracies, "b");
        title("Accuracy");
        ylabel("%");
        
        % Plot test
        subplot(3,1,2);
        plot(1:epoch, best_epoch_test_accuracies, "b");
        title("Test accuracy");
        ylabel("%");

        % Plot time taken per epoch
        subplot(3,1,3);
        plot(1:epoch, epoch_durations, "b");
        title("Epoch duration");
        ylabel("seconds");
        
        % Setting title for whole figure.
        sgtitle("Training #" + number_to_specialize);

        drawnow;
        
        % If test accuracy is perfect, training can be ended immidiately.
        if (top_accuracies(1) == 100 && top_test_accuracies(1) == 100)
            break
        end
        
        % Prevent over learning by stopping training, if evaluation drops
        % bellow 80% after 50 epochs. 50 epoch limit is introduced, so
        % learning isn't cut too quickly.
        if (epoch > test_limit_epoch && test_accurasies_last_10_average < test_limit_percentage)
            break;
        end
        
        % Calculate new learning rate.
        learn_rate = initial_learn_rate * (50 / top_accuracies(1));
    end
end
