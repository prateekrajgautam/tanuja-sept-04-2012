function[code]=loadcdmadata(name)
load(name);
group_no_to_select=1;
if exist('group')==1
    if numel(group)~=0
        select=group(group_no_to_select,:);
    end
end
if exist('groups')==1
    select=groups(group_no_to_select,:);
end
codelength=n;
[aa,users_max]=size(select);
%% generate code 
% codelength=length(dop2binary(dop(select(1,1),:)));
% for j=1:codelength
no_of_cyclic_shifted_codes_included=1;
for j=1:1:no_of_cyclic_shifted_codes_included
    if exist('num')==0
        num=0;
        for i=1:users_max
            code1(i,:)=dop(select(1,i),:);
            code(i,:)=dop2binary(code1(i,:));
        end
    end
end
end