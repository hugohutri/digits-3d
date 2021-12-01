function children = create_children(parent, child_count, learn_rate, limits, use_gauss)



    % TODO:
    % - use_gauss before limits

    arguments
       % parent that is used as the base for the children
       parent Child = NaN
       % amount of children to be generated
       child_count uint16 = 100
       % learn rate aka variance to parent's values
       learn_rate double = 0.01
       % weights min, max & bias min, max
       limits (1,2) double = [-1e1, 1e1]
       % if false, generate children with uniform random. If true, the
       % parent is used as mean for gaussian random.
       use_gauss logical = true
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
    
    
    
    % children = list of all the new generation children to be returned Nx1
    children = Child.empty(child_count, 0);
    for n = 1:child_count
        % Initializing Child class instance
        child = Child;
        
        % INPUT
        child.weights_in = apply_rand(parent.weights_in);
        child.bias_in = apply_rand(parent.bias_in);
        
        
        % HIDDEN
        child.weights_hidden = apply_rand(parent.weights_hidden);
        child.bias_hidden = apply_rand(parent.bias_hidden);        
        
        
        % OUTPUT
        child.weights_out = apply_rand(parent.weights_out);
        child.bias_out = apply_rand(parent.bias_out);
        
        % Add the child to the list of children
        children(n) = child;        
    end
    
    
    function C = apply_rand(parent_mat)
        
        % Parent size
        p_size = size(parent_mat);
        
        % Values from the parent with each value summed by
        % normally random matrix of "learn_rate" variance
        % aka gaussian noise is added to each node
        if use_gauss
            % Each parent node is multiplied by gaussianly random node
            C = parent_mat + (randn(p_size) * learn_rate);
        else
            % Uniform distribution ]min, max[
            C = ones(p_size) .* ...
            (rand(p_size) * (limits(2) - limits(1)) + limits(1));
        end

        
        % TODO: Clamping is really only needed for when gaussian is used
        % aka when inheriting values from parent. But it looks better if
        % it's not stuffed inside the if-clause :)
        
        % clamp the min values to min
        h = C < limits(1);
        C(h == 1) = limits(1);

        % clamp the max values to max
        h = C > limits(2);
        C(h == 1) = limits(2);

    end

end