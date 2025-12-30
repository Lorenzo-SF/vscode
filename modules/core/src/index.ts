import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext): any {
    console.log('[ElixIDE Core] Module activated');
    
    // Comando de ejemplo: ElixIDE: Show Version
    const showVersionCommand = vscode.commands.registerCommand('elixide.showVersion', () => {
        vscode.window.showInformationMessage('ElixIDE v0.1.0 - Elixir Development Environment');
    });
    
    context.subscriptions.push(showVersionCommand);
    
    return {
        showVersion: () => {
            vscode.window.showInformationMessage('ElixIDE v0.1.0');
        }
    };
}

export function deactivate(): void {
    console.log('[ElixIDE Core] Module deactivated');
}
