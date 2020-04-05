
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

% VARIABLE DESCRIPTION OF THE PACKAGE
%               Link:		matrix of links 
%               X0:         matrix of initial node coordinates
%               Xf:         matrix of current node coordinates
%               Bound:		vector of boundary conditions 
%               Young:		Young modulus of elements (links)  
%               A:          section of elements (links)
%               Lc: 		current length of elements (links) 
%               L0: 		initial length of elements (links) 
%               S0: 		initial self-stress of cables
%               Ff: 		current internal force 
%               Type:       0=tension/compression, 1=tension, 2=spring, 3=bending/torsion
%               Fe: 		external forces 
%               Clusters:   matrix defining groups of cables   


%--------------------------------------------------------------------------
%                    Main call of the DR algorithm
%--------------------------------------------------------------------------

clear *

disp('Analysis in progress...');

Deadload = 1;       % Define coefficient for dead load

[Link,X0,Type,Bound,Clusters,k,A,Young,Gamma,L0,S0,Fe,I,Curve0,Bending]= feval(str2func('Input1'));    % reading input file
Linit=L0;                                                                                             % storing initial link lenghts

% Static analysis by dynamic relaxation
[Xf,Tr,Lf,Rf,BMoment]= DRroutine(Link,X0,Type,Bound,Clusters,k,A,Young,Gamma,Linit,L0,S0,Fe,Deadload,I,Curve0,Bending);

% Displaying nodal displacements   
disp('Nodal Displacements');
disp(Xf-X0);

% Displaying element lenghts 
disp('Element Lengths');
disp(Lf);

% Displaying intenal forces 
disp('Internal Forces');
disp(Tr);

% Displaying bending moments 
disp('Bending Moments');
disp(BMoment);

% Displaying boundary reactions 
disp('Boundary Reactions');
disp(Rf);

%--------------------------------------------------------------------------
%                    End or the main call
%--------------------------------------------------------------------------




%--------------------------------------------------------------------------
%                Plot the structure s initial configuration
%--------------------------------------------------------------------------

coef = 1;              			     			% amplification coefficient 
color = [0.7 0.7 0.7];                          % grey color definition
style = '--';                                   
LinkLabel = 0;                                  % link label: 0 deactive, 1 activate
NodeLabel = 1;                                  % node label: 0 deactive, 1 activate

Net = size(Link,1);           
XYZ = X0(Link(1,:),:);
line(XYZ(1,1),XYZ(1,2),XYZ(1,3),'color','cyan', 'LineWidth',5, 'LineStyle',style);
hold on;
line(XYZ(1,1),XYZ(1,2),XYZ(1,3),'color','blue', 'LineWidth',5, 'LineStyle',style); 
line(XYZ(1,1),XYZ(1,2),XYZ(1,3),'color','red', 'LineWidth',5, 'LineStyle',style);

for ie = 1:Net						
            XYZ = X0(Link(ie,:),:);				
            X = [XYZ(:,1)];					 
            Y = [XYZ(:,2)];					 
            Z = [XYZ(:,3)];					
            line(X,Y,Z,'color',color, 'LineStyle',style);   	   

            if(LinkLabel)					
                x =  mean(XYZ(:,1));		
                y =  mean(XYZ(:,2));       
                z =  mean(XYZ(:,3));        
                text(x,y,z,num2str(ie),'color','b')		
            end;
end;

if(NodeLabel)						 
    Np = size(X0,1);				
    
    for i=1:Np
        text(X0(i,1),X0(i,2),X0(i,3),num2str(i),'color','m')		
    end;

end;

hold on;  


%--------------------------------------------------------------------------
%                Plot the structure s final configuration
%--------------------------------------------------------------------------

color = 'k';                                % black color definition
style = '-';                                
LinkLabel = 0;                              % link label: 0 deactive, 1 activate
NodeLabel = 1;                              % node label: 0 deactive, 1 activate

Net = size(Link,1);					

for ie = 1:Net						
            XYZ = Xf(Link(ie,:),:);				
            X = (XYZ(:,1));				
            Y = (XYZ(:,2));				
            Z = (XYZ(:,3));				

            % struts
            if Type(ie)==0
                line(X,Y,Z,'MarkerFaceColor',[0 0 0],...
                'MarkerEdgeColor',[0 0 0],...
                'Marker','o',...
                'LineWidth',5,...
                'Color',[0.3137 0.3137 0.3137]);
            elseif Type(ie)==3
                line(X,Y,Z,'MarkerFaceColor',[0 0 0],...
                'MarkerEdgeColor',[0 0 0],...
                'Marker','o',...
                'LineWidth',5,...
                'Color',[0.3137 0.3137 0.3137]);
            else
            % cables
                line(X,Y,Z,'color',color, 'LineWidth',1, 'LineStyle',style);
            end;
            
            if(LinkLabel)					
                x =  mean(XYZ(:,1));			
                y =  mean(XYZ(:,2));          
                z =  mean(XYZ(:,3));            
                text(x,y,z,num2str(ie),'color','b','FontName','Times New Roman','FontSize',20)		
            end;
end;

if(NodeLabel)					
    Np = size(Xf,1);			
    
    for i=1:Np
    	text(Xf(i,1),Xf(i,2),Xf(i,3),num2str(i),'color','k','FontName','Times New Roman','FontSize',20)	
    end;
    
end;

axis equal;                                    
xlabel('x axis (cm)','FontName','Times New Roman','FontSize',14);
ylabel('y axis (cm)','FontName','Times New Roman','FontSize',14);
zlabel('z axis (cm)','FontName','Times New Roman','FontSize',14);


%--------------------------------------------------------------------------
%                Creating a DXF file from MatLab
%--------------------------------------------------------------------------

FID = dxf_open('DXFpoints.dxf');
FID = dxf_set(FID,'Color',[1 1 0],'Layer',20);

x=Xf(:,1);
y=Xf(:,2);
z=Xf(:,3);

% Produce a cloud of points.
dxf_point(FID,x,y,z);

% Close DXF file.
dxf_close(FID);

%---------------------------------------------------------------------

% Open DXF File.
FID = dxf_open('DXFsurface.dxf');
FID = dxf_set(FID,'Color',[1 0 0],'Layer',10);

x=Xf(:,1);
y=Xf(:,2);
z=Xf(:,3);

dx=100;
dy=100;

x_edge=[floor(min(x)):dx:ceil(max(x))];
y_edge=[floor(min(y)):dy:ceil(max(y))];
[X,Y]=meshgrid(x_edge,y_edge);

F = TriScatteredInterp(x,y,z);
Z= F(X,Y);

%fvc = surf2patch(X,Y,Z,'triangles');
fvc = surf2patch(X,Y,Z);

% fvc is a structure containing vertices and faces. We use these matrices
% to create a polymesh.
dxf_polymesh(FID, fvc.vertices, fvc.faces);

dxf_close(FID);
