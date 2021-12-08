function children = create_all_children(top_children, learn_rate, base_NN)
    % Create_children(parent, child_count, learn_rate, limits, use_gauss)

    children_amount = length(top_children);

    % The best child from previous generation will always survice
    children = [top_children(1)];

    % Top 20% will get 2 children
    % -> 40% of the next generation
    for i = 1 : floor(0.20 * children_amount)
        new_children = create_children(top_children(i), 2, learn_rate);
        children = [children new_children];
    end

    % From top 20% to top 40% will get 1 child
    % -> 20% of the next generation
    for i = ceil(0.2*children_amount) : floor(0.4*children_amount)
        new_children = create_children(top_children(i), 1, learn_rate);
        children = [children new_children];
    end

    % Select randomly from remaining 50%
    % -> 30% of next generation
    randomly_selected_amount = 0.3 * children_amount;
    for i = randperm(floor(0.5 * children_amount),randomly_selected_amount) + floor(0.5*children_amount) %51:110
        new_children = create_children(top_children(i), 1, learn_rate);
        children = [children new_children];
    end

    % Rest of the children are purely random ~10 %
    randomly_generated_amount = children_amount - length(children);
    child_list_random = create_children(base_NN, randomly_generated_amount, 100, [-1e1, 1e1], false);


    children = [children child_list_random];
end