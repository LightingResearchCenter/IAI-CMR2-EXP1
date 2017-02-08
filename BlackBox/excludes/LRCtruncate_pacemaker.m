function pacemaker = LRCtruncate_pacemaker(pacemaker)
%LRCTRUNCATE_PACEMAKER Truncate pacemaker to most recent run
%   Discards entries other than the most recent run. One of the fields
%   must be runTimeUTC. All fields must be of equal length.

[~,idx] = max(pacemaker.runTimeUTC);

fields = fieldnames(pacemaker);
for iField = 1:numel(fields)
    thisField = fields{iField};
    pacemaker.(thisField) = pacemaker.(thisField)(idx,:);
end
end

