/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * ElixIDE: Manejo de Errores Robusto
 * Carga asíncrona con timeouts, fallback graceful, modo degradado
 */

import * as vscode from 'vscode';
import { Logger } from './logger.js';
import { TelemetryService } from './telemetry.js';

export interface ModuleLoadResult<T> {
	success: boolean;
	module?: T;
	error?: Error;
	loadTime?: number;
}

export class ErrorHandler {
	private static instance: ErrorHandler | undefined;
	private logger: Logger;
	private telemetry: TelemetryService;
	private failedModules: Set<string> = new Set();
	private healthChecks: Map<string, () => boolean> = new Map();

	private constructor() {
		this.logger = Logger.getInstance();
		this.telemetry = TelemetryService.getInstance();
	}

	static getInstance(): ErrorHandler {
		if (!ErrorHandler.instance) {
			ErrorHandler.instance = new ErrorHandler();
		}
		return ErrorHandler.instance;
	}

	/**
	 * Cargar módulo con timeout y manejo de errores
	 */
	async loadModuleWithTimeout<T>(
		moduleId: string,
		loadFn: () => Promise<T>,
		timeout: number = 30000
	): Promise<ModuleLoadResult<T>> {
		const startTime = Date.now();

		try {
			const timeoutPromise = new Promise<never>((_, reject) => {
				setTimeout(() => {
					reject(new Error(`Module ${moduleId} load timeout after ${timeout}ms`));
				}, timeout);
			});

			const module = await Promise.race([loadFn(), timeoutPromise]);
			const loadTime = Date.now() - startTime;

			this.logger.info(`Module ${moduleId} loaded successfully`, { loadTime });
			this.failedModules.delete(moduleId);

			return {
				success: true,
				module: module as T,
				loadTime
			};
		} catch (error: any) {
			const loadTime = Date.now() - startTime;
			const err = error instanceof Error ? error : new Error(String(error));

			this.logger.error(`Failed to load module ${moduleId}`, { loadTime }, err);
			this.telemetry.logError(err, `Module load: ${moduleId}`);
			this.failedModules.add(moduleId);

			// Notificar solo si es crítico
			if (this.isCriticalModule(moduleId)) {
				this.notifyCriticalError(moduleId, err);
			}

			return {
				success: false,
				error: err,
				loadTime
			};
		}
	}

	/**
	 * Verificar si un módulo es crítico
	 */
	private isCriticalModule(moduleId: string): boolean {
		// Módulos críticos que deben cargarse para que ElixIDE funcione
		const criticalModules = ['core'];
		return criticalModules.includes(moduleId);
	}

	/**
	 * Notificar error crítico al usuario
	 */
	private notifyCriticalError(moduleId: string, error: Error): void {
		vscode.window.showErrorMessage(
			`ElixIDE: Failed to load critical module '${moduleId}'. Some features may not work.`,
			'Show Details'
		).then(selection => {
			if (selection === 'Show Details') {
				vscode.window.showErrorMessage(
					`Module: ${moduleId}\nError: ${error.message}\n\nCheck logs for more details.`,
					{ modal: true }
				);
			}
		});
	}

	/**
	 * Ejecutar función con fallback graceful
	 */
	async executeWithFallback<T>(
		operation: string,
		primaryFn: () => Promise<T>,
		fallbackFn: () => Promise<T>
	): Promise<T> {
		try {
			return await primaryFn();
		} catch (error: any) {
			this.logger.warn(`Primary operation failed for ${operation}, using fallback`, {}, error);
			
			try {
				return await fallbackFn();
			} catch (fallbackError: any) {
				this.logger.error(`Fallback also failed for ${operation}`, {}, fallbackError);
				throw fallbackError;
			}
		}
	}

	/**
	 * Registrar health check para un módulo
	 */
	registerHealthCheck(moduleId: string, checkFn: () => boolean): void {
		this.healthChecks.set(moduleId, checkFn);
	}

	/**
	 * Ejecutar health checks periódicos
	 */
	async performHealthChecks(): Promise<Map<string, boolean>> {
		const results = new Map<string, boolean>();

		for (const [moduleId, checkFn] of this.healthChecks.entries()) {
			try {
				const isHealthy = checkFn();
				results.set(moduleId, isHealthy);

				if (!isHealthy) {
					this.logger.warn(`Health check failed for module ${moduleId}`);
					this.failedModules.add(moduleId);
				} else {
					this.failedModules.delete(moduleId);
				}
			} catch (error: any) {
				this.logger.error(`Health check error for module ${moduleId}`, {}, error);
				results.set(moduleId, false);
				this.failedModules.add(moduleId);
			}
		}

		return results;
	}

	/**
	 * Verificar si un módulo está en modo degradado
	 */
	isModuleDegraded(moduleId: string): boolean {
		return this.failedModules.has(moduleId);
	}

	/**
	 * Obtener lista de módulos fallidos
	 */
	getFailedModules(): string[] {
		return Array.from(this.failedModules);
	}

	/**
	 * Limpiar estado de módulo fallido (para reintento)
	 */
	clearModuleFailure(moduleId: string): void {
		this.failedModules.delete(moduleId);
	}

	/**
	 * Manejar error de forma genérica
	 */
	handleError(error: Error, context?: string, showNotification: boolean = false): void {
		this.logger.error(
			context || 'Unhandled error',
			{ error: error.message },
			error
		);

		this.telemetry.logError(error, context);

		if (showNotification) {
			vscode.window.showErrorMessage(
				`ElixIDE: ${error.message}`,
				'Show Details'
			).then(selection => {
				if (selection === 'Show Details') {
					vscode.window.showErrorMessage(
						`Error: ${error.message}\n\nStack: ${error.stack}`,
						{ modal: true }
					);
				}
			});
		}
	}
}

