#!/bin/bash
# ElixIDE: Instalar aliases en .bashrc para node, yarn, etc.

BASHRC="$HOME/.bashrc"
ELIXIDE_ALIASES="# ElixIDE aliases
alias elixide-node='cd ~/proyectos/ElixIDE && source scripts/init-env.sh && node'
alias elixide-yarn='cd ~/proyectos/ElixIDE && source scripts/init-env.sh && yarn'
alias elixide-start='cd ~/proyectos/ElixIDE && ./scripts/start.sh'
alias elixide-compile='cd ~/proyectos/ElixIDE && source scripts/init-env.sh && yarn compile'
alias elixide-setup='cd ~/proyectos/ElixIDE && ./scripts/setup-and-compile.sh'
"

if ! grep -q "# ElixIDE aliases" "$BASHRC" 2>/dev/null; then
    echo "" >> "$BASHRC"
    echo "$ELIXIDE_ALIASES" >> "$BASHRC"
    echo "✅ Aliases de ElixIDE agregados a ~/.bashrc"
    echo "Recarga tu shell con: source ~/.bashrc"
else
    echo "✅ Aliases de ElixIDE ya están en ~/.bashrc"
fi

