function plot_riq(file)
    results=readmatrix(file);

    metric_vals = unique( results(:,5));
    prefs1=zeros( [size(metric_vals,1),1]);

    trial_first_left = (results(:,3)<results(:,4)); % 1 if first trial was "left" one
    resp_left = ( results(:,6) == (trial_first_left+1) );

    idx1=1;
    for nmetric=1:size(metric_vals,1)
        idxs=results( results(:,5)==metric_vals(nmetric) );
        %sides= (results(idxs,6)-1.5 ) *2; % Turn 1,2 into -1,+1
        sides = resp_left(nmetric);
        sides = (sides - 0.5) * 2;

        sides = sides .* (1+results(idxs,7)); % Turn 0,1 into 1,2 (double side)

        prefs1(idx1) = mean(sides);
        idx1 = idx1 + 1;

        plot( repmat(metric_vals(nmetric),[2,1] ), sides, 'o' )
        hold on;
    end

    plot(metric_vals, prefs1);
    ylabel("<- resp 'left' | resp 'right' ->")
    xlabel("metric value");
end

