function children = create_all_children(top_children, best_child, learn_rate, base_NN)
    fprintf("Creating children\n")
    % Create_children(parent, child_count, learn_rate, limits, use_gauss)

    children = [];

    % Create 2 children for top 50 children
    % -> 100 children
    for i = 1:length(top_children)
        new_children = create_children(top_children(i), 2, learn_rate);
        children = [children new_children];
    end

    % All time best child has 5 children
    % child_list_best = create_children(best_child, 5, learn_rate * 0.1);

    % 9 purely random children
    child_list_random = create_children(base_NN, 9, 100, [-1e1, 1e1], false);

    % children = [children child_list_best child_list_random];

    % Add all children together
    % -> 100 + 9 + 1 = 110
    children = [children best_child child_list_random];
    fprintf("Children created\n")
end