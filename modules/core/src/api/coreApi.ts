/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * ElixIDE Core API
 * API pública del módulo core para otros módulos
 */

import * as vscode from 'vscode';

export class CoreApi {
	private context: vscode.ExtensionContext;

	constructor(context: vscode.ExtensionContext) {
		this.context = context;
	}

	/**
	 * Obtiene la versión de ElixIDE
	 */
	getVersion(): string {
		return '0.1.0';
	}

	/**
	 * Muestra información de ElixIDE
	 */
	showInfo(): void {
		vscode.window.showInformationMessage(
			`ElixIDE v${this.getVersion()} - Elixir Development Environment`
		);
	}
}

