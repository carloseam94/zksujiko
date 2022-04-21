const wc  = require("./witness_calculator.js");

module.exports.generateWitness = async function (input) {
	const response = await fetch('/sujiko62.wasm');
	const buffer = await response.arrayBuffer();
	let buff;

	await wc(buffer).then(async witnessCalculator => {
		buff = await witnessCalculator.calculateWTNSBin(input, 0);
		console.log(buff)
	});
	return buff;
}
