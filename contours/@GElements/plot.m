function plot(obj,idx)

    obj = validate(obj);

    if nargin == 2
       if ~GERT_Aux_ValidVec(idx,'double') || any(mod(idx,1)) || any(idx<1)
          msg = 'Invalid index vector';
          GERT_ShowError(fnc_name,msg,3);
       end
    elseif nargin == 1
       idx = 1:obj.n;
    else
    	msg = 'Too many arguments';
        GERT_ShowError(fnc_name,msg,3);
    end
    
    figure; hold on;
    
    for i = 1:length(obj(:))
        plot(obj(i).x(idx),obj(i).y(idx),'k.');
        cx = gettag(obj(i),'c');
        cx = intersect(cx,idx);
        plot(obj(i).x(cx),obj(i).y(cx),'r.');
        bx = gettag(obj(i),'b');
        bx = intersect(bx,idx);
        plot(obj(i).x(bx),obj(i).y(bx),'b.');
        fx = gettag(obj(i),'f');
        fx = intersect(fx,idx);
        plot(obj(i).x(fx),obj(i).y(fx),'g.');
    end

    if ~isempty(obj.dims)
        plot([obj.dims(1) obj.dims(1) obj.dims(2) obj.dims(2) obj.dims(1)], ...
            [obj.dims(3) obj.dims(4) obj.dims(4) obj.dims(3) obj.dims(3)],'r-');
    end

    axis equal;
    hold off;
end