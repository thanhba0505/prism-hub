#!/usr/bin/env node
import { spawn } from 'node:child_process';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const ROOT_DIR = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const SERVICE_CONFIGS = [
  { name: 'wonderlab', color: '\x1b[1;34m', label: 'WONDERLAB' },
  { name: 'central-gateway', color: '\x1b[1;35m', label: 'GATEWAY' },
  { name: 'git-pulse', color: '\x1b[1;32m', label: 'GIT-PULSE' },
];

const modeArg = process.argv.find(arg => arg.startsWith('--mode='));
const mode = modeArg ? modeArg.split('=')[1] : 'all';
const scriptName = mode === 'clients' ? 'dev:client' : mode === 'servers' ? 'dev:server' : 'dev';

const children = [];
let shuttingDown = false;

function writePrefixed(prefix, chunk, stream) {
  const lines = chunk.toString('utf8').split(/\r?\n/);
  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    if (i === lines.length - 1 && line === '') continue;
    stream.write(`${prefix} ${line}\n`);
  }
}

function shutdown(signal = 'SIGTERM', exitCode = 0) {
  if (shuttingDown) return;
  shuttingDown = true;
  process.stdout.write(
    `\n\x1b[1;33m[prism-hub]\x1b[0m Stopping all dev processes (${signal})...\n`,
  );
  for (const child of children) {
    if (!child.killed) {
      child.kill(signal);
    }
  }
  setTimeout(() => {
    for (const child of children) {
      if (!child.killed) child.kill('SIGKILL');
    }
    process.exit(exitCode);
  }, 1500).unref();
}

process.on('SIGINT', () => shutdown('SIGINT', 0));
process.on('SIGTERM', () => shutdown('SIGTERM', 0));

for (const svc of SERVICE_CONFIGS) {
  const cwd = path.join(ROOT_DIR, 'services', svc.name);
  const child = spawn('pnpm', [scriptName], {
    cwd,
    env: process.env,
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  const prefix = `${svc.color}[${svc.label}]\x1b[0m`;
  child.stdout?.on('data', chunk => writePrefixed(prefix, chunk, process.stdout));
  child.stderr?.on('data', chunk => writePrefixed(prefix, chunk, process.stderr));
  child.on('exit', code => {
    if (!shuttingDown && code !== 0) {
      process.stderr.write(`${prefix} exited with code ${code ?? 1}\n`);
      shutdown('SIGTERM', code ?? 1);
    }
  });
  children.push(child);
}
