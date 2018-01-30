
%% test empty matrix
empty = [];
r1 = trimNanRows(empty);
assert(isempty(r1));

%% test scalar
scalar1 = 0;
r2 = trimNanRows(scalar1);
assert(isequal(r2, scalar1));

scalar2 = -Inf;
r3 = trimNanRows(scalar2);
assert(isequal(r3, scalar2));

scalar3 = NaN;
r4 = trimNanRows(scalar3);
assert(isempty(r4));

%% test vector
vec1 = [1 2];
r5 = trimNanRows(vec1);
assert(isequal(r5, vec1));

vec2 = [1 2]';
r6 = trimNanRows(vec2);
assert(isequal(r6, vec2));

vec3 = [1 NaN];
r7 = trimNanRows(vec3);
assert(isequaln(r7, vec3));

vec4 = [1 NaN]';
r8 = trimNanRows(vec4);
assert(isequaln(r8, 1));

vec5 = [NaN 1];
r9 = trimNanRows(vec5);
assert(isequaln(r9, vec5));

vec6 = [NaN 1]';
r10 = trimNanRows(vec6);
assert(isequaln(r10, 1));

vec7 = [NaN 1 1 2 3 -Inf Inf NaN 3 2 NaN];
r11 = trimNanRows(vec7);
assert(isequaln(r11, vec7));

vec8 = [NaN 1 1 2 3 -Inf Inf NaN 3 2 NaN]';
r12 = trimNanRows(vec8);
assert(isequaln(r12, [1 1 2 3 -Inf Inf 3 2]'));

vec9 = ceil(rand(10,1));
i = ceil(rand*10);
vec9(i) = NaN;
r13 = trimNanRows(vec9);
vec9b = vec9;
vec9b(i) = [];
assert(isequal(r13, vec9b));

%% test matrix
mat1 = [1 2 2 1];
