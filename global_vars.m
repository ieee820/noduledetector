function e = global_vars()
%global dth;
%dth = [0.65, 0.40];
%global ex_size;
%ex_size = [4 4 2];
%global ex_size2;
%ex_size2 = [10 10 6];
%global dilatesiz;
%dilatesiz = 2;
%global magth;
%magth = 300;
%e = 'global dth; global ex_size; global ex_size2; global dilatesiz; global magth;';
e = ['dth = [0.65, 0.40];'...
     'ex_size = [4 4 2];'...
     'ex_size2 = [10 10 6];'... 
     'dilatesiz = 2;'...
     'magth = 0;'...
     'contol = 25;'...
     'areatol = 30;'];
end
