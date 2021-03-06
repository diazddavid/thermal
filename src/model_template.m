%{
# Thermal mathematical model (TMM) set up function.

OUTPUT:

This function returns a structure with 

* node properties
* conduction links
* radiative links

All units are SI units.

Initial temperatures and thermal loads (internal and external) are
scenario-specific, and are not contained in this structure. They are
generated by the companion function `thermal_scenario`.

This function can be used as a template when creating the TMM of a new
system. 

Mario Merino <mario.merino@uc3m.es>, 2020
%}
function model = thermal_model

%% TMM name, description, date
model.info.name = 'Template'; % A short name for the current TMM
model.info.date = '20200415'; % TMM date
model.info.description = 'Just a template TMM file. Copy and modify this file'; % TMM description

%% Node data
model.nodes.n = 3; % Number of nodes. Must be consistent with the following

capacitance = ... % Auxiliary variable. Thermal capacitance of each node [J/(K*kg)]
[
    500
    800
    400
];

mass = ... % Auxiliary variable. Mass of each node [kg]
[
    3
    4
    3
];

model.nodes.capacity = capacitance.*mass; % Thermal capacity of each node [J/K]

%% Conductive links 
conductivity(model.nodes.n,model.nodes.n) = 0; % Auxiliary variable. Conductivity matrix for each pair of nodes. Upper triangular matrix [W/(K*m)]
conductivity(1,2) = 220; 
conductivity(1,3) = 100;
conductivity(2,3) = 200;

area(model.nodes.n,model.nodes.n) = 0; % Auxiliary variable. Contact area for each pair of nodes. Upper triangular matrix [m^2]
area(1,2) = 0.01; 
area(1,3) = 0.002;
area(2,3) = 0.01;

length(model.nodes.n,model.nodes.n) = 0; % Auxiliary variable. Contact length for each pair of nodes. Upper triangular matrix [m]
length(1,2) = 0.01; 
length(1,3) = 0.01;
length(2,3) = 0.01;

model.conduction.conductance = (conductivity+conductivity').*(area+area')./(length+length'+eye(model.nodes.n)); % Conductance matrix. This is a very crude estimation of the conductances. Correct as needed [W/K]

%% Radiative links
areaproducts(model.nodes.n,model.nodes.n) = 0; % Auxiliary variable. Product of effective radiative area of each pair of nodes. Upper triangular matrix [m^4]
areaproducts(1,2) = 0; 
areaproducts(1,3) = 0;
areaproducts(2,3) = 0;

distance(model.nodes.n,model.nodes.n) = 0; % Auxiliary variable. Effective radiative distance between nodes. Upper triangular matrix [m]
distance(1,2) = 1; 
distance(1,3) = 1;
distance(2,3) = 1;

model.radiation.AF = (areaproducts+areaproducts')./(2*pi*(distance+distance'+eye(model.nodes.n)).^2); % Area * view factor for each pair of nodes. This is a very crude estimation of the view factors, and only serves as a good approximation for small areas sufficiently far away. Correct as needed [m^2]

model.radiation.AFspace = ... % Area * view factor for radiation to free space for each node [m^2]
[
    0.5 
	0
	0.5
];

model.radiation.Eij(model.nodes.n,model.nodes.n) = 0; 
model.radiation.Eij(1,2) = 1; 
model.radiation.Eij(1,3) = 1;
model.radiation.Eij(2,3) = 1;
model.radiation.Eij = model.radiation.Eij + model.radiation.Eij'; % Effective emissivity between each two nodes, Eij = Ei*Ej/(Ei+Ej-Ei*Ej) [-]

model.radiation.Espace = ... % Emissivity of each node to free space [-]
[
    0.8
    0
    0.8
];

model.radiation.Asun = ... % Absorptivity of each node [-]
[
    1
    0
    1
];


