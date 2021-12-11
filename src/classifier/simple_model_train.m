function top_children = simple_model_train(base_NN, train_data, train_class, epoch_count, target_accuracy, verbal)



    arguments
        % parent that is used as the base for the children
        base_NN Child = NaN
        % data to train the model
        train_data (:,:) double = NaN
        % classes to train the model
        train_class (:,:) double = NaN
        % max epoch count
        epoch_count uint16 = 600;
        % accuracy at which stop the training (in percents)
        target_accuracy double = 90;
        % Printing and plotting
        verbal logical = 0
    end

    
    number_of_train = length(train_class);
    
    child_count = 110;
    num_top_child = child_count; % 50; %3;
    top_children = Child.empty(num_top_child, 0);

    % Overall best child ever created
    best_child = NaN;
    best_child_error = epoch_count;

    % List for monitoring performance etc
    average_accuracies = [];
    average_top10_accuracies = [];
    best_epoch_accuracies = [];
    epoch_durations = [];

    % Number of hidden layers
    % is the third dimension of hidden weights layer
    hidden_layers = size(base_NN.weights_hidden);
    hidden_layers = hidden_layers(3);

    % Initialize data and variables that are needed for the execution.
    train_data_constant = parallel.pool.Constant(train_data);
    train_class_constant = parallel.pool.Constant(train_class);
    child_errors = zeros(1, child_count);

    % First epoch child list
    child_list = create_children(base_NN, child_count, 0, [-1e1, 1e1], false);
    for epoch = 1:epoch_count
        if (verbal)
            fprintf("Starting epoch\n")
        end

        % Start timer
        t_start = tic;

        % Evaluate each child
        % fprintf("Evaluating each children\n")
        child_list_constant = parallel.pool.Constant(child_list);
        parfor n = 1:child_count
            child_errors(n) = 0;

            for m = 1:number_of_train

                % result = Evaluate_NN(child, input)
                result = evaluate_NN(child_list(n), train_data_constant.Value(:, m), ...
                                    hidden_layers);

                [~,I] = max(result);

                % If it's not correct
                child_errors(n) = child_errors(n) + (I ~= train_class_constant.Value(m));
            end
        end
        % fprintf("Children evaluated\n")




        % Rank the children
        [B,I] = sort(child_errors);

        top_children = child_list( I(1:num_top_child) );

        if B(1) < best_child_error

            best_child_error = B(1);
            best_child = child_list( I(1) );
        end
        
        % Next epoch child list.
        % create_cross_children(top_children, base_NN, mutation_rate, mutation_multpl)
        % TODO: mutation_rate and mutation_multiplier can be attached to variables
        child_list = create_cross_children(top_children, base_NN, 6, 10);
        


        % Stopping the timer
        t_delta = toc(t_start);

        if (epoch == 1 && verbal)

            full_duration = seconds(t_delta * epoch_count);
            full_duration.Format = 'hh:mm';

            fprintf("Training has been started with %d iterations\n", epoch_count);
            fprintf("Estimated complete duration %s hh:mm\n\n", full_duration);
        end
        
        accuracies = (1 - (B ./ number_of_train)) * 100;
        average_accuracy = mean(accuracies);
        
        epoch_durations = [epoch_durations t_delta];
        average_epoch_duration = mean(epoch_durations);
        
        if (verbal)
            fprintf('[%s]\n', datestr(now,'hh:MM:ss'))
            fprintf("Epoch: %d/%d, with learn rate: %0.3f\n", epoch, epoch_count, learn_rate)
            
            fprintf("Top accuracies: %0.1f%%, %0.1f%%, %0.1f%%\n",accuracies(1:3))
            fprintf("Average accuracy: %0.1f%% \n",average_accuracy)
            fprintf("Time taken: %0.3fs\n", t_delta)
            
            fprintf("Average epoch duration: %0.3fs\n", average_epoch_duration)

            fprintf("\n")
        end

        
        save("best_child.mat", "best_child")
        % PLOTTING

        best_epoch_accuracies = [best_epoch_accuracies, accuracies(1)];
        average_accuracies = [average_accuracies average_accuracy];
        average_top10_accuracies = [average_top10_accuracies mean(accuracies(1:10))];
        hold on;
        
        % Plot accuracy
        subplot(2,1,1);
        plot(1:epoch, best_epoch_accuracies, "b"); hold on;
        plot(1:epoch, average_top10_accuracies, "m"); hold on;
        plot(1:epoch, average_accuracies, "r"); hold on;
        legend("Best accuracy", "Average top 10 accuracy", "Average accuracy", "Location", "southeast")
        title("Accuracy");
        ylabel("%");
        
        % Plot time taken per epoch
        subplot(2,1,2);
        plot(1:epoch, epoch_durations, "b");
        title("Epoch duration");
        ylabel("seconds");

        drawnow;


        if (accuracies(1) >= target_accuracy)
            fprintf("Target accuracy of %0.2f reached\n", target_accuracy)
            return
        end
    end
end