dataset = data;
for i = 1:20287
    predict = label(1,i)*2^0 + label(2,i)*2^1 + label(3,i)*2^2 + label(4,i)*2^3 + label(5,i)*2^4;
    dataset(i,19) = predict;
end