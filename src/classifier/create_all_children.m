function children = create_all_children(top_children, best_child, learn_rate, base_NN)
    % fprintf("Creating children\n")
    % Create_children(parent, child_count, learn_rate, limits, use_gauss)

    children = [];

    % % Create 2 children for top 50 children
    % % -> 100 children
    % for i = 1:length(top_children)
    %     new_children = create_children(top_children(i), 2, learn_rate);
    %     children = [children new_children];
    % end

    % Create 2 children for top 1-20 children
    % -> 40
    for i = 1:20
        new_children = create_children(top_children(i), 2, learn_rate);
        children = [children new_children];
    end

    % Create 1 children for top 21-50 children
    % -> 30
    for i = 21:50
        new_children = create_children(top_children(i), 1, learn_rate);
        children = [children new_children];
    end

    % Select 30 children from top 51-110 and create 1 children for each of them
    % -> 30
    for i = randperm(60,30)+50 %51:110
        new_children = create_children(top_children(i), 1, learn_rate);
        children = [children new_children];
    end

    % All time best child has 5 children
    % child_list_best = create_children(best_child, 5, learn_rate * 0.1);

    % 10 purely random children
    child_list_random = create_children(base_NN, 9, 100, [-1e1, 1e1], false);

    % children = [children child_list_best child_list_random];

    % Add all children together
    % -> 100 + 10 = 110
    children = [children child_list_random best_child];
    % fprintf("Children created\n")
end