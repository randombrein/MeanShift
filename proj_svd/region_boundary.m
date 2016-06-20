function B=region_boundary(reg_idx)

max_idx=max(reg_idx(:));
delta=max_idx+5;

reg_idx=reg_idx+delta;

tmp_mat=zeros(2*delta-1,2*delta-1);
N=size(reg_idx,1);

for i=1:N
    row=reg_idx(i,2);
    col=reg_idx(i,1);
    tmp_mat(row,col)=1;
end


% eroded image
SE=strel('disk',2);
tmp_mat=tmp_mat-imerode(tmp_mat,SE);
[idx_y,idx_x]=find(tmp_mat);

idx_y=idx_y-delta;
idx_x=idx_x-delta;
B=[idx_x,idx_y];