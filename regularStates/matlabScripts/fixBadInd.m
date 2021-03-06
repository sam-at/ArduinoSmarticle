figure(1);
sizeDiff=.1;
for i=1:length(movs)
    movs(i).rot=unwrap(movs(i).rot);
    a=abs(diff(movs(i).rot));
    subplot(2,1,1)
    hold on;
    plot(a);
    
    [r,c]=find(a>sizeDiff);
    while(r)
        C=c(1);
        s=r(1);
        fNext=0;
        count=1;
        while(~fNext)
            if(abs(movs(i).rot(s,C)-movs(i).rot(s+count,C))>sizeDiff)
                count=count+1;
            else
                fNext=1;
                e=s+count;
                movs(i).rot(s:e,C)=linspace(movs(i).rot(s,C),movs(i).rot(e,C),e-s+1);
            end
            
        end
        a=abs(diff(movs(i).rot));
        [r,c]=find(a>sizeDiff);
    end
    a=(diff(movs(i).rot));
    subplot(2,1,2)
    title([num2str(i), 'fixed dat']);
    hold on;
    plot(a);
    pause
    clf;
end
save(fullfile('C:\Users\root\Desktop\others code\pavel','movieInfo.mat'),'movs','fold','nMovs','numBods','minT','vals')