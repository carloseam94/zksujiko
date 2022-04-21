pragma circom 2.0.0;

include "./circomlib/comparators.circom";

template Verify62Sujiko (n,c) {  
    // public
    signal input squares[n];
    signal input circles[c];
    signal input edges[c][n];
    // private
    signal input solution[n];

    // verify that the solution comes from provided squares

    // (mul == 0 && diff != 0) || (mul != 0 && diff == 0)
    // (A && !B) || (!A && B)
    // A B    P
    // 1 1    0
    // 1 0    1
    // 0 1    1
    // 0 0    0
    // XOR
    component comparers_diff[n];
    component comparers_mul[n];
    for(var i = 0; i < n; i++) {
        comparers_diff[i] = IsZero();
        comparers_mul[i] = IsZero(); 

        comparers_diff[i].in <== solution[i] - squares[i];
        comparers_mul[i].in <== solution[i] * squares[i];

        1 === comparers_diff[i].out + comparers_mul[i].out;
    }

    // verify that every number in solution is in 1-n range
    component comparers_lower_bound[n];
    component comparers_upper_bound[n];
    component circle_or_upper[n];
    for(var i = 0; i < n; i++) {

        comparers_lower_bound[i] = GreaterEqThan(8);
        comparers_upper_bound[i] = LessEqThan(8);
        
        comparers_lower_bound[i].in[0] <== solution[i];
        comparers_lower_bound[i].in[1] <== 1;
        comparers_upper_bound[i].in[0] <== solution[i];
        comparers_upper_bound[i].in[1] <== n;

        1 === comparers_lower_bound[i].out;
        1 === comparers_upper_bound[i].out;
    }

    // verify that every number is unique
    component comparers[n][n];
    signal comparisson_results_acc[n][n];
    for(var i = 0; i < n; i++) {
        // in position 0 store if the first node is equal to i
        comparers[i][0] = IsEqual();   
        comparers[i][0].in[0] <== solution[0] - 1;
        comparers[i][0].in[1] <== i;
        comparisson_results_acc[i][0] <== comparers[i][0].out;
        for(var j = 1; j < n; j++) {
            // accumulate if this is equal to i with previous iterations
            comparers[i][j] = IsEqual();
            comparers[i][j].in[0] <== solution[j] - 1;
            comparers[i][j].in[1] <== i;
            comparisson_results_acc[i][j] <== comparers[i][j].out + comparisson_results_acc[i][j-1];
        }
        1 === comparisson_results_acc[i][n-1];
    }

    // verify that every sum is equal to their corresponding circle value
    signal sums_acc[c][n];
    for(var i = 0; i < c; i++) {
        sums_acc[i][0] <== solution[0] * edges[i][0];
        for(var j = 1; j < n; j++) {
            sums_acc[i][j] <== solution[j] * edges[i][j] + sums_acc[i][j-1];
        }
        circles[i] === sums_acc[i][n-1];
    }
    
} 

component main {public [squares,circles,edges]} = Verify62Sujiko(6,2);
