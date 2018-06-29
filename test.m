clc; close all;
path='C:\Users\SwethaUmbria\Desktop\Dataset\Dataset';
fnm='labels.txt';
fid=fopen([path '\' fnm],'r+'); 

i=1;servity=0;tissue=0;

while feof(fid)~=1 
    file=fgetl(fid);
    k(i)=ftell(fid);
    if i==1 p(i)=k(i)-2;else p(i)=k(i)-k(i-1)-2;end
    if strcmp(file(1:3),'mdb')==1 
        name(i,1:6)=file(1:6); 
        abnormality(i)=file(10);
        servity(i)=0;
        center(i,1:3)=[0 0 0];
    end
 if p(i)>12
     if strcmp(file(12),'0')==1 servity(i)=1;elseif strcmp(file(12),'1')==1 servity(i)=2;end
     if p(i)>13
            center(i,1:3)=str2num(file(14:p(i)));
     end
   
 end
 
    i=i+1;
   
end
for i=1:330
    A=imread([path '\' name(i,:) '.pgm']);
    if center(i,:)~=[0 0 0]
%       x=1024-center(i,2);
      x=center(i,2);
      y=center(i,1);
      r=center(i,3)+10;
      xr=x-r;
      rx=x+r;
      yr=y-r;
      ry=r+y;
      if xr<0
          xr=1;
      end
      if yr<0
          yr=1;
      end
      if rx>1024
          rx=1024;
      end
      if ry>1024
          ry=1024;
      end
      B{i}=imresize(A(xr:rx,yr:ry),[100,100]);
    else
      B{i}=imresize(A,[100,100]);
    end
    HogFeat{i}=extractLBPFeatures(B{i});

end
% Data=reshape(HogFeat{1}.',1,[]);
% for i=2:330
%     temp=reshape(HogFeat{1}.',1,[]);
%     Data=vertcat(Data,temp);
% end
% meanD=mean(Data);
% stdD=std(Data);
% for i=1:330
%     Data(i,:)=Data(i,:)-meanD;
%     Data(i,:)=Data(i,:)./stdD;
% end
% Train=Data(1:230,:);
% trainserv=servity(1:230);
% testserv=servity(231:330);
% Test=Data(231:330,:);
% regtree=fitctree(Train,trainserv');
% testpred=predict(regtree,Test);

importdata('data.csv');
FV= [area_mean area_se area_worst compactness_mean compactness_se compactness_worst, concavepoints_mean, concavepoints_se, concavepoints_worst concavity_mean, concavity_se, concavity_worst concavity_mean, concavity_se, concavity_worst fractal_dimension_mean, fractal_dimension_se, fractal_dimension_worst, id, perimeter_mean, perimeter_se, perimeter_worst, radius_mean, radius_se, radius_worst, smoothness_mean, smoothness_se, smoothness_worst, symmetry_mean, symmetry_se, symmetry_worst, texture_mean, texture_se, texture_worst];
FVtrain=FV(1:369,:);
FVTest=FV(370:569,:);
trainlab=diagnosis(1:369);
testlab=diagnosis(370:569);

svm=svmtrain(FVtrain,trainlab);
pred=svmclassify(svm,FVTest);

perc=0;
for i=1:200
if pred{i}==testlab{i}
perc=perc+1;
end
end

regtree=fitctree(FVtrain,trainlab);
testpred=predict(regtree,FVTest);

perc2=0;
for i=1:200
if testpred{i}==testlab{i}
perc2=perc2+1;
end
end

knn=fitcknn(FVtrain,trainlab,'Distance','hamming'); %'cityblock' %'euclidean'
testpredknn=predict(knn,FVTest);

perc3=0;
for i=1:200
if testpredknn{i}==testlab{i}
perc3=perc3+1;
end
end

for i=1:200
    if pred{i}=='M';
        predmat(i)=0;
    elseif pred{i}=='B'
        predmat(i)=1; % labels of svm
    end
    if testpred{i}=='M';
        testpredmat(i)=0;
    elseif testpred{i}=='B'
        testpredmat(i)=1; % labels of dec tree
    end
    if testpredknn{i}=='M';
        testpredknnmat(i)=0;
    elseif testpredknn{i}=='B'
        testpredknnmat(i)=1; %labels of knn
    end
    if testlab{i}=='M';
        testlabmat(i)=0;
    elseif testlab{i}=='B'
        testlabmat(i)=1; %labels of test data
    end
end

accSVM=sum(predmat==testlabmat)/200
acctree=sum(testpredmat==testlabmat)/200
accknn=sum(testpredknnmat==testlabmat)/200


plotconfusion(testpredknnmat,testlabmat);