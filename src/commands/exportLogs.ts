/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * ElixIDE: Comando para exportar logs
 * Comando: elixide.exportLogs
 */

import * as vscode from 'vscode';
import * as path from 'path';
import { Logger } from '../utils/logger.js';
import { TelemetryService } from '../utils/telemetry.js';

export function registerExportLogsCommand(context: vscode.ExtensionContext): void {
	const command = vscode.commands.registerCommand('elixide.exportLogs', async () => {
		const logger = Logger.getInstance();
		const telemetry = TelemetryService.getInstance();

		// Solicitar ubicación de guardado
		const uri = await vscode.window.showSaveDialog({
			defaultUri: vscode.Uri.file(path.join(
				process.env.HOME || process.env.USERPROFILE || '',
				'elixide-logs-export.json'
			)),
			filters: {
				'JSON': ['json'],
				'All Files': ['*']
			}
		});

		if (!uri) {
			return; // Usuario canceló
		}

		try {
			// Exportar logs
			await logger.exportLogs(uri.fsPath);
			await telemetry.exportLogs(uri.fsPath.replace('.json', '-telemetry.json'));

			vscode.window.showInformationMessage(
				`ElixIDE logs exported to ${path.basename(uri.fsPath)}`
			);
		} catch (error: any) {
			vscode.window.showErrorMessage(
				`Failed to export logs: ${error.message}`
			);
		}
	});

	context.subscriptions.push(command);
}

