function result = growth_fn(mmol_m2_s)

data=[0, 0
58.60155382907877, 0.018597108055786293
99.44506104328525, 128.2403034396823
198.89012208657044, 146.04337133634624
401.33185349611546, 158.80155101133516
599.3340732519423, 163.4342033377739
799.1120976692564, 136.07870271082595];

pot_per_m2=20;
growth_perhour_perday = (14*17);

result=pot_per_m2*interp1(data(:,1),data(:,2),mmol_m2_s)/growth_perhour_perday;% g lettuce