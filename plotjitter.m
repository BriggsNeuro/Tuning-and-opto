% figure
% for u = 1:3
% subplot(1,3,u)
% scatter(ones(1,4),Lon(:,u),'^k')
% hold on
% scatter(ones(1,4)+1,Lon(:,u+3),'^b')
% hold on
% scatter(ones(1,1),Loff(:,u),'^k','filled')
% hold on
% scatter(ones(1,1)+1,Loff(:,u+3),'^b','filled')
% hold on
% scatter(ones(1,4),Con(:,u),'ok')
% hold on
% scatter(ones(1,4)+1,Con(:,u+3),'ob')
% hold on
% scatter(ones(1,2),Coff(:,u),'ok','filled')
% hold on
% scatter(ones(1,2)+1,Coff(:,u+3),'ob','filled')
% hold on
% scatter(ones(1,1),CKon(:,u),'oc')
% hold on
% scatter(ones(1,1)+1,CKon(:,u+3),'ob')
% hold on
% scatter(ones(1,2),CPon(:,u),'or')
% hold on
% scatter(ones(1,2)+1,CPon(:,u+3),'ob')
% hold on
% 
% scatter(ones(1,1),KKon(:,u),'sc')
% hold on
% scatter(ones(1,1)+1,KKon(:,u+3),'sb')
% hold on
% scatter(ones(1,3),KKoff(:,u),'sc','filled')
% hold on
% scatter(ones(1,3)+1,KKoff(:,u+3),'sb','filled')
% hold on
% 
% scatter(ones(1,8),KMon(:,u),'sk')
% hold on
% scatter(ones(1,8)+1,KMon(:,u+3),'sb')
% hold on
% scatter(ones(1,4),KMoff(:,u),'sk','filled')
% hold on
% scatter(ones(1,4)+1,KMoff(:,u+3),'sb','filled')
% hold on
% 
% scatter(ones(1,5),KPon(:,u),'sr')
% hold on
% scatter(ones(1,5)+1,KPon(:,u+3),'sb')
% hold on
% scatter(ones(1,7),KPoff(:,u),'sr','filled')
% hold on
% scatter(ones(1,7)+1,KPoff(:,u+3),'sb','filled')
% hold on
% 
% for r = 1:42
%     plot([1 2],[N(r,u) L(r,u)],'k')
% end
% end

%figure
subplot(2,2,4)
scatter(ones(1,2),Lon(:,1),'^k')
hold on
scatter(ones(1,2)+1,Lon(:,2),'^b')
hold on
scatter(ones(1,2),Lun(:,1),'^y','filled')
hold on
scatter(ones(1,2)+1,Lun(:,2),'^b','filled')
hold on
scatter(ones(1,3),Con(:,1),'ok')
hold on
scatter(ones(1,3)+1,Con(:,2),'ob')
hold on
scatter(ones(1,2),Coff(:,1),'ok','filled')
hold on
scatter(ones(1,2)+1,Coff(:,2),'ob','filled')
hold on
scatter(ones(1,6),Kon(:,1),'sk')
hold on
scatter(ones(1,6)+1,Kon(:,2),'sb')
hold on
scatter(ones(1,1),Koff(:,1),'sk','filled')
hold on
scatter(ones(1,1)+1,Koff(:,2),'sb','filled')
hold on
scatter(ones(1,1),Kun(:,1),'sy')
hold on
scatter(ones(1,1)+1,Kun(:,2),'sb')
hold on

for r = 1:17
    plot([1 2],[N(r) L(r)],'k')
    hold on
end

errorbar([1 2],[mean(N) mean(L)],[std(N)/sqrt(13) std(L)/sqrt(13)],'dc')
hold on
plot([1 2],[mean(N) mean(L)],'k')
% hold on
% scatter(1,mean(N(Ons,u)),'dk')
% hold on
% scatter(2,mean(L(Ons,u)),'db')
% hold on
% errorbar([1 2],[mean(N(Offs,u)) mean(L(Offs,u))],[std(N(Offs,u))/4 std(L(Offs,u))/4],'dk')
% hold on
% plot([1 2],[mean(N(Offs,u)) mean(L(Offs,u))],'k')
% hold on
% scatter(1,mean(N(Offs,u)),'dk','filled')
% hold on
% scatter(2,mean(L(Offs,u)),'db','filled')
% hold on