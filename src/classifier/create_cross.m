function children = create_cross(parent_1, parent_2, mutation_rate, mutation_multpl)
    % Linear crossover to create 3 new children for 2 parents
    % Returns always 3 children, all of which should be utilized

    children = Child.empty(3, 0);
    
    % First child has 50% genes of both parents
    children(1) = multiply_with(parent_1, parent_2, 0.5, 0.5);
    
    % Second child prioritizes the parent 1
    children(2) = multiply_with(parent_1, parent_2, 3/2, -0.5);
    
    % Thirt child prioritizes the parent 2
    children(3) = multiply_with(parent_1, parent_2, -0.5, 3/2);
    
    
    function child = multiply_with(parent_1, parent_2, mult_1, mult_2)
        % Create the new child based on parents and the multipliers

        child = Child;
        
        child.weights_in = apply_random( (mult_1 .* parent_1.weights_in) + (mult_2 .* parent_2.weights_in));
        child.bias_in    = apply_random( (mult_1 .* parent_1.bias_in)    + (mult_2 .* parent_2.bias_in));
        
        child.weights_hidden = apply_random( (mult_1 .* parent_1.weights_hidden) + (mult_2 .* parent_2.weights_hidden));
        child.bias_hidden    = apply_random( (mult_1 .* parent_1.bias_hidden)    + (mult_2 .* parent_2.bias_hidden));
        
        child.weights_out = apply_random( (mult_1 .* parent_1.weights_out) + (mult_2 .* parent_2.weights_out));
        child.bias_out    = apply_random( (mult_1 .* parent_1.bias_out)    + (mult_2 .* parent_2.bias_out));
    end

    % Apply random variation to the child based on the parent
    function mat = apply_random(parent_mat)
        
        p_size = size(parent_mat);
        dims = length(p_size);
        
        
        num_of_muts = round(abs(randn()) * mutation_rate) * dims;
        
        rnd_x = randi([1, p_size(1)], 1, num_of_muts);
        rnd_y = randi([1, p_size(2)], 1, num_of_muts);
        if (dims > 2)
            rnd_z = randi([1, p_size(3)], 1, num_of_muts);
        end
        
        % Mutation matrix
        mat = zeros(p_size);
        for p = 1:num_of_muts
            
            x = rnd_x(p);
            y = rnd_y(p);
            if (dims > 2)
                z = rnd_z(p);
                mat(x, y, z) = randn() * mutation_multpl;
            else
                mat(x, y) = randn() * mutation_multpl;
            end
        end
        
        % Add the parent_mat values to matrix of mutations
        mat = mat + parent_mat;
    end
end

% CHILD -class
%
% weights_in (:,:) double
% bias_in (:,:) double
%
% weights_hidden (:,:) double
% bias_hidden (:,:) double
%
% weights_out (:,:) double
% bias_out (:,:) double