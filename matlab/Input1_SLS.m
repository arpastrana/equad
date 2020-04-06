
% Package: 		FORM-FINDING AND NONLINEAR STATIC ANALYSIS USING DYNAMIC RELAXATION
% Authors: 		L. Rhode-Barbarigos, N. Bel Hadj Ali, S. Adriaenssens, I.F.C. Smith               

% References:   M. Barnes, S. Adriaenssens, M. Krupka M. A novel torsion/bending element for dynamic relaxation modeling. Computers and Structures, 19(1):60-67, 2013.
%               N. Bel Hadj Ali, L. Rhode-Barbarigos, I.F.C. Smith. Analysis of clustered tensegrity structures using a modified dynamic relaxation algorithm. International Journal of Solids and Structures, 48(5):637-647, 2011.
%               M. Barnes. Form finding and analysis of tension structures by dynamic relaxation. International Journal of Space Structures, 14(2):89-104, 1999.

% IMPORTANT NOTICES:    
%               This program is distributed in the hope that it ill be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. The intellectual property rests with the authors and no use of this program 
%               can be made without prior consent from one of the authors.

% ASSUMPTIONS:	1. nonlinear elastic analysis		
%               2. pin jointed structure with perfect hinges and pulleys (no friction)
%               3. self-weight applied to nodes as point load
%               4. bending stiffness constant about any axis
%               5. supported element types: tension/compression, tension only, springs, bending

%__________________________________________________________________________

function [Link,X0,Type,Sup,Clusters,kspring,A,Young,Gamma,lgo,P,F,I,Curve0,Bending] = Input1


%--------------------------------------------------------------------------

% Node connectivity (node to node)
% Element number = line of the matrix Link
% Connectivity = values of the matrix in the same line

Link=[
1	2
3	2
3	4
1	5
2	6
3	7
2	5
3	6
4	7
8	9
10	9
10	4
8	11
9	12
10	7
9	11
10	12
13	14
13	16
14	16
14	15
14	17
15	17
15	4
15	7
18	19
18	21
19	21
19	20
19	22
20	22
20	4
20	7
23	24
23	26
24	26
24	25
24	27
25	27
25	4
25	7
28	29
28	31
29	31
29	30
29	32
30	32
30	4
30	7
5	11
11	16
16	21
21	26
26	31
31	5
6	12
12	17
17	22
22	27
27	32
32	6
];

nbLinks=size(Link,1);


%--------------------------------------------------------------------------

% Node coordinates (x,y,z;) 
% Line i of this matrix correspond to coordinates of the node i 

X0 =    1.0e+03 * [
6	0	1.15
4	0	2.3
2	0	3
0	0	3.25
4	0	0
2	0	1.6
0	0	2.65		
3	5.1962	1.15
2	3.4641	2.3
1	1.7321	3
2	3.4641	0
1	1.7321	1.6	
-3	5.1962	1.15
-2	3.4641	2.3
-1	1.7321	3
-2	3.4641	0
-1	1.7321	1.6
-6	0	1.15
-4	0	2.3
-2	0	3
-4	0	0
-2	0	1.6
-3	-5.1962	1.15
-2	-3.4641	2.3
-1	-1.7321	3
-2	-3.4641	0
-1	-1.7321	1.6
3	-5.1962	1.15
2	-3.4641	2.3
1	-1.7321	3
2	-3.4641	0
1	-1.7321	1.6
];

%--------------------------------------------------------------------------

% Type defines the element nature 
% 0=tension/compression, 1=tension, 2=spring, 3=bending
% Note: the first number defines the total number of elements (based on the topology studied)

Type = ones(nbLinks,1);     % defining all elements as cables

Struts = [7,8,9,16,17,20,23,28,31,36,39,44,47]; % grouping strut elements

Type(Struts,1)=0;           % defining strut elements

%--------------------------------------------------------------------------

% Support conditions
% For each line: the node number, for each translation (x,y,z): 1 if blocked 0 if not.

Sup = [ 
1	1	1	1
8	1	1	1
13	1	1	1
18	1	1	1
23	1	1	1
28	1	1	1
];
    
%--------------------------------------------------------------------------

% Clustering cables 
% Note: the first number defines the total number of elements 

Clusters=zeros(nbLinks,1);   
Clusters(1:nbLinks)=1:nbLinks;

%--------------------------------------------------------------------------

% Spring details
% link number = line of the matrix

% if springs are used: definition of spring rigidity
kspring = zeros(nbLinks,1); 

%--------------------------------------------------------------------------

% Cross-section area of elements 
% link number = line of the matrix

A = zeros(nbLinks,1);

A(1:nbLinks,1)=78.5; %cm^2

A([9],1)=12.5*12.5; % cm^2
A([8,17,23,31,39,47],1)=15*15; % cm^2
A([9,16,20,28,36,44],1)=27.5*27.5; % cm^2

%--------------------------------------------------------------------------

% Young modulus of elements
% link number = line of the matrix

Young = zeros(nbLinks,1);

Young(1:nbLinks,1)=20000; %200,000 MPa
Young(Struts,1)=20000; %200,000 MPa

%--------------------------------------------------------------------------

% Specific weight  
% link number = line of the matrix

Gamma = zeros(nbLinks,1);
%Gamma(1:nbLinks,1)=0.00008; %kN/cm^3
%Gamma(Struts,1)=0.00008; %kN/cm^3

%--------------------------------------------------------------------------

% Initial length for elements 
% link number = line of the matrix

% Note: if initial length is set to zero than the geometrical length is 
%       considered based on the nodal coordinated provided

lgo = zeros(nbLinks,1);

prestress = 0.999;

lgo = 1.0e+03 * prestress *[
    2.3071
    2.1190
    2.0156
    2.3071
    2.1190
    2.0304
    2.3000
    1.4000
    0.6000
    2.3071
    2.1189
    2.0156
    2.3071
    2.1189
    2.0304
    2.3000
    1.4000
    2.3071
    2.3071
    2.3000
    2.1189
    2.1189
    1.4000
    2.0156
    2.0304
    2.3071
    2.3071
    2.3000
    2.1190
    2.1190
    1.4000
    2.0156
    2.0304
    2.3071
    2.3071
    2.3000
    2.1189
    2.1189
    1.4000
    2.0156
    2.0304
    2.3071
    2.3071
    2.3000
    2.1189
    2.1189
    1.4000
    2.0156
    2.0304
    4.0000
    4.0000
    4.0000
    4.0000
    4.0000
    4.0000
    2.0000
    2.0000
    2.0000
    2.0000
    2.0000
    2.0000];


%prestress = 0.98;
%tops = [3,12,24,32,40,48];
%lgo(tops,1) = prestress*lgo(tops,1);


lgo(Struts,1)=0;

%--------------------------------------------------------------------------

% Element internal forces 
% link number = line of the matrix

P = zeros(nbLinks,1);

%--------------------------------------------------------------------------

% External load applied to nodes of the structure
% for each node we define (Fx, Fy, Fz;)
% node number = line of the matrix

F = zeros(32,3);

% In kN
F=0.5*[
0	0	0
0	0	-690 % 2 apply load
0	0   -350 % 3 apply load
0	0	-260 % 4 apply load
0	0	0
0	0	0
0	0	0
0	0	0
0	0	-690 % 9 apply load
0	0	-350 % 10 apply load
0	0	0
0	0	0
0	0	0
0	0	-690 % 14 apply load
0	0	-350 % 15 apply load
0	0	0
0	0	0
0	0	0
0	0	-690 % 19 apply load
0	0	-350 % 20 apply load
0	0	0
0	0	0
0	0	0
0	0	-690 % 24 apply load
0	0	-350 % 25 apply load
0	0	0
0	0	0
0	0	0
0	0	-690 % 29 apply load
0	0	-350 % 30 apply load
0	0	0
0	0	0
];

%--------------------------------------------------------------------------

% Second moment of inertia of bending elements 
% link number = line of the matrix

I = zeros(nbLinks,1);

%--------------------------------------------------------------------------

% Initial curvature of element
% link number = line of the matrix

Curve0 = zeros(nbLinks,1);

%--------------------------------------------------------------------------

% Bending-element topology
% Element number = line of the matrix Link

% Note: The links should be ordered in pairs that share a common node.
%       If a bending element has less links (axial elements) compared to 
%       another one, use 0 to complete the line
%       Links in the bending matrix must be defined as Type 3

Bending = [0 0];    % Default values for cases where there is no bending

