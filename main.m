% 参数：数据文件夹名称 过程 画图选项
%     过程 -- ALL 所有
%             SET 过程
%             RESET 过程
%     画图选项 -- 1-9999 第 n 个数据图像
%                inf 全部
% main('C:\Users\hyx3179\Documents\MATLAB\20210318','ALL',1)
% main('20210318',1,0);
function [I_raw, V_raw, Discontinuity] = main(foldername, varargin)
if nargin < 2
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargin > 4
    error(message('MATLAB:narginchk:tooManyInputs'));
end

%% 查找文件列表
if exist([foldername foldername(end-8:end) '.mat'],'file')
    load([foldername foldername(end-8:end) '.mat'], 'filename')
else
    main_foldername = pwd;
    cd(foldername)
    filename = ls;
    filename = filename(3:end,:);
    cd(main_foldername)
    save([foldername foldername(end-8:end) '.mat'],'filename')
end
switch nargin
    case 2
        [I_raw, V_raw, Discontinuity] = raed_raw(foldername,filename,varargin{1});
end
end
% 读取原始数据
function [I_raw, V_raw, Discontinuity] = raed_raw(foldername,filename,Process)
%% 读取原始数据
Amount_of_file = size(filename,1);
Max_amount_of_data = 2000;

if contains(Process,'ALL')
    Process = '';
end

% datetime('20210318-211027','InputFormat','yyyyMMdd-HHmmss')
V_raw = zeros(Max_amount_of_data,Amount_of_file);
I_raw = zeros(Max_amount_of_data,Amount_of_file);
jj = 0;
for ii = 1:Amount_of_file
    if contains(filename(ii,:),['-' Process])
        [~,V,I] = importfile([foldername '\' filename(ii,:)]);
        
        jj = jj + 1;
        V_raw(:,jj) = [V(1:round(length(V)/2)) ; ...
            ones(Max_amount_of_data-1-length(V),1)*inf ; ...
            V(round(length(V)/2:end))];
        I_raw(:,jj) = [I(1:round(length(I)/2)) ; ...
            ones(Max_amount_of_data-1-length(I),1)*inf ; ...
            I(round(length(I)/2:end))];
    end
end
V_raw = V_raw(1:Max_amount_of_data,1:jj);
I_raw = I_raw(1:Max_amount_of_data,1:jj);
%% 寻找突变点
for ii =1:jj
    x = find(I_raw(:,ii) == inf);
    I_raw(x,ii) = I_raw(x(1) - 1, ii);
end
data = abs(diff(I_raw));
[~, Discontinuity] = max(data);
end

function Drawing(V_raw,I_raw)
%% 画图
% Amount_of_file = size(I_raw,2);
% Amount_of_file = 5;
% plot(V_raw(:,1),I_raw(:,1),'k')
% hold on
% for ii =1:Amount_of_file
%     plot(V_raw(:,ii),I_raw(:,ii),'k')
% end
% figure

if Drawing < inf
    semilogy(V_raw(:,Drawing),abs(I_raw(:,Drawing)),'k')
    hold on
    scatter(V_raw(Discontinuity(Drawing),Drawing),abs(I_raw(Discontinuity(Drawing),Drawing)),'r')
else
    semilogy(V_raw(:,1),abs(I_raw(:,1)),'k')
    hold on
    for ii =2:jj
        semilogy(V_raw(:,ii),abs(I_raw(:,ii)),'k')
    end
    for ii =1:jj
        scatter(V_raw(Discontinuity(ii),ii),abs(I_raw(Discontinuity(ii),ii)),'r')
    end
end
hold off
end


function [times, Voltage, Current] = importfile(filename, dataLines)
%IMPORTFILE 从文本文件中导入数据
%  [TIME, VOLTAGE, CURRENT] = IMPORTFILE(FILENAME)读取文本文件 FILENAME
%  中默认选定范围的数据。  以列向量形式返回数据。
%
%  [TIME, VOLTAGE, CURRENT] = IMPORTFILE(FILE, DATALINES)按指定行间隔读取文本文件
%  FILENAME 中的数据。对于不连续的行间隔，请将 DATALINES 指定为正整数标量或 N×2 正整数标量数组。
%
%  示例:
%  [time, Voltage, Current] = importfile("C:\Users\hyx3179\Documents\MATLAB\20210319-183105---SET.csv", [1, Inf]);
%
%  另请参阅 READTABLE。
%
% 由 MATLAB 于 2021-03-20 20:11:08 自动生成

%% 输入处理

% 如果不指定 dataLines，请定义默认范围
if nargin < 2
    dataLines = [1, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3);

% 指定范围和分隔符
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 指定列名称和类型
opts.VariableNames = ["time", "Voltage", "Current"];
opts.VariableTypes = ["double", "double", "double"];

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 导入数据
tbl = readtable(filename, opts);

%% 转换为输出类型
times = tbl.time;
Voltage = tbl.Voltage;
Current = tbl.Current;
end