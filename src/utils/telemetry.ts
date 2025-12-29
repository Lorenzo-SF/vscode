/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * ElixIDE: Sistema de Telemetría Básico
 * Eventos opcionales y desactivables para diagnóstico
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { Logger } from './logger.js';

export interface TelemetryEvent {
	timestamp: number;
	event: string;
	data?: any;
}

export class TelemetryService {
	private static instance: TelemetryService | undefined;
	private enabled: boolean = false;
	private logFile: string;
	private events: TelemetryEvent[] = [];
	private maxEvents: number = 1000;
	private flushInterval: number = 30000; // 30 segundos
	private flushTimer: any;

	private constructor() {
		const elixideDataDir = path.join(
			process.env.HOME || process.env.USERPROFILE || '',
			'.elixide'
		);
		const logsDir = path.join(elixideDataDir, 'logs');
		
		// Crear directorio de logs si no existe
		if (!fs.existsSync(logsDir)) {
			fs.mkdirSync(logsDir, { recursive: true });
		}

		this.logFile = path.join(logsDir, `telemetry-${Date.now()}.json`);
		
		// Verificar configuración del usuario
		const config = vscode.workspace.getConfiguration('elixide');
		this.enabled = config.get<boolean>('telemetry.enabled', false);
		
		if (this.enabled) {
			this.startFlushTimer();
		}
	}

	static getInstance(): TelemetryService {
		if (!TelemetryService.instance) {
			TelemetryService.instance = new TelemetryService();
		}
		return TelemetryService.instance;
	}

	/**
	 * Registrar evento de telemetría
	 */
	logEvent(event: string, data?: any): void {
		if (!this.enabled) {
			return;
		}

		const telemetryEvent: TelemetryEvent = {
			timestamp: Date.now(),
			event,
			data: this.sanitizeData(data)
		};

		this.events.push(telemetryEvent);

		// Si hay demasiados eventos, hacer flush inmediato
		if (this.events.length >= this.maxEvents) {
			this.flush();
		}
	}

	/**
	 * Sanitizar datos para evitar información sensible
	 */
	private sanitizeData(data: any): any {
		if (!data) {
			return undefined;
		}

		const sanitized: any = {};
		const sensitiveKeys = ['password', 'token', 'secret', 'key', 'apiKey', 'auth'];

		for (const [key, value] of Object.entries(data)) {
			const lowerKey = key.toLowerCase();
			if (sensitiveKeys.some(sk => lowerKey.includes(sk))) {
				sanitized[key] = '[REDACTED]';
			} else if (typeof value === 'object' && value !== null) {
				sanitized[key] = this.sanitizeData(value);
			} else {
				sanitized[key] = value;
			}
		}

		return sanitized;
	}

	/**
	 * Registrar evento de inicio
	 */
	logStartup(): void {
		this.logEvent('startup', {
			version: vscode.extensions.getExtension('elixide.core')?.packageJSON?.version || 'unknown',
			timestamp: Date.now()
		});
	}

	/**
	 * Registrar evento de cierre
	 */
	logShutdown(): void {
		this.logEvent('shutdown', {
			timestamp: Date.now()
		});
		this.flush();
	}

	/**
	 * Registrar error crítico
	 */
	logError(error: Error, context?: string): void {
		this.logEvent('error', {
			message: error.message,
			stack: error.stack,
			context,
			timestamp: Date.now()
		});
	}

	/**
	 * Registrar métrica de rendimiento
	 */
	logPerformance(metric: string, value: number, unit: string = 'ms'): void {
		this.logEvent('performance', {
			metric,
			value,
			unit,
			timestamp: Date.now()
		});
	}

	/**
	 * Registrar uso de memoria
	 */
	logMemoryUsage(): void {
		if (typeof process !== 'undefined' && process.memoryUsage) {
			const memUsage = process.memoryUsage();
			this.logPerformance('memory.heapUsed', memUsage.heapUsed, 'bytes');
			this.logPerformance('memory.heapTotal', memUsage.heapTotal, 'bytes');
			this.logPerformance('memory.rss', memUsage.rss, 'bytes');
		}
	}

	/**
	 * Escribir eventos a archivo
	 */
	private flush(): void {
		if (this.events.length === 0) {
			return;
		}

		try {
			const eventsToWrite = [...this.events];
			this.events = [];

			// Rotar logs si el archivo es muy grande (>100MB)
			if (fs.existsSync(this.logFile)) {
				const stats = fs.statSync(this.logFile);
				if (stats.size > 100 * 1024 * 1024) { // 100MB
					this.rotateLogFile();
				}
			}

			// Escribir eventos (append)
			const logLine = JSON.stringify({
				timestamp: Date.now(),
				events: eventsToWrite
			}) + '\n';

			fs.appendFileSync(this.logFile, logLine, 'utf8');
		} catch (error) {
			// No bloquear si hay error escribiendo telemetría
			Logger.getInstance().warn('Failed to write telemetry', error);
		}
	}

	/**
	 * Rotar archivo de log
	 */
	private rotateLogFile(): void {
		const timestamp = Date.now();
		const rotatedFile = this.logFile.replace(/\.json$/, `-${timestamp}.json`);
		
		if (fs.existsSync(this.logFile)) {
			fs.renameSync(this.logFile, rotatedFile);
		}

		this.logFile = path.join(
			path.dirname(this.logFile),
			`telemetry-${Date.now()}.json`
		);

		// Limpiar logs antiguos (>7 días)
		this.cleanOldLogs();
	}

	/**
	 * Limpiar logs antiguos (>7 días)
	 */
	private cleanOldLogs(): void {
		const logsDir = path.dirname(this.logFile);
		const sevenDaysAgo = Date.now() - (7 * 24 * 60 * 60 * 1000);

		try {
			const files = fs.readdirSync(logsDir);
			for (const file of files) {
				if (file.startsWith('telemetry-') && file.endsWith('.json')) {
					const filePath = path.join(logsDir, file);
					const stats = fs.statSync(filePath);
					if (stats.mtimeMs < sevenDaysAgo) {
						fs.unlinkSync(filePath);
					}
				}
			}
		} catch (error) {
			// Ignorar errores de limpieza
		}
	}

	/**
	 * Iniciar timer para flush periódico
	 */
	private startFlushTimer(): void {
		if (this.flushTimer) {
			clearInterval(this.flushTimer);
		}

		this.flushTimer = setInterval(() => {
			this.flush();
		}, this.flushInterval);
	}

	/**
	 * Exportar logs para diagnóstico
	 */
	async exportLogs(outputPath: string): Promise<void> {
		// Flush eventos pendientes
		this.flush();

		// Copiar archivo de log
		if (fs.existsSync(this.logFile)) {
			fs.copyFileSync(this.logFile, outputPath);
		}
	}

	/**
	 * Habilitar/deshabilitar telemetría
	 */
	setEnabled(enabled: boolean): void {
		this.enabled = enabled;
		
		if (enabled) {
			this.startFlushTimer();
		} else {
			if (this.flushTimer) {
				clearInterval(this.flushTimer);
				this.flushTimer = undefined;
			}
			// Flush eventos pendientes antes de deshabilitar
			this.flush();
		}
	}

	/**
	 * Limpiar recursos
	 */
	dispose(): void {
		if (this.flushTimer) {
			clearInterval(this.flushTimer);
			this.flushTimer = undefined;
		}
		this.flush();
	}
}

