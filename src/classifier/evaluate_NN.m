
function result = evaluate_NN(child, input, layer_N)       
    activ_fun = @(X) max(zeros(size(X)), X);

    % INPUT
    current = input' * child.weights_in;
    current = current + child.bias_in;
    current = activ_fun(current);
    
    % HIDDEN LAYERS
    for layer = 1:layer_N
        
        current = current * child.weights_hidden(:, :, layer);
        current = current + child.bias_hidden(:, :, layer);
        current = activ_fun(current);
    end
    
    % OUTPUT
    current = current * child.weights_out;
    current = current + child.bias_out;
    current = activ_fun(current);
    
    result = current;
end