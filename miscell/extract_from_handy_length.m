pos_list={'A','B','C','D'};
col=1;
for pos=pos_list
    Npos=char(pos);
    row=1;
    for field=pippo'
        Nfield=char(field);
        tabby(row,col)=handy_length.(Npos).(Nfield)(20);
        row=row+1;
    end
    col=col+1;
end