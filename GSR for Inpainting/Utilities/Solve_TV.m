function xe=Solve_TV(y,lambda,IterNums)
% Usage:
%
% Chambolle projection's algorithm:
%
%
% This algorithm solves the following problem: 
%
%    arg min_x = 0.5*|| y - x ||_2^2 + lambda*TV(x)
%
% ======================
% Parameters:
%
% 'y'       : noisy image 
%  
% 'lambda'  : lambda parameter according to (1)
%
% 'IterNums'   : Number of iterations
%
% =======================
%

%Inicialize with zeros if inicialzeros == 1
inicialzeros=1; 
tau=0.249;

[uy,ux]=size(y);

% Direct and transpose operators that compute
% first order horizontal and vertical differences
dh = @(x) conv2c(x,[1 -1 0]);
dv = @(x) conv2c(x,[1 -1 0]');
dht = @(x) conv2c(x,[0 -1 1]);
dvt = @(x) conv2c(x,[0 -1 1]');

%  Z = [Z1 ; Z2];
if inicialzeros
    Z1 = zeros(uy,ux);
    Z2 = zeros(uy,ux);
else
    Z1=dh(y);
    Z2=dv(y);
end

%
% Chambolle's algorithm
% 
% for i=1:niter
%     x=dht(Z1)+dvt(Z2)-y;
%     W=sqrt(dh(x).^2+dv(x).^2);
%     
%     Z1=Z1-tau*dh(x);
%     Z2=Z2-tau*dv(x);
%     Z1=Z1./(1+2/lambda*tau*W);
%     Z2=Z2./(1+2/lambda*tau*W);
% end


for i=1:IterNums
    x=dht(Z1)+dvt(Z2)-y;
    W=1./(1+2/lambda*tau*sqrt(dh(x).^2+dv(x).^2));
    
    Z1=(Z1-tau*dh(x)).*W;
    Z2=(Z2-tau*dv(x)).*W;
end
xe=y-dht(Z1)-dvt(Z2);



%================================================
%
% A U X I L I A R   F U N C T I O N S
%
%

function y = conv2c(x,h)
% Circular 2D convolution
x=wraparound(x,h);
y=conv2(x,h,'valid');


function y = wraparound(x, m)
% Extend x so as to wrap around on both axes, sufficient to allow a
% "valid" convolution with m to return the cyclical convolution.
% We assume mask origin near centre of mask for compatibility with
% "same" option.
[mx, nx] = size(x);
[mm, nm] = size(m);
if mm > mx | nm > nx
    error('Mask does not fit inside array')
end

mo = floor((1+mm)/2); no = floor((1+nm)/2);  % reflected mask origin
ml = mo-1;            nl = no-1;             % mask left/above origin
mr = mm-mo;           nr = nm-no;            % mask right/below origin
me = mx-ml+1;         ne = nx-nl+1;          % reflected margin in input
mt = mx+ml;           nt = nx+nl;            % top of image in output
my = mx+mm-1;         ny = nx+nm-1;          % output size

y = zeros(my, ny);
y(mo:mt, no:nt) = x;      % central region
if ml > 0
    y(1:ml, no:nt) = x(me:mx, :);                   % top side
    if nl > 0
        y(1:ml, 1:nl) = x(me:mx, ne:nx);            % top left corner
    end
    if nr > 0
        y(1:ml, nt+1:ny) = x(me:mx, 1:nr);          % top right corner
    end
end
if mr > 0
    y(mt+1:my, no:nt) = x(1:mr, :);                 % bottom side
    if nl > 0
        y(mt+1:my, 1:nl) = x(1:mr, ne:nx);          % bottom left corner
    end
    if nr > 0
        y(mt+1:my, nt+1:ny) = x(1:mr, 1:nr);        % bottom right corner
    end
end
if nl > 0
    y(mo:mt, 1:nl) = x(:, ne:nx);                   % left side
end
if nr > 0
    y(mo:mt, nt+1:ny) = x(:, 1:nr);                 % right side
end
