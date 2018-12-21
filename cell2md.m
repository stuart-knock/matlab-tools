%% Converts a cell array of char arrays into a MarkDown table.
%
% ARGUMENTS: 
%    C -- cell-array of char arrays.
%    headers -- [optional] cell-array of column headings, must have
%               one entry per column (element of C).
%
% OUTPUT:
%    markdown_table -- A char array with MarkDown table formatting.
%
% AUTHOR:
%     Stuart A. Knock (2018-04-27).
%
% USAGE:
%{ 
    headers = {'Person', 'Value'};
    rows = {'bob'; 'fred'; 'loki'};
    X = rand(3,1);
    [markdown_table] = cell2md({char(rows), num2str(X, '%5.2f')}, headers)

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TODO(stuart-knock): Add internal formatting of other types, such that the
%                    usage example, for example, could be called as:
%                        [markdown_table] = cell2md({rows, X}, headers, fmt)
%                    where 'fmt' would be {'', '%5.2f'} in this case.

function [markdown_table] = cell2md(C, headers)
    if nargin > 1 && ~isempty(headers)
        if numel(C) ~= numel(headers)
            error(['SAK:' mfilename ':BadArg'], ...
                  'headers must contain the same number of elements as data.');
        end
        add_header = true;
        % Get the length of each header.
        header_lengths = cellfun(@(x) length(x), headers);
        % Calculate column widths, used to set consistent row length.
        min_h_sep_length = 5; %:---:
        column_widths = cellfun(@(x,y) max([size(x,2), length(y), min_h_sep_length]) +2, ...
                                C, headers);
        % Construct header separator strings.
        h_sep = arrayfun(@(x) strcat(pad(' :', max(x-3, 5), 'right', '-'), ': |'), ...
                         column_widths,                                            ...
                         'UniformOutput', false);
    else
        add_header =false;
        % Calculate column widths, used to set consistent row length.
        column_widths = cellfun(@(x,y) max([size(x,2), length(y)]) +2, ...
                                C, headers);
    end

    % Build the table from the data and any headers.
    table_header = [];
    header_seperator = [];
    markdown_table = [];
    for k = 1:numel(C)
        if add_header
            hdr_sep_offset = floor((length(h_sep{k})-header_lengths(k))./2.0);
            hdr_fmt = ['%' num2str(column_widths(k)-hdr_sep_offset) 's'];
            sep_fmt = ['%' num2str(column_widths(k)+1) 's'];

            table_header = strcat(table_header,                 ...
                                  sprintf(hdr_fmt, headers{k}), ...
                                  pad('|', hdr_sep_offset+1, 'left'));
            header_seperator =  strcat(header_seperator, sprintf(sep_fmt, h_sep{k}));
        end
        clmn_offset_right = floor((column_widths(k)-size(C{k},2))./2.0);
        clmn_offset_left = ceil((column_widths(k)-size(C{k},2))./2.0);
%         clmn_fmt = ['%' num2str(clmn_offset) 's'];
        markdown_table = strcat(markdown_table, ...
                                char(pad(strip(string(C{k})), size(C{k},2) + clmn_offset_left, 'left')), ...
                                pad('|', clmn_offset_right + 1, 'left'));
    end

    % Add initial pipes on each data row.
    markdown_table = strcat('|', markdown_table);

    if add_header
        % Add initial pipes on each header row.
        table_header = strcat('|', table_header);
        header_seperator =  strcat('|', header_seperator);

        % Concatenate header and data.
        markdown_table = [table_header;     ...
                          header_seperator; ...
                          markdown_table];
    end
end %function cell2md()
