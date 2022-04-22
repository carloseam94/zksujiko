import { exportCallDataGroth16 } from "./zkproof.js";

export async function sujikoCalldata(squares, circles, solution) {
  const input = {
    squares: squares,
    circles: circles,
    solution: solution
  };
  let dataResult;
  try {
    dataResult = await exportCallDataGroth16(
      input,
      "/sujiko.wasm",
      "/sujiko_0001.zkey"
    );
  } catch (error) {
    console.log(error);
  }
  return dataResult;
}