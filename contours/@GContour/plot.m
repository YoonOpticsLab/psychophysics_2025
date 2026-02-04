function plot(obj)
    
    obj = validate(obj);

    figure; hold on;
    
    for i = 1:length(obj(:))
        plot(obj(i).x,obj(i).y,'k.');
    end
    
    axis equal;
    hold off;
    
end