//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );

/*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }
    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-add-failed");
    }
    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success,"pairing-mul-failed");
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length,"pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-opcode-failed");
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Sujiko62Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            9288066190072768942300937753247444114483678618875324683191239159507573327504,
            10846571818565278159925593176392645540473604489943691145121464152111970064658
        );

        vk.beta2 = Pairing.G2Point(
            [13408089221025721183201626334353665820683508824917388940796807540365536608326,
             13989472353090004860230159969988191722492357361023231988844863198684531833417],
            [2247273923851429917501071961409307055808319476406488386743803725604651635134,
             2493874927500709266528969881319380849792047404076370667361733008462726057678]
        );
        vk.gamma2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.delta2 = Pairing.G2Point(
            [5816703893942767599387758329653436371982689399848927686688231055139176923541,
             14058252721381450297910094327879278828995839584721929675203597466067485907088],
            [7918702392253682784002751081543539862434774696851866740744882037944560371365,
             3056354002997038825255228195357455723238791187905587327575401648382571036260]
        );
        vk.IC = new Pairing.G1Point[](21);
        
        vk.IC[0] = Pairing.G1Point( 
            19306028282849836126477002244718804268193339800823655526120471081021258697263,
            729032545905020512934484397627848190713870192641233887958205267390884326160
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            10788638490314945511387203987437177514474264636457403692552234379611335648816,
            659339860446303738779855563980677307087219188419537328994510651537450452371
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            10493038403999423199459390907726812966162118387314279236313373392750708780307,
            20680629672494107325617506319117374469428380189922966069379170756591678666287
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            17431700827303576900469613438344493781584111613607570157993203625794973316905,
            8355306107724627916883345905259008388284107936934370276107497132982383386316
        );                                      
        
        vk.IC[4] = Pairing.G1Point( 
            6987864676448281604008037157545475315410684249299555022183900590794769924856,
            8048215124022227008321499376820318042824498845803420774178758804749908633919
        );                                      
        
        vk.IC[5] = Pairing.G1Point( 
            10841076542615987070118469527290553292075843412406435382567467698020687964627,
            4417334353133948709875035684430189722232655328433861106734572910723010557958
        );                                      
        
        vk.IC[6] = Pairing.G1Point( 
            15007214648835420896554417044921856930939098138369450067408991348396474552007,
            15019582839404577463266588529504559284061596179033069778185121797725555222356
        );                                      
        
        vk.IC[7] = Pairing.G1Point( 
            7416261610475251584495857721574178988535590824602630182236697899968308478687,
            8548447652631074279804690780479220871903874732848139409186680216492829088517
        );                                      
        
        vk.IC[8] = Pairing.G1Point( 
            21309045030304947457003172041127819673100555170445086557361546945866780468871,
            573895178772087057320048374761396764731055829226292227771267299500967984236
        );                                      
        
        vk.IC[9] = Pairing.G1Point( 
            16849091099547894962131048215750002872172238446077710686916596513573998852151,
            10389712478145396319778260656527338248415603583385272930986790291252065609930
        );                                      
        
        vk.IC[10] = Pairing.G1Point( 
            11768254217346233622693433415499326242735621892592141853623202348360080549701,
            9123544644562543517411184200447058024186453861421031287853870112268449719682
        );                                      
        
        vk.IC[11] = Pairing.G1Point( 
            4620540281762839125354602386339933894962781829565763402166899518886878354846,
            3961916788822156674622483996857678687266499904116261212871725820029943675637
        );                                      
        
        vk.IC[12] = Pairing.G1Point( 
            17123613870896430645431467191723018307565797965908827751528003175895462468627,
            15636335557815838430078137996075356959179243712621473829902476341837276580771
        );                                      
        
        vk.IC[13] = Pairing.G1Point( 
            4598752593397597035930545444819418962483608782117100493792428540870451558036,
            8846111909202241384133017405238541204789387938323518590447527254845989596939
        );                                      
        
        vk.IC[14] = Pairing.G1Point( 
            15215111670619495244520509990139219099106898785363777281154630661769150672737,
            18646754406390550195539059762748602428105278004528864628370831893886250081351
        );                                      
        
        vk.IC[15] = Pairing.G1Point( 
            1134328066598445712914300134449206483454786663506862754660995357851057189609,
            10433056894387892098540337899144499553122479790882123921125452388676821640874
        );                                      
        
        vk.IC[16] = Pairing.G1Point( 
            2670631852105721387262405640881435325999455880710985816100101511813406210800,
            18723972029101869010454136038908305537374011006208925723218054593713849748751
        );                                      
        
        vk.IC[17] = Pairing.G1Point( 
            3788166441486561155803953014193700871932139634148690414148832354711441289850,
            20094536550541585693959925309139722167149483246025327122105798897994823206606
        );                                      
        
        vk.IC[18] = Pairing.G1Point( 
            15207092929382826774684787097997161671458292782952458872212894010565861118097,
            7681452288401406022799302404220004738857496417372162045981076130238060884676
        );                                      
        
        vk.IC[19] = Pairing.G1Point( 
            12386412831023186964031501178096907361616853626215805096232101096337805524574,
            1804142973597808046043676984615977865025112352528587737931627370737251767854
        );                                      
        
        vk.IC[20] = Pairing.G1Point( 
            8892897768847084794793214392730050548898749209650927816240155927296521452940,
            8512491901105488401116886669807343570126108921537974214355269316460171073350
        );                                      
        
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd4(
            Pairing.negate(proof.A), proof.B,
            vk.alfa1, vk.beta2,
            vk_x, vk.gamma2,
            proof.C, vk.delta2
        )) return 1;
        return 0;
    }
    /// @return r  bool true if proof is valid
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[20] memory input
        ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
