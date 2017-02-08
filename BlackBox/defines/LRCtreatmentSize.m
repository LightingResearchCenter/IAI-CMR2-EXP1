function treatmentSize = LRCtreatmentSize
%LRCTREATMENTSIZE Summary of this function goes here
%   Detailed explanation goes here

n = ceil(LRCtreatmentPlanLength*24*60*60/LRCtreatmentInc/2);

treatmentSize = [n,0];

end

