% --------------------------------------------------------------------------------
% Function : AED_element_lookup
%
% Description : parse element string and determine corresponding id number.
%               id number is composed of:
%               digit 1-3: element mass (most abundant isotope).
%               digit 4-6: AED wavelength.
%               digit 7: 1 if "multi" is appended to element string
%               unused digits: zeros (remove at beginning)
%
% Created : 2017-04, F.Obersteiner, florian.obersteiner@kit.edu
%
% Modifications: 
%
% --------------------------------------------------------------------------------
%
function [element_id] = AED_element_lookup( elementstring, separator )

% describe element masses [u]
%   add new elements here - avoid duplicates in m/q string (2nd col)
%   use lower case strings for names
    elements = [...
        "carbon" "12";...
        "antimony" "121";...
        "arsenic" "75";...
        "boron" "11";...
        "bromine" "79";...
        "germanium" "74";...
        "iodine" "127";...
        "mercury" "202";...
        "nitrogen" "14";...
        "phosphorus" "31";...
        "selenium" "80";...
        "silicon" "28";...
        "sulfur" "32";...
        "oxygen" "16"...
                 ] ;


    % check for multi keyword
    if contains(elementstring, "multi", 'IgnoreCase', true)
        multi = "1";
    else 
        multi = "0";
    end

    % parse the element info string into substrings...
    elementstring = lower(deblank(elementstring));
    % separator = " ";
    ix_sep = [0 strfind(elementstring, separator)];
    substrings = strings(numel(ix_sep),1);

    for i=1:numel(ix_sep)
        if i < numel(ix_sep)
            substrings(i) = extractBetween(elementstring, ix_sep(i)+1, ix_sep(i+1)-1);
        else
            substrings(i) = extractBetween(elementstring, ix_sep(i)+1, strlength(elementstring));
        end
    end    

    % find element in element structure...
    % ...and determine element_id string.
    ix_mq = find(contains(elements, substrings(1,1)));
        if strcmp(string(class(ix_mq)), "double")
            mq = elements(ix_mq+numel(elements)/2);
            element_id = mq + substrings(2,1) + multi;
        else
            mq = "999";
            element_id = mq + "9990";
        end

end