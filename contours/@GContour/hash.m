function h = hash(obj)

idx = ceil(linspace(1,obj.n,10));
h = GERT_Aux_UniqueID([obj.n obj.x(idx) obj.y(idx)]);