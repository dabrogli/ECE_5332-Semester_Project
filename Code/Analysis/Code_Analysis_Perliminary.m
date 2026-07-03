close all; clear;
%{
%% Information
% Author: Dante Broglie
% Date Started: June 25, 2026

%% Loading Data

data_directory = "../../Data/";

% Loading Wind Location Data
wind_directory = data_directory + "./Wind_Location/";
wind_location = wind_directory + "";

% Loading PV Location Data
pv_directory = data_directory + "./PV_Location/";
pv_location = pv_directory + "uspvdb_v4_0_20260414_informed.csv";

pv_table = readtable(pv_location);

% Simlifying to just sites in Texas.
pv_table_split = pv_table.p_state == "TX" ;
pv_table = pv_table(pv_table_split, :);

% Simplifying to just unique projects.
[pv_table_projects, loca, locc] = unique(pv_table.p_name);
pv_table = pv_table(loca, :);


% Loading Weather Data
weather_directory = data_directory + "./NOAA-Local_Climatological_Data/";
weather_data = weather_collect_data(weather_directory);

function weather_struct = weather_collect_data(weather_directory)

	weather_struct = struct();
	
	weather_dir = dir(weather_directory);
	weather_dir_size = size(weather_dir);
	
	weather_names = [""];
	for idx = 1:weather_dir_size(1)
	
		weather_names(idx) = weather_dir(idx).name;
	end
	
	weather_names = weather_names(contains(weather_names, ".csv"));
	weather_names_len = length(weather_names);
	
	weather_table_names = ["station_id", "datetime", "precip", "humidity", "wind_speed", "temperature"];
	weather_table_types = ["string", "datetime", "double", "double", "double", "double"];
	weather_table_len = length(weather_table_names);
	
	for idx = 1:weather_names_len
		fprintf("%d\n", idx)
		temp_read_table = readtable(weather_directory + weather_names(idx));
	
		temp_read_size =  size(temp_read_table);
	
		temp_table = table(Size=[temp_read_size(1) weather_table_len], VariableNames=weather_table_names, VariableTypes=weather_table_types);
	
		temp_table.station_id = temp_read_table.STATION;
		temp_table.datetime = temp_read_table.DATE;
		temp_table.precip = noaa_data_prepare(temp_read_table.HourlyPrecipitation);
		temp_table.humidity = temp_read_table.HourlyRelativeHumidity;
		temp_table.wind_speed = temp_read_table.HourlyWindSpeed;
		temp_table.temperature = temp_read_table.HourlyDryBulbTemperature;

		temp_station = string(unique(temp_table.station_id));

		if (isscalar(temp_station))
			weather_struct.(temp_station) = temp_table;
		else
			fprintf("ERROR: %s has multiple stations.", weather_names(idx));
		end
	%{
		if (idx == 1) 
			weather_table = temp_table;
		else 
			weather_table = vertcat(weather_table, temp_table);
		end
	%}
	end
end

function data_prep = noaa_data_prepare(data)
	
	data_check = isa(data, 'double');

	data_prep = data;

	if (~data_check)
		data_prep = str2double(data);
	end
end
%}