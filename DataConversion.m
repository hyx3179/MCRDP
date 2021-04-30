clear
foldername = uigetdir('C:\Users\Public\Documents\','选择要转换的文件夹');
load([foldername '\Data.mat'], 'Discontinuity','Filename')
Filename = replace(string(Filename), '_', '-');
Filename = char(Filename);
Data = dir([foldername '\*.csv']);
Data = rmfield(Data,["date", "isdir", "datenum"]);
for ii = 1:length(Data)
    if contains(Data(ii).name, "-PSET")
        Data(ii).type = 'PULSE';
        Data(ii).Process = 'SET';
    elseif contains(Data(ii).name, "-PRESET")
        Data(ii).type = 'PULSE';
        Data(ii).Process = 'RESET';
    elseif contains(Data(ii).name, "-SET")
        Data(ii).type = 'SWEEP';
        Data(ii).Process = 'SET';
    elseif contains(Data(ii).name, "-RESET")
        Data(ii).type = 'SWEEP';
        Data(ii).Process = 'RESET';
    else
        Data(ii).type = 'TIME';
        Data(ii).Process = 'TIME';
    end
    Data(ii).date = datetime(Data(ii).name(1:15) , 'InputFormat', 'yyyyMMdd-HHmmss');
    cache = load([Data(ii).folder '\' Data(ii).name]);
    Data(ii).Time = cache(:,1);
    Data(ii).Voltage = cache(:,2);
    Data(ii).Current = cache(:,3);
    Data(ii).Discontinuity = 1;
    Data(ii).Delete = false;
    index = find(contains(string(Filename(:,1:15)), Data(ii).name(1:15)));
    if ~isempty(index)
        Data(ii).Delete = contains(string(Filename(index,:)), 'set');
        if ~Data(ii).Delete
            Data(ii).Discontinuity = Discontinuity(index);
        end
    end
end
movefile([foldername '\Data.mat'], [foldername '\old.mat'])
save([foldername '\Data.mat'], 'Data')