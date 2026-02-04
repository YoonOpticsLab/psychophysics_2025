[xx,yy]=meshgrid(-1000:1000,-1000:1000);
rr=sqrt(xx.^2+yy.^2);
ri=floor(rr/100)+1;
N=numel(ri);
[~,~,iir]=unique(ri); %find unique values
Qt =sparse(1:N,iir,ones(N,1));

tic;Pf=(rr(:).'*Qt).';toc %radial average