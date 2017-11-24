function [ price ] = LSM( cp, X, T, r, coupon, sigma, mcallschedule, Nrepl, Nstep)
%UNTITLED2 Summary of this function goes here
%cp:��ǰ�ɼ�
%X����ʼת�ɼ�
%T��ծȯ����
%r:�޷�������
%coupon��Ʊ�����ʣ�������ʽ��
%sigma���껯�ղ�����
%mcallschedule:������ؼ�
%Nrepl��·��������
%Nstep��ÿ��·���Ĳ���
%   Detailed explanation goes here
dt = T/Nstep;
s = cp * ones(Nrepl, Nstep);

%MonteCarloSimulation����Nrepl���ɼ�����
for i = 1:Nrepl
    for j = 1:(Nstep-1)
        s(i, j+1) = s(i, j) * exp((r-0.5*sigma^2) * dt+sigma * sqrt(dt)* randn);
    end
end

X = X * ones(Nrepl, Nstep);  %����ÿ��·����ת�ɼ�
p = zeros(Nrepl, 1); %���תծ�۸�

%Ϊ��ֹ���۶�����ת�ɼ�
for j = 1:Nrepl
    for k = 0:T-1
        for i = (1 + k*Nstep/T + round(0.9/(k+1))*0.5*k*Nstep/T):((k+1)*Nstep/T -30*floor((k+1)/T))
            if size(find(s(j,i:i+29)<X(j,i:i+29)*0.8))>=15
                X(j,i+30:Nstep) = mean(s(j,i:i+29));
                break
            end
        end
    end
end
   
for j=1:Nrepl %ͳ�ƴ�����������·��
    for i=(0.5*Nstep/T+1):Nstep-30
        if (find(s(j, i:i+29)>= 1.3*X(j,i:i+29)))>=15 
            p(j,1)=((100/X(j,i+30))*s(j,i+30)+sum(coupon(1,1:floor(i*T/Nstep))))*exp(-r*dt*i);
            break
        end
    end
end

%����Ʊģ��·���������ȥ����ʣ�µ�·��ת�ɼ��Ѿ�ȷ������ȫ���ܿ�תծ���������Ӱ��
for m = 1:Nrepl
    if p(m,1)>0 %�������·���Ѿ���ǰת��
        s(m,:)=0; %ɾȥ����·���е����йɼ�����
    end
end

A = 100*s(:,Nstep)./X(:,Nstep); %ÿ��·������ת����ֵ��������A
cashflows = max(A, mcallschedule); %mcallscheduleΪ������ؼ�ֵ��cashflows�����洢ÿ��·���ڲ�ͬʱ�̵�cb��ֵ
for i=1:Nrepl
    if A(i,1)==0 %������ص�����ǰת�ɵ�·���Ĺɼ��Ѿ�ɾȥ����˸�·����A��Ϊ0
        cashflows(i, 1)=0;
    end
end

for step = (Nstep-1):-1:0.5*Nstep/T
    cashflows(:,1) = cashflows(:,1).* exp(-r*dt); %����һ�ڵ��ֽ������ֵ�����
    ConversionPrice = 100*s(:,step)/X(:,step); %�����step��ת����ֵ
    PathNo = find(s(:, step)>X(:,step)); %��¼�ɼ۴���ת�ɼ۵�λ��
    x = s(PathNo, step); 
    y = cashflows(PathNo, 1);
    RegressionMatrix = [ones(length(y),1),x, x.^2];
    b = regress(y,RegressionMatrix);
    HoldingPrice = [ones(length(s(:,step)),1),s(:,step),s(:,step).^2]*b; %����step�ڵĳ��м۸�
    cashflows(PathNo,1)=max(ConversionPrice(PathNo,1),HoldingPrice(PathNo,1));
end

cashflows0 = cashflows.*exp(-r*dt*(0.5*Nstep/T));
price = mean(cashflows0(:,1)+p(:,1));

end

