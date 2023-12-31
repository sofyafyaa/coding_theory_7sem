clear all; clc; close all;
load strings

%% 1) Count alphabet probabilities
[X_alphabet, X_probability] = alphabet_probabilities(X);
[Y_alphabet, Y_probability] = alphabet_probabilities(Y);

%% 2) Count entropy of X & Y
H_X = entropy(X);
H_Y = entropy(Y);

%% 3) Count condition value entropy
H_cond_xy = cond_val_entropy(X, Y, 'c');

%% 4.1) Count condition entropy
H_XY_cond = cond_entropy(X, Y);
H_YX_cond = cond_entropy(Y, X);

%% 4.2) Count joint entropy
H_XY_joint = joint_entropy(X, Y);
H_YX_joint = joint_entropy(Y, X);

%% 5) Check model

I_XY = H_X - H_XY_cond;
I_YX = H_Y - H_YX_cond;

R_X_th = 1 - H_X / length(X_alphabet);
R_Y_th = 1 - H_Y / length(Y_alphabet);

if (H_XY_cond <= H_X) && (H_X <= log2(length(X)))
    disp('1) H(X|Y) <= H(X) <= log2(L)')
end

if (H_YX_cond <= H_Y) && (H_Y <= log2(length(Y)))
    disp('2) H(Y|X) <= H(Y) <= log2(L)')
end

if (I_YX == I_XY)
    disp('3) I(X, Y) == I(Y, X)')
end

if (H_XY_joint == H_X + H_YX_cond)
    disp('4) H(X, Y) = H(X) + X(Y|X)')
end

if (H_YX_joint == H_Y + H_XY_cond)
    disp('5) H(X, Y) = H(Y) + X(X|Y)')
end

%% 6) L-entropy

% Count conditional L-entropy
L = 5;
N = length(X)-1;

samples_idx = (1:L) + (0:N-L).';
samples_mtrx = X(samples_idx);
samples_mtrx = string(samples_mtrx);
samples_alphabet = unique(string(samples_mtrx));

p_samples = sum(samples_mtrx==samples_alphabet.', 1) ...
            / length(samples_mtrx);

samples_UL = X(samples_idx(:, L) + 1);
samples_UL = string(samples_UL(:));

HL_cond = 0;
for i = 1:length(X_alphabet)
    
    UL_idx = samples_UL==string(X_alphabet(i));

    mtrx_itter = samples_mtrx(UL_idx);

    idx_p = mtrx_itter==string(samples_alphabet(:)).';    
    p_joint = sum(idx_p, 1) / length(samples_mtrx);

    p_cond = p_joint ./ p_samples;
    p_cond(p_cond==0) = [];

    HL_cond = HL_cond - sum(p_cond .* log2(p_cond));
end

% Count mean L-entropy
K = L+1;

samples_idx_L = (1:K) + (0:N-K).';
samples_mtrx_L = X(samples_idx_L);
samples_mtrx_L = string(samples_mtrx_L);
samples_alphabet_L = unique(string(samples_mtrx_L));

p_UL = sum(samples_mtrx_L==samples_alphabet_L.', 1) ...
            / length(samples_mtrx_L);

HL_mean = -sum(p_UL .* log2(p_UL)) / L;

H_max = log2(length(samples_alphabet));

R_X = 1 - (HL_cond/H_max);

%% 6.1 Simulations for different L
clear all; 
load strings;

disp('Dependence of H_l on an L')

[X_alphabet, X_probability] = alphabet_probabilities(X);

L = 2 : 20;
N = length(X)-1;
HL_cond = zeros(1, length(L));
HL_mean = zeros(1, length(L));
H_max = zeros(1, length(L));

for ii = 1 : length(L)
    display([num2str(ii) ,') for L = ', num2str(L(ii))])
    samples_idx = (1:L(ii)) + (0:N-L(ii)).';
    samples_mtrx = string(X(samples_idx));
    samples_alphabet = unique(string(samples_mtrx));

    p_samples = sum(samples_mtrx==samples_alphabet.', 1) ...
            / length(samples_mtrx);

    samples_UL = X(samples_idx(:, L(ii)) + 1);
    samples_UL = string(samples_UL(:));
    
    HL_cond(ii) = 0;
    for jj = 1:length(X_alphabet)
        
        UL_idx = samples_UL==string(X_alphabet(jj));
        mtrx_itter = samples_mtrx(UL_idx);
    
        idx_p = mtrx_itter==string(samples_alphabet(:)).';    
        p_joint = sum(idx_p, 1) / length(samples_mtrx);
    
        p_cond = p_joint ./ p_samples;
        p_cond(p_cond==0) = [];
    
        HL_cond(ii) = HL_cond(ii) - sum(p_cond .* log2(p_cond));
    end
    display(['Conditional L_entropy H_L_cond = ', num2str(HL_cond(ii))])

    K = L(ii)+1;
    samples_idx_L = (1:K) + (0:N-K).';
    samples_mtrx_L = X(samples_idx_L);
    samples_mtrx_L = string(samples_mtrx_L);
    samples_alphabet_L = unique(string(samples_mtrx_L));
    
    p_UL = sum(samples_mtrx_L==samples_alphabet_L.', 1) ...
                / length(samples_mtrx_L);
    
    HL_mean(ii) = -sum(p_UL .* log2(p_UL)) / L(ii);
    display(['Mean L_entropy H_L_mean = ', num2str(HL_mean(ii))])

    H_max(ii) = log2(length(samples_alphabet));
    display(['Zero Entropy = ', num2str(H_max(ii))])
end

figure
plot(L, HL_cond);
title('H_L cond(L)');
xlabel('L, symb');

figure
plot(L, HL_mean, 'DisplayName', 'H_L mean');

hold on;
plot(L, H_max, 'DisplayName', 'H max');
hold off;

legend

title('H_L mean(L) & H max(L) comparison');
xlabel('L, symb');


