function children = create_cross_children(top_children, base_NN, mutation_rate, mutation_multpl)
    % fprintf("Creating children\n")
    % Create_children(parent, child_count, learn_rate, limits, use_gauss)

    children = [];
    
    % The smaller the number the more likely the top ones are to be bred
    % exclusively. On contrary the bigger the number the more it allows the
    % outliers to have a chance of breeding
    %
    % Another way of seeing this is: the smaller this number, the less
    % there will be difference between the average accuracy and top
    % accuracy
    n = 20;
    
    
    pair_count = 33;
    
    r1 = ceil( abs(randn(1, pair_count)) * n );
    r2 = ceil( abs(randn(1, pair_count)) * n );
    
    % Clamp max values to 110 (110 is the max amount of children)
    r1(r1 > 110) = 110;
    r2(r2 > 110) = 110;
    
    
    s1 = r1(1:pair_count);
    s2 = r2(1:pair_count);
    
    
    same = s1 == s2;

    s2(same == 1) = s2(same == 1) + 1;
    
    s2(s2 > 110) = 110;
    
    
    for p = 1:pair_count
        
        % children = create_cross(parent_1, parent_2, mutation_rate, mutation_multpl)
        child_list = create_cross(top_children( s1(p) ), top_children( s2(p) )...
            , mutation_rate, mutation_multpl);
        children = [children child_list];
    end
    

    % 11 purely random children
    child_list_random = create_children(base_NN, 10, 100, [-1e1, 1e1], false);
    %

    % children = [children child_list_best child_list_random];

    % Add all children together
    % -> 100 + 10 = 110
    children = [children child_list_random top_children(1)];
    % fprintf("Children created\n")
end