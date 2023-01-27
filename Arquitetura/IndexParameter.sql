show parameter optimizer_index_cost_adj
-- Default é 100

show parameter optimizer_index_caching
-- Default é 0

Alter system Set optimizer_index_caching=80 scope=both;
Alter system set optimizer_index_cost_adj=25 scope=both;
