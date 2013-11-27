function [P,R,wys] = wswb_extract_st_PR(st,wyType)

P	= st.WB.(wyType).PRISM_USGS.P;
Pwy = st.WB.(wyType).PRISM_USGS.Pwys;
R	= st.WB.(wyType).PRISM_USGS.R;
Rwy = st.WB.(wyType).PRISM_USGS.Rwys;

[wys,iP,iR] = intersect(Pwy,Rwy);

P = P(iP);
R = R(iR);