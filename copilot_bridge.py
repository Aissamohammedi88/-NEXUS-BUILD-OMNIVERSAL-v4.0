#!/usr/bin/env python3
"""Nexus Copilot Bridge — CLI qui parle à Ollama."""
import subprocess
import sys

MODEL = "qwen2.5-coder:7b"

def copilot(prompt):
    cmd = ["ollama", "run", MODEL]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    stdout, _ = proc.communicate(prompt)
    return stdout.strip()

def main():
    print("🤖 Nexus Copilot CLI — Propulsé par Ollama")
    print("Tape 'exit' pour quitter.\n")
    while True:
        try:
            prompt = input("❓ Copilot > ")
        except (EOFError, KeyboardInterrupt):
            break
        if prompt.lower() == "exit":
            break
        if prompt.strip():
            print("\n🤖 Réponse :")
            print(copilot(prompt))
            print()

if __name__ == "__main__":
    main()
