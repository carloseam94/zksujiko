pragma circom 2.0.0;

include "./circomlib/comparators.circom";

template VerifySujiko () {  
    // public
    signal input board[9];
    signal input circles[4];
    // private
    signal input solution[9];

    // verify that the solution comes from provided board

    // (mul == 0 && diff != 0) || (mul != 0 && diff == 0)
    // (A && !B) || (!A && B)
    // A B    P
    // 1 1    0
    // 1 0    1
    // 0 1    1
    // 0 0    0
    // XOR
    component comparers_diff[9];
    component comparers_mul[9];
    for(var i = 0; i < 9; i++) {
        comparers_diff[i] = IsZero();
        comparers_mul[i] = IsZero(); 

        comparers_diff[i].in <== solution[i] - board[i];
        comparers_mul[i].in <== solution[i] * board[i];

        1 === comparers_diff[i].out + comparers_mul[i].out;
    }

    // verify that every number is between 1-9 range
    component comparers_lower_bound[9];
    component comparers_upper_bound[9];
    for(var i = 0; i < 9; i++) {
        comparers_lower_bound[i] = GreaterEqThan(8);
        comparers_upper_bound[i] = LessEqThan(8);
        
        comparers_lower_bound[i].in[0] <== solution[i];
        comparers_lower_bound[i].in[1] <== 1;
        comparers_upper_bound[i].in[0] <== solution[i];
        comparers_upper_bound[i].in[1] <== 9;

        1 === comparers_lower_bound[i].out;
        1 === comparers_upper_bound[i].out;
    }

    // verify that every number is unique
    component comparers[9][9];
    for(var i = 0; i < 9; i++) {
        for(var j = 0; j < 9; j++) {
            comparers[i][j] = IsEqual();
            
            comparers[i][j].in[0] <== solution[j] - 1;
            comparers[i][j].in[1] <== i;
        }
        1 === comparers[i][0].out + comparers[i][1].out + comparers[i][2].out + comparers[i][3].out +  
        comparers[i][4].out + comparers[i][5].out + comparers[i][6].out + comparers[i][7].out + comparers[i][8].out;
    }

    // verify that every sum is equal to their corresponding circle value
    circles[0] === solution[0] + solution[1] + solution[3] + solution[4];
    circles[1] === solution[1] + solution[2] + solution[4] + solution[5];
    circles[2] === solution[3] + solution[4] + solution[6] + solution[7];
    circles[3] === solution[4] + solution[5] + solution[7] + solution[8];
} 

component main {public [board,circles]} = VerifySujiko();
