const wc  = require("./generate_witness.js");

module.exports.generateWitness = async function (input) {
	const response = await fetch('/circuit.wasm');
	const buffer = await response.arrayBuffer();
	let buff;
	await wc(buffer).then(async witnessCalculator => {
		buff = await witnessCalculator.calculateWTNSBin(input, 0);
	});
	return buff;
}