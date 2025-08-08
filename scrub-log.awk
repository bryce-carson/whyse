/(LaTeX Warning: Reference `NW[[:alpha:]]{5}-[[:alnum:]]{6}-[[:digit:]]+' .*)\n/ { print(substring(1)); next; }
{ print }

