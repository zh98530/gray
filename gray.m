clear,clc

%% 初始化
%建立符号变量a(发展系数)和u(灰作用量)
syms a u;
c=[a,u]';

%输入数据，可以修改
A=[174, 179, 183, 189, 207, 234, 220.5, 256, 270, 285];
n=length(A);%原始数据个数

%原始数据一次累加,得到1-AGO序列xi(1)。
Ago=cumsum(A);

%% 灰色预测模型
%Z(i)为xi(1)的紧邻均值生成序列
for k=1:(n-1)
    Z(k)=(Ago(k)+Ago(k+1))/2; 
end

%从第二个数开始，即x(2),x(3)...
Yn =A;
Yn(1)=[]; 
Yn=Yn';

%累加生成数据做均值
E=[-Z;ones(1,n-1)]';

%利用最小二乘法求出a，u
c=(E'*E)\(E'*Yn);
c= c';
a=c(1);
u=c(2);

%求出GM(1,1)模型公式
F=[];
F(1)=A(1);
for k=2:(n)
    F(k)=(A(1)-u/a)/exp(a*(k-1))+u/a;
end


%两者做差还原原序列，得到预测数据
G=[];
G(1)=A(1);
for k=2:(n)
    G(k)=F(k)-F(k-1);
end

%% 绘图
t1=1:n;
t2=1:n;
plot(t1,A,'bo--');
hold on;
plot(t2,G,'r*-'); 
title('预测结果');
legend('真实值','预测值');

%% 检验
%根据-a的值来推断预测的发展态势
if -a < 0.3
    disp('GM(1,1)模型可用于中长期预测')
elseif 0.3<=-a && -a<0.5
    disp('GM(1,1)模型可用于短期预测，中长期预测慎用')
elseif 0.5<=-a && -a<1.0
    disp('采用GM(1,1)改进模型')
elseif -a>=1.0
    disp('不宜采用GM(1,1)模型')       
end

%后验差检验
e=A-G;
q=e/A;%相对误差
s1=var(A);
s2=var(e);
c=s2/s1;%方差比
len=length(e);
p=0;  %小误差概率
for i=1:len
    if(abs(e(i))<0.6745*s1)
        p=p+1;
    end
end
p=p/len;

if(p>=0.95 && c<0.35)
    disp('模型为优')
elseif(0.80<=p && p<0.95 && 0.35<=c && c<0.5)
    disp('模型合格')
elseif(0.70<=p && p<0.80 && 0.50<=c && c<0.65)
    disp('模型勉强合格')
elseif(0.70>p && 0.65<=c)
    disp('模型不合格')    
end

%残差检验
Rel_err = mean(abs(q));
if Rel_err>=0.2
    disp('残差检验不合格')
elseif Rel_err<0.2 && Rel_err>=0.1
    disp('残差检验勉强合格')
elseif Rel_err<0.1
    disp('残差检验合格')    
end

%关联度检验，大于0.6即可满意
P = 0.5;
T = ((min(abs(A - G)) + P*max(abs(A - G)))*ones(1,length(A)))./(abs(A - G) + P*max(abs(A - G)));
Rel_T = mean(T);
if Rel_T>=0.6
    disp('关联度检验合格')
elseif Rel_T<0.6
    disp('关联度检验不合格')    
end
