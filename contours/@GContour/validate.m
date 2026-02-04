function obj = validate(obj)

    fnc_name = 'GContour.validate';

    if length(obj.x) ~= length(obj.y)
        msg = 'Vectors must be of equal length';
        GERT_ShowError(fnc_name,msg,3);
    end

    if ~obj.validated && obj.n

        obj.validated = true;

        cdx = obj.x; cdy = obj.y;

        % Is the contour really closed?
        xshp = circshift(cdx,[0 1]);
        yshp = circshift(cdy,[0 1]);

        dp = sqrt(((cdx-xshp).^2) + ((cdy-yshp).^2));

        if obj.closed && dp(1) > max(dp(2:end))*1.5
            msg = 'Large distance between endpoints. Is the contour really closed?';
            GERT_ShowError(fnc_name,msg,1);
            obj.validated = false;
        end

        % Are there any overlapping points?
        [cdx idx] = sort(cdx); 
        cdy = cdy(idx);
        dx = cdx-circshift(cdx,[0 1]); dy = cdy-circshift(cdy,[0 1]);
        d = (dx==0 & dy==0);

        if any(d)
            msg = 'Identical points found in contour description. Try to execute the ''rmid'' method on the GContour object.';
            GERT_ShowError(fnc_name,msg,3);
            obj.validated = false;
        end

        % Is the contour continuous?
%         dd = d-repmat(dp, [length(d) 1]);
%         
%         if ~obj.closed
%             dd = dd(:,2:end);
%         end
%         
%         thrsh = round(length(d)/10);
%         if any(dd(thrsh,:)<0)
%             msg = 'Some elements do not have their neighbours among the 10% closest points. Is the contour continuous?';
%             GERT_ShowError(fnc_name,msg,1);
%             obj.validated = false;
%         end
%         
    else
        obj.validated = true;
    end

end