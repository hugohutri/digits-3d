function debug_draw(data)
    dimension = floor(sqrt(length(data)));

    pixel_matrix = reshape(data,dimension,dimension);
    % Plot new image to sub plot.
    image(rot90(pixel_matrix * 255))
    colormap(gray);
end