
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

function [Link,X0,Type,Sup,Clusters,kspring,A,Young,Gamma,lgo,P,F,I,Curve0,Bending] = Input2


%--------------------------------------------------------------------------

% Node connectivity (node to node)
% Element number = line of the matrix Link
% Connectivity = values of the matrix in the same line

Link=[
1	2
2	3
3	4
4	5
5	6
6	7
7	8
8	9
9	10
10  11
12	13
13	14
14	15
15	16
16	17
17	18
18	19
19	20
20  21
21	22
23	24
24	25
25	26
26	27
27	28
28	29
29	30
30  31
31	32
32	33
34	35
35	36
36	37
37	38
38	39
39	40
40  41
41	42
42	43
43	44
45	46
46	47
47	48
48	49
49	50
50  51
51	52
52	53
53	54
54	55
56	57
57	58
58	59
59	60
60  61
61	62
62	63
63	64
64	65
65	66
67	68
68	69
69	70
70  71
71	72
72	73
73	74
74	75
75	76
76	77
78	79
79	80
80  81
81	82
82	83
83	84
84	85
85	86
86	87
87	88
89	90
90  91
91	92
92	93
93	94
94	95
95	96
96	97
97	98
98	99
100 101
101 102
102 103
103 104
104 105
105 106
106 107
107 108
108 109
109 110
111 112
112 113
113 114
114 115
115 116
116 117
117 118
118 119
119 120
120 121

1	12
12	23
23	34
34	45
45	56
56	67
67	78
78	89
89	100
100	111
2	13
13	24
24	35
35	46
46	57
57	68
68	79
79	90
90	101
101	112
3	14
14	25
25	36
36	47
47	58
58	69
69	80
80	91
91	102
102	113
4	15
15	26
26	37
37	48
48	59
59	70
70	81
81	92
92	103
103	114
5	16
16	27
27	38
38	49
49	60
60	71
71	82
82	93
93	104
104	115
6	17
17	28
28	39
39	50
50	61
61	72
72	83
83	94
94	105
105	116
7	18
18	29
29	40
40	51
51	62
62	73
73	84
84	95
95	106
106	117
8	19
19	30
30	41
41	52
52	63
63	74
74	85
85	96
96	107
107	118
9	20
20	31
31	42
42	53
53	64
64	75
75	86
86	97
97	108
108	119
10	21
21	32
32	43
43	54
54	65
65	76
76	87
87	98
98	109
109	120
11	22
22	33
33	44
44	55
55	66
66	77
77	88
88	99
99	110
110	121
];

nbLinks=size(Link,1);

%--------------------------------------------------------------------------

% Node coordinates (x,y,z;) 
% Line i of this matrix correspond to coordinates of the node i 

X0 = 100*[ 
0	0	0
1	0	0
2	0	0
3	0	0
4	0	0
5	0	0
6	0	0
7	0	0
8	0	0
9	0	0
10  0   0
0	1	0
1	1	0
2	1	0
3	1	0
4	1	0
5	1	0
6	1	0
7	1	0
8	1	0
9	1	0
10  1   0
0	2	0
1	2	0
2	2	0
3	2	0
4	2	0
5	2	0
6	2	0
7	2	0
8	2	0
9	2	0
10  2   0
0	3	0
1	3	0
2	3	0
3	3	0
4	3	0
5	3	0
6	3	0
7	3	0
8	3	0
9	3	0
10  3   0
0	4	0
1	4	0
2	4	0
3	4	0
4	4	0
5	4	0
6	4	0
7	4	0
8	4	0
9	4	0
10  4   0
0	5	0
1	5	0
2	5	0
3	5	0
4	5	0
5	5	0
6	5	0
7	5	0
8	5	0
9	5	0
10  5   0
0	6	0
1	6	0
2	6	0
3	6	0
4	6	0
5	6	0
6	6	0
7	6	0
8	6	0
9	6	0
10  6   0
0	7	0
1	7	0
2	7	0
3	7	0
4	7	0
5	7	0
6	7	0
7	7	0
8	7	0
9	7	0
10  7   0
0	8	0
1	8	0
2	8	0
3	8	0
4	8	0
5	8	0
6	8	0
7	8	0
8	8	0
9	8	0
10  8   0
0	9	0
1	9	0
2	9	0
3	9	0
4	9	0
5	9	0
6	9	0
7	9	0
8	9	0
9	9	0
10  9   0
0	10	0
1	10	0
2	10	0
3	10	0
4	10	0
5	10	0
6	10	0
7	10	0
8	10	0
9	10	0
10  10  0
];

%--------------------------------------------------------------------------

% Type defines the element nature 
% 0=tension/compression, 1=tension, 2=spring, 3=bending
% Note: the first number defines the total number of elements (based on the topology studied)

Type = ones(nbLinks,1);     % defining all elements as cables

%--------------------------------------------------------------------------

% Support conditions
% For each line: the node number, for each translation (x,y,z): 1 if blocked 0 if not.

Sup = [ 
1	1	1	1
11	1	1	1
111	1	1	1
121	1	1	1
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

A(1:nbLinks,1)=100;

%--------------------------------------------------------------------------

% Young modulus of elements
% link number = line of the matrix

Young = zeros(nbLinks,1);

Young(1:nbLinks,1)=10;

%--------------------------------------------------------------------------

% Specific weight  
% link number = line of the matrix

Gamma = zeros(nbLinks,1);

%--------------------------------------------------------------------------

% Initial length for elements 
% link number = line of the matrix

% Note: if initial length is set to zero than the geometrical length is 
%       considered based on the nodal coordinated provided

lgo = zeros(nbLinks,1);

prestress = 1.0;

lgo(1:nbLinks,1) = prestress* 100;

%--------------------------------------------------------------------------

% Element internal forces 
% link number = line of the matrix

P = zeros(nbLinks,1);

%--------------------------------------------------------------------------

% External load applied to nodes of the structure
% for each node we define (Fx, Fy, Fz;)
% node number = line of the matrix

F = zeros(121,3);

F = 10*[
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
0	0	-1
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
       

