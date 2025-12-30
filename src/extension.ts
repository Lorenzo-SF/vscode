/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * ElixIDE: Punto de entrada principal de la extensión
 * Carga el sistema de bootstrap que detecta y carga todos los módulos
 */

import * as vscode from 'vscode';
import { bootstrap } from './bootstrap.js';
import { registerExportLogsCommand } from './commands/exportLogs.js';
import { registerShowVersionCommand } from './commands/showVersion.js';
import { Logger } from './utils/logger.js';

export async function activate(context: vscode.ExtensionContext): Promise<void> {
	const logger = Logger.getInstance();
	logger.info('ElixIDE extension activating...');
	
	// Registrar comandos
	registerExportLogsCommand(context);
	registerShowVersionCommand(context);
	
	// Inicializar sistema de bootstrap de forma asíncrona para no bloquear
	setTimeout(async () => {
		try {
			await bootstrap(context);
		} catch (error: any) {
			logger.error('Error during bootstrap (non-fatal)', {}, error instanceof Error ? error : new Error(String(error)));
			// No mostrar error al usuario - el bootstrap es opcional
		}
	}, 0);
	
	logger.info('ElixIDE extension activated');
}

export function deactivate(): void {
	console.log('[ElixIDE] Extension deactivating...');
}

