ID = 11468500;
idx = find([st_master(:).ID]==ID);
st = st_master(idx);
st.HYDROL_TIMELINE

[Pq,Rq,wysq] = wswb_extract_st_PR(st,'QuantMinRbDOY');
[Pm,Rm,wysm] = wswb_extract_st_PR(st,'MedMinRbDOY');
[Po,Ro,wyso] = wswb_extract_st_PR(st,'Oct1');

x = 150:50:1550;
[no,xo] = hist(Po-Ro,x);
[nm,xm] = hist(Pm-Rm,x);
[nq,xq] = hist(Pq-Rq,x);

figure
bar(x,[no./length(Po);nq./length(Pq)]',1)
% plot(xo,[no./length(Po);nm./length(Pm);nq./length(Pq)]','LineWidth',3)
% plot(xo,[no./length(Po);nq./length(Pq)]','LineWidth',3)
title([st.METADATA.ws.GAGESII.BASINID.STANAME,': ',num2str(ID)])
legend(['Oct1 N=',num2str(length(Po))],['Calc N=',num2str(length(Pq))])
xlabel('P-R (mm)')
ylabel('Fractional Count')