/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * ElixIDE: Comando para mostrar la versión
 * Comando: elixide.showVersion
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

export function registerShowVersionCommand(context: vscode.ExtensionContext): void {
	const command = vscode.commands.registerCommand('elixide.showVersion', async () => {
		try {
			// Leer package.json para obtener la versión
			const packageJsonPath = path.join(context.extensionPath, 'package.json');
			let version = 'unknown';

			if (fs.existsSync(packageJsonPath)) {
				const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
				version = packageJson.version || 'unknown';
			}

			// Leer product.json para obtener información adicional
			const productJsonPath = path.join(context.extensionPath, 'product.json');
			let productName = 'ElixIDE';
			let commit = 'unknown';

			if (fs.existsSync(productJsonPath)) {
				const productJson = JSON.parse(fs.readFileSync(productJsonPath, 'utf8'));
				productName = productJson.nameLong || productJson.name || 'ElixIDE';
				commit = productJson.commit || 'unknown';
			}

			// Mostrar información de versión
			const message = `${productName}\n\nVersion: ${version}\nCommit: ${commit}\n\nBuilt on: ${new Date().toLocaleString()}`;
			
			vscode.window.showInformationMessage(
				`${productName} ${version}`,
				'Show Details'
			).then(selection => {
				if (selection === 'Show Details') {
					vscode.window.showInformationMessage(message, { modal: true });
				}
			});
		} catch (error: any) {
			vscode.window.showErrorMessage(
				`Failed to get version information: ${error.message}`
			);
		}
	});

	context.subscriptions.push(command);
}

