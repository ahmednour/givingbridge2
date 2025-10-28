#!/usr/bin/env node

const { spawn } = require("child_process");
const path = require("path");

async function runTests() {
  console.log("🚀 Running comprehensive test suite...");

  const jestPath = path.join(__dirname, "../node_modules/.bin/jest");
  const args = [
    "--coverage",
    "--verbose",
    "--detectOpenHandles",
    "--forceExit",
  ];

  // Add specific test patterns if provided
  if (process.argv.length > 2) {
    args.push(...process.argv.slice(2));
  }

  const jest = spawn(jestPath, args, {
    cwd: path.join(__dirname, ".."),
    stdio: "inherit",
    shell: process.platform === "win32",
  });

  jest.on("close", (code) => {
    if (code === 0) {
      console.log("✅ All tests passed successfully!");
    } else {
      console.log(`❌ Tests failed with exit code ${code}`);
    }
    process.exit(code);
  });

  jest.on("error", (error) => {
    console.error("❌ Failed to run tests:", error);
    process.exit(1);
  });
}

runTests();