% 参数：数据文件夹名称 过程 画图选项 选项
% 参数说明：
%     过程 -- ALL 所有
%             SET 过程
%             RESET 过程
%     数据选择 -- 1-9999 第 n 个数据
%                 inf 全部（仅画图）
%     选项 -- Delete 删除选择的数据
%
%% 使用方法
% [I_raw, V_raw, Discontinuity] = main('foldername', 'SET'); % 仅导出原始数据
% main('foldername', 'ALL', 7) % 画出所有数据中第 7 组数据
% main('foldername', 'SET', 6, 'Delete') % 删除 SET过程 数据中第 6 组数据

% datetime('20210318-211027', 'InputFormat', 'yyyyMMdd-HHmmss')

%%
function [varargout] = main(foldername, varargin)
%% 检查参数
if nargin < 2
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargin > 6
    error(message('MATLAB:narginchk:tooManyInputs'));
end
%% 调用功能
switch nargin
    case 2
        [I_raw, V_raw, Discontinuity] = raed_raw(foldername, varargin{1});
    case 3
        [I_raw, V_raw, Discontinuity] = raed_raw(foldername, varargin{1});
        Drawing(V_raw, I_raw, Discontinuity, varargin{2})
    otherwise
        Edit_data(foldername, varargin{1}, varargin{2}, varargin{3})
end
if nargout
    varargout{1} = I_raw;
    varargout{2} = V_raw;
    varargout{3} = Discontinuity;
end
end

% 读取原始数据
function [I_raw, V_raw, Discontinuity] = raed_raw(foldername, Process)
%% 查找文件列表
if exist([foldername '\filename.mat'], 'file')
    load([foldername '\filename.mat'], 'filename')
else
    main_foldername = pwd;
    cd(foldername)
    filename = ls;
    filename = filename(3:end, :);
    cd(main_foldername)
    save([foldername '\filename.mat'], 'filename')
end
%% 读取原始数据
Amount_of_file = size(filename, 1);
Max_amount_of_data = 2000;

if contains(Process, 'ALL')
    Process = '';
end

V_raw = zeros(Max_amount_of_data, Amount_of_file);
I_raw = zeros(Max_amount_of_data, Amount_of_file);
jj = 0;
for ii = 1:Amount_of_file
    if contains(filename(ii, :), ['-' Process])
        [~, V, I] = importfile([foldername '\' filename(ii, :)]);
        
        jj = jj + 1;
        V_raw(:, jj) = [V(1:round(length(V)/2)) ; ...
            ones(Max_amount_of_data-1-length(V), 1)*inf ; ...
            V(round(length(V)/2:end))];
        I_raw(:, jj) = [I(1:round(length(I)/2)) ; ...
            ones(Max_amount_of_data-1-length(I), 1)*inf ; ...
            I(round(length(I)/2:end))];
    end
end
V_raw = V_raw(1:Max_amount_of_data, 1:jj);
I_raw = I_raw(1:Max_amount_of_data, 1:jj);
%% 寻找突变点
if exist([foldername '\Discontinuity.mat'], 'file')
    load([foldername '\Discontinuity.mat'], 'Discontinuity')
else
    cache = I_raw;
    for ii =1:jj
        x = find(cache(:, ii) == inf);
        cache(x, ii) = cache(x(1) - 1, ii);
    end
    data = abs(diff(cache));
    [~, Discontinuity] = max(data);
    save([foldername '\Discontinuity.mat'], 'Discontinuity')
end
end

function Drawing(V_raw, I_raw, Discontinuity, n)
%% 画图
% Amount_of_file = size(I_raw, 2);
% Amount_of_file = 5;
% plot(V_raw(:, 1), I_raw(:, 1), 'k')
% hold on
% for ii =1:Amount_of_file
%   plot(V_raw(:, ii), I_raw(:, ii), 'k')
% end
% figure
jj = length(Discontinuity);
if n < inf
    semilogy(V_raw(:, n), abs(I_raw(:, n)), 'k')
    hold on
    scatter(V_raw(Discontinuity(n), n), abs(I_raw(Discontinuity(n), n)), 'r')
else
    semilogy(V_raw(:, 1), abs(I_raw(:, 1)), 'k')
    hold on
    for ii =2:jj
        semilogy(V_raw(:, ii), abs(I_raw(:, ii)), 'k')
    end
    for ii =1:jj
        scatter(V_raw(Discontinuity(ii), ii), abs(I_raw(Discontinuity(ii), ii)), 'r')
    end
end
hold off
end

function Edit_data(foldername, Process, n, Options)
%%
if exist([foldername '\filename.mat'], 'file') && exist([foldername '\Discontinuity.mat'], 'file')
    load([foldername '\filename.mat'], 'filename')
    load([foldername '\Discontinuity.mat'], 'Discontinuity')
else
    error('未进行数据导出');
end
Amount_of_file = size(filename, 1);
if contains(Process, 'ALL')
    Process = '';
end
jj = 0;
for ii = 1:Amount_of_file
    if contains(filename(ii, :), ['-' Process])
        jj = jj + 1;
        if jj == n
            if contains(Options, 'Delete')
                filename(ii, :) = strrep(filename(ii, :),'SET','set');
                Discontinuity(ii) = [];
                save([foldername '\filename.mat'], 'filename')
                save([foldername '\Discontinuity.mat'], 'Discontinuity')
            end
            
        end
    end
end
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
%  [time, Voltage, Current] = importfile("FILENAME", [1, Inf]);
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