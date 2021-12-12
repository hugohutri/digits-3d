clc; clearvars; close all;

% Load preprocessed test data.
load("../../data/preprocessed/preprocessed_training_data.mat")

% Train 3 times for super model forest.
for round = 1:3
    figure_axes = cell(10, 1, 1);

    % Open 10 figures.
    for index = 1:10
        subplot_axes = cell(4, 1, 1);
        subplot_axes{1} = figure;
        sgtitle("Training #" + index);
        subplot_axes{2} = subplot(3,1,1);
        title("Accuracy");
        ylabel("%");
        subplot_axes{3} = subplot(3,1,2);
        title("Test accuracy");
        ylabel("%");
        subplot_axes{4} = subplot(3,1,3);
        title("Epoch duration");
        ylabel("seconds");
        figure_axes{index} = subplot_axes;
        drawnow
    end
    
    % Train all specialist models.
    % Note 0 is 10 in classes.
    figure_queue = parallel.pool.DataQueue;
    figure_queue.afterEach(@(parameters) update_figures(figure_axes, parameters));
    parfor index = 1:10
        % Generate model save name.
        save_name = "NN_" + index + "_" + round;
        
        % Start training.
        train_model(data, classes, index, figure_queue, save_name);
    end
    
    % Save all figures.
    for index = 1:10
        save_name = "NN_" + index + "_" + round;
        
        saveas(figure_axes{index}{1}, "../../data/figures/" + save_name + ".svg")
    end
    
    % Close all figures.
    close all;
end

function update_figures(figure_axes, parameters)
    % USAGE:
    %   update_figures(figure_axes, parameters);

    number_to_specialize = parameters{1};
    epoch = parameters{2};
    best_epoch_accuracies = parameters{3};
    best_epoch_test_accuracies = parameters{4};
    epoch_durations = parameters{5};
    
    specific_figure_axes = figure_axes{number_to_specialize};
    
    % Plot title
    sgtitle(specific_figure_axes{1}, "Training #" + number_to_specialize);
    
    % Plot accuracy
    plot(specific_figure_axes{2}, 1:epoch, best_epoch_accuracies, "b");
    title(specific_figure_axes{2}, "Accuracy");
    ylabel(specific_figure_axes{2}, "%");

    % Plot test
    plot(specific_figure_axes{3}, 1:epoch, best_epoch_test_accuracies, "b");
    title(specific_figure_axes{3}, "Test accuracy");
    ylabel(specific_figure_axes{3}, "%");

    % Plot time taken per epoch
    plot(specific_figure_axes{4}, 1:epoch, epoch_durations, "b");
    title(specific_figure_axes{4}, "Epoch duration");
    ylabel(specific_figure_axes{4}, "seconds");
    
    drawnow('limitrate');
end