function [ price ] = MonteCarlo(F0, T, cr, alpha, miu, sigmar, cH, s, sigmaH, td, EndDft, ExoDft, ti,Nrepl, Nstep)
%UNTITLED2 Summary of this function goes here
%F0�������
%T���������ޣ��꣩
%cr����ǰ����
%alpha��CIRģ�������ʵ����ٶ�
%miu��CIRģ�������ʾ�ֵ
%sigmar��CIRģ�������ʲ�����
%cH����ǰ����
%s�������
%sigmaH��GBģ���з��۲�����
%td��ΥԼ�ɱ��ʣ���Է��۵İٷֱȣ�
%EndDft��dtʱ��������ΥԼ����
%ExoDft��dtʱ���ڷ�����ΥԼ����
%ti: �������ֳɱ���
%Nrepl��·��������
%Nstep��ÿ��·���Ĳ���

%   Detailed explanation goes here
dt = T/Nstep;
r = cr * ones(Nrepl, Nstep);
H = cH * ones(Nrepl, Nstep);

A = F0 * (c/12) * (1+c/12)^(12*Nstep)/((1+c/12)^(12*Nstep)-1); %ÿ��֧�����
F = F0 * ones(1, Nstep);
%���ɴ����������
for i = 1:(Nstep-1)
    F(1, i+1) = F(1, i) * (1+c/12)-A;
end

%MonteCarloSimulation����Nrepl�����ʺͷ�������
for i = 1:Nrepl
    for j = 1:(Nstep-1)
        r(i, j+1) = r(i, j) + alpha*(miu-r(i, j))*dt + sqrt(r(i, j))*sigmar*sqrt(dt)*randn;
        H(i, j+1) = H(i, j)* exp((r(i, j) - s - 0.5*sigmaH^2) * dt+sigmaH * sqrt(dt)* randn);
    end
end

%��������ΥԼ��������
p = zeros(Nrepl, Nstep+1);
k = zeros(Nrepl, Nstep+1);
W = zeros(Nrepl, Nstep+1);
for i = 1:Nrepl
    for j = 1:Nstep
        k(i, j+1) = (log((c/s*F(1,j+1)-r(i,j+1)/s*td)/H(i,j)) - ((r(i,j+1)-s)-0.5*sigmaH^2)*dt)/(sigmaH*sqrt(dt));%ΥԼ����
        pl = normcdf(k(i,j+1),0,1); %������ȨΥԼ��������ĸ���
        p(i, j+1) = pl *  EndDft * dt + (1-pl) * (1 - EndDft) * dt + ExoDft * dt; %ΥԼ����
        W(i, j+1) = H(i,j+1)*(1-ti); %ΥԼ�ֽ���
    end
end

%���������ֵ����
V = zeros(Nrepl, Nstep + 1);
V(:,Nstep+1) =(ones(Nrepl,1) - p(:, Nstep+1)).* A + p(:,Nstep+1).* W(i, j+1);
for i = 1:Nrepl
    for j = Nstep:-1:1
        V(i,j) = (1 - p(i, j))* V(i, j+1)*exp(-r(i,j)*dt) + p(i,j)* W(i,j);
    end
end

price = mean(V(:,1));

end

