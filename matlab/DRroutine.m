
% LOCAL VARIABLES
%           X:          initial coordinate matrix
%           nblink:		number of links
%           nbnode:     number of nodes
%           nbBound;	number of boundary conditions
%           BoundMass;	boundary condition mass
%           DeltaT:     time interval
%           na:         node A
%           nb:         node B
%           w:          dead load for a link
%           M:          nodal mass matrix
%           V:          nodal velocity matrix
%           maxCycle:	max number of cycles
%           maxReset: 	max number of resets
%           KE:         kinetic energy stored
%           KEdt:		kinetic energy current
%           nbCycle:	number of cycles
%           nbReset:	number of resets
%           d:          displacement (temporary variable)
%           kene:		kinetic energy (temporary variable)
%           Reac:       boundary reactions

%__________________________________________________________________________________________________________________________________________________________________________________________

function [X,T,L,Reac,BMoment]= DRroutine(Link,X0,Type,Bound,CL,kspring,A,Young,Gamma,Linit,L0,P,Fe,Coef,I,Curve0,Bending)

X=X0;                       
nblink=size(Link,1);		
nbnode=size(X0,1);			
V=zeros(nbnode,3); 			
nbBound=size(Bound,1);		
BoundMass=1.0e100;			
DeltaT=0.005;				

% Computation of initial link lengths
	
for i=1:nblink                 
    if L0(i)==0                 
        na=Link(i,1);		
        nb=Link(i,2);		
        d=0;
        c=0;
        for j=1:3				
            d=X(nb,j)-X(na,j);	
            c = c + d*d;		
        end;
        L0(i)=sqrt(c);		
    end;
end;
% disp('Initial length: ');
% disp(L0);

% Computation of clustering properties for continuous cables
	
nbclusters = max(CL(:,1));
S = zeros(nbclusters,nblink);
for i=1:nblink
    S(CL(i,1),i)=1;
end;
pr = inv(S*S');
YoungC = pr*S*Young;
AC = pr*S*A;
L0C = S*L0;
PC = pr*S*P;

% Dead load estimation and addition to external loads

for i=1:nblink									 
	na=Link(i,1);				
	nb=Link(i,2);			
	w = (Coef*L0(i)*A(i)*Gamma(i))/2;			
	Fe(na,3) = Fe(na,3)-w;				
	Fe(nb,3) = Fe(nb,3)-w;				

end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
[R,L,T] = DrResiduals(Fe,Link,Type,X,YoungC,kspring,AC,Linit,L0C,PC,S);
% [R,L,T,Rcurv,BMoment] = DrBending(R,L,T,Link,Type,X,Young,I,Curve0,Bending);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

% Attributing large masses to boundary nodes

M=zeros(nbnode,3);				
for i=1:nbBound					
	numnode=Bound(i,1);						
    for j=2:4				
        if Bound(i,j)==1	
			M(numnode,j-1)=BoundMass;	
        end;        
    end;	
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
[M] = DrMasses(M,Link,Type,X,Young,A,L,T,DeltaT,kspring,I);	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 




%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%                   DYNAMIC RELAXATION: MAIN LOOP
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

maxCycle=99999;				% number of cycles
maxReset=10000;				% number of resets
nbCycle=0;					% number of cycles
nbReset=0;					% number of resets
KE=0;                       % kinetic energy set to zero
conv=0;                     % convergence parameter

while nbCycle<maxCycle && nbReset<maxReset && conv~=1	
    
	nbCycle=nbCycle+1;									
    
	% velocity computation I
	for i=1:nbnode										
		for j=1:3										
			if M(i,j)<BoundMass && M(i,j)~=0 			
				V(i,j)=V(i,j)+(DeltaT*R(i,j)/M(i,j));	% velocity = velocity + (TimeInterval / Mass) * ResidualForce
            else
                V(i,j)=0;								% if a (boundary node) or (mass zero) than V=0
			end;
		d = DeltaT*V(i,j);								% displacement computation
		X(i,j)= X(i,j)+d;								% nodal coordinate = nodal coordinate + displacement	
		end;
	end;
    
    % kinetic energy calculation
	kene=0;                                             
    	for i=1:nbnode									
		for j=1:3										
			kene=kene+((V(i,j)*V(i,j)*M(i,j))/2);		% kinetic energy = 0.5 * mass * velocity^2
		end;
	end;
	KEdt=kene;											

    % plotting convergence      
        %disp(KEdt);
        %plot(nbCycle, KEdt,'-*k');
        %xlabel('Cycle Number', 'FontSize', 12);
        %ylabel('Kinetic Energy', 'FontSize', 12);
        %set(gca,'FontSize', 12);
        %hold on;
        %grid on;
        %drawnow;    
    
	% kinetic damping computation
	if KEdt<=KE          								% if (current kinetic energy) < (previous kinetic)	
		
		for i=1:nbnode									
			for j=1:3									
				if M(i,j)<BoundMass && M(i,j)~=0 		
					X(i,j)=X(i,j)-(1.5*DeltaT*V(i,j))+(0.5*DeltaT*DeltaT*R(i,j)/M(i,j));    % coordinate = coordinate  - (1.5 * TimeInterval * Velocity) + [0.25 * TimeInterval^2 * (ResidualForce / Mass)]
				end;                                                                        																			
			end;                                                                                                                        
		end;            
           
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        [R,L,T] = DrResiduals(Fe,Link,Type,X,YoungC,kspring,AC,Linit,L0C,PC,S);
%         [R,L,T,Rcurv,BMoment] = DrBending(R,L,T,Link,Type,X,Young,I,Curve0,Bending);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
                
		% velocity computation II
		for i=1:nbnode														
			for j=1:3									
				if M(i,j)<BoundMass && M(i,j)~=0		
					V(i,j)=(DeltaT*R(i,j))/(2*M(i,j));	% velocity = (TimeInterval * ResidualForce) / (2 * Mass)
                else
                    V(i,j)=0;							% if a (boundary node) or (mass zero) than V=0
                    R(i,j)=0;
				end;
			end;
		end;
        NormRes=norm(R);
		KEdt=0;                                         % setting current kinetic energy to zero
		
		% convergence on kinetic energy peaks
		nbReset=nbReset+1;								
        if NormRes<0.00001
            conv =1;
        end;
        
	end; 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    [R,L,T] = DrResiduals(Fe,Link,Type,X,YoungC,kspring,AC,Linit,L0C,PC,S);
%     [R,L,T,Rcurv,BMoment] = DrBending(R,L,T,Link,Type,X,Young,I,Curve0,Bending);                
	[M] = DrMasses(M,Link,Type,X,Young,A,L,T,DeltaT,kspring,I);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
	
    KE = KEdt;	
    
end;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[R,L,T] = DrResiduals(Fe,Link,Type,X,YoungC,kspring,AC,Linit,L0C,PC,S);
[R,L,T,Rcurv,BMoment] = DrBending(R,L,T,Link,Type,X,Young,I,Curve0,Bending);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%                       END OF THE MAIN LOOP
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------




%--------------------------------------------------------------------------
%                  Calculation of the boundary reactions
%--------------------------------------------------------------------------

Reac = Bound;
for i=1:nbBound
    n = Bound(i,1);   
    for j=2:4
        Reac(i,j)=Bound(i,j)*R(n,j-1);
    end;
end;


%--------------------------------------------------------------------------
%                  % Residual forces for axial elements 
%--------------------------------------------------------------------------

function [R,L,T] = DrResiduals(Fe,Link,Type,X0,YoungC,k,AC,Linit,L0C,PC,S)

nblink=size(Link,1);	
nbcluster=size(S,1);     
TC=zeros(nbcluster,1);     
L=zeros(nblink,1);		
T=zeros(nblink,1);			
R = Fe;                

for i=1:nblink                         
	na=Link(i,1);			
	nb=Link(i,2);				
	d=0;				
	c=0; 
	for j=1:3				
		d=X0(nb,j)-X0(na,j);		
		c = c + d*d;			
	end;
	L(i,1)=sqrt(c);			
end;

LC = S*L;                        

for i=1:nbcluster
    TC(i,1)=(YoungC(i)*AC(i)/L0C(i))*(LC(i)-L0C(i))+PC(i);		% internal force = (Young modulus * Area) * ( DeltaL / initial length ) + self-stress  
end;

T = S'*TC;                             

for i=1:nblink
	if Type(i)==1 && T(i,1)<0     
		T(i,1)=0;              
	end;
end;

for i=1:nblink
    if (Type(i,1)==2)
        T(i,1)=k(i,1)*(L(i)-Linit(i));
        if T(i,1)<0
            T(i,1)=0;  
        end;
    end;
end;    

for i=1:nblink
	na=Link(i,1);                              
	nb=Link(i,2);                             
	for j=1:3                                  
		r = (T(i)/L(i))*(X0(nb,j)-X0(na,j));	
		R(na,j) = R(na,j)+r;                                
		R(nb,j) = R(nb,j)-r;                                          
	end;
end;

return


%--------------------------------------------------------------------------
%        Function for computing residual forces in bending elements
%--------------------------------------------------------------------------

function [R,L,T,Rcurv,BMoment] = DrBending(R,L,T,Link,Type,X,Young,I,Curve0,Bending)

nbBEND=size(Bending,1);            
nblink=size(Link,1);          
nbnode=size(X,1);               
Rcurv=zeros(nblink,1);
BMoment=zeros(nbnode,1);

for l=1:nbBEND                  
    BENDelement=Bending(l,:);              
    BENDlinks=nonzeros(BENDelement);       
    nbBENDlinks=size(BENDlinks,1);    

    for m=1:nbBENDlinks-1           
        
        if Type(BENDlinks(m))~=3 && Type(BENDlinks(m+1))~=3         
            return;
        end;
        if Type(BENDlinks(m))~=3 || Type(BENDlinks(m+1))~=3        
            disp('Error in link-type definition for bending');
            return;
        end;
        
        if Type(BENDlinks(m))==3 && Type(BENDlinks(m+1))==3        

            na=Link(BENDlinks(m),1);		
            nb=Link(BENDlinks(m),2);		
            nc=Link(BENDlinks(m+1),1);		
            nd=Link(BENDlinks(m+1),2);		         

            if nb==nc
                node1=na;
                node2=nd;
                node3=nb;               
            end;
            if nb==nd
                node1=na;
                node2=nc;
                node3=nb; 
            end;
            if na==nc
                node1=nb;
                node2=nd;
                node3=na;   
            end;
            if na==nd
                node1=nb;
                node2=nc;
                node3=na;   
            end;
            
            if na~=nc && na~=nd && nb~=nc && nb~=nd
                disp('Error in bending connectivity: no common node for links');
                return;
            end;

            d=0;						
            c=0;
            for j=1:3					
                d=X(node1,j)-X(node3,j);
                c = c + d*d;			
            end;
            el2=sqrt(c);				
            d=0;						
            c=0;
            for j=1:3					
                d=X(node2,j)-X(node3,j);
                c = c + d*d;			
            end;
            el1=sqrt(c);				              
            d=0;						
            c=0;
            for j=1:3					
                d=X(node1,j)-X(node2,j);
                c = c + d*d;			
            end;
            el3=sqrt(c);				          
            
            % geometrical calculations for bending moment and shear forces
                       
            cosAlpha1 = (el2*el2+el3*el3-el1*el1) / (2*el2*el3);
            cosAlpha1 = abs(cosAlpha1);
            
                if cosAlpha1>0.9999;
                    cosAlpha1=1;
                end;
                if cosAlpha1<0.0001;
                    cosAlpha1=0;
                end;
            
            Alpha1=acos(cosAlpha1);                             
            height=el2*sin(Alpha1);
            Alpha2=asin(height/el1);                            
            Alpha=Alpha1+Alpha2;                       
            curvature=(2*sin(Alpha))/el3;    
            
            if curvature~=0
                Rcurv(Bending(l,m))=1/curvature;
            end;
            
            Moment = Young(m)*I(m)*(curvature-Curve0(m));  
            SF1 = Moment / el2;                  
            SF2 = Moment / el1;         
            BMoment(node3)=Moment;       
            
            % transformation of the shear forces from local to global components
            
            df1 = el2 / (el3*cos(Alpha1));                      
            df2 = el1 / (el3*cos(Alpha2));    
            ptE1=zeros(1,3);                        
            ptE2=zeros(1,3);
            
            for j=1:3
                ptE1(j) = X(node1,j) + df1*(X(node2,j)-X(node1,j));   
                ptE2(j) = X(node2,j) - df2*(X(node2,j)-X(node1,j));   
            end;

            d=0;						
            c=0;
            for j=1:3
                d=X(node3,j)-ptE1(j);   
                c=c+d*d;
            end;
            cl1=sqrt(c);                
            
                if cl1<0.0001*el3
                    cl1=0.0001*el3;
                end;
            d=0;						
            c=0;
            for j=1:3
                d=X(node3,j)-ptE2(j);   
                c=c+d*d;
            end;
            cl2=sqrt(c);                
            
                if cl2<0.0001*el3
                    cl2=0.0001*el3;
                end;
            
            SF1 = SF1 / cl1;            
            SF2 = SF2 / cl2;                
            
            % distribution of shear forces in residual forces
            
            for j=1:3                                                                       
                R(node1,j) = R(node1,j) + SF1*(X(node3,j)-ptE1(j));                             
                R(node2,j) = R(node2,j) + SF2*(X(node3,j)-ptE2(j));
                R(node3,j) = R(node3,j) - SF1*(X(node3,j)-ptE1(j)) - SF2*(X(node3,j)-ptE2(j));  
            end;    
            
        end;
    end;
end;

return



%--------------------------------------------------------------------------
%                     Function for computing masses
%--------------------------------------------------------------------------

function [M] = DrMasses(M,Link,Type,X0,Young,A,L,T,DeltaT,kspring,I)

nblink=size(Link,1);				
nbnode=size(X0,1);			
BoundMass = 1.0e100;      	
minM = 0.001;					 
DT2=DeltaT*DeltaT;				

% mass reset
for i=1:nbnode			
	for j=1:3						
		if M(i,j)<BoundMass				
            M(i,j)=0;				
		end;
	end;
end;

k = zeros(nblink,1);

for i=1:nblink						
    
	EA = Young(i)*A(i);					
	if Type(i)==1					
		EA = EA + T(i);       
	end;
	k = EA/L(i);					
    
    % for spring elements
    
	if Type(i)==2					
		k = kspring(i);                      
	end;
    
    % for bending elements
    
    if Type(i)==3					
        k = k + (2*Young(i)*I(i))/(L(i)*L(i)*L(i));                   
    end;
    
	na=Link(i,1);				
	nb=Link(i,2);			
	for j=1:3							
		DX= abs(X0(nb,j)-X0(na,j));		
		kX= k*((DX*DX)/(L(i)*L(i)));	
		MX= kX*2*DT2+minM;              	
		M(na,j)= M(na,j)+MX;			
		M(nb,j)= M(nb,j)+MX;			                         
	end;
    
end;

return

