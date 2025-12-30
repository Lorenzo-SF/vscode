/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * ElixIDE: Sistema de Logging Estructurado
 * Logs en formato JSON con niveles y contexto
 */

import * as fs from 'fs';
import * as path from 'path';

export enum LogLevel {
	TRACE = 0,
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4
}

export interface LogEntry {
	timestamp: number;
	level: string;
	message: string;
	context?: any;
	error?: {
		message: string;
		stack?: string;
	};
}

export class Logger {
	private static instance: Logger | undefined;
	private logFile: string;
	private currentLevel: LogLevel = LogLevel.INFO;
	private maxFileSize: number = 100 * 1024 * 1024; // 100MB
	private retentionDays: number = 7;

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

		this.logFile = path.join(logsDir, `elixide-${this.getDateString()}.log`);
		this.cleanOldLogs();
	}

	static getInstance(): Logger {
		if (!Logger.instance) {
			Logger.instance = new Logger();
		}
		return Logger.instance;
	}

	/**
	 * Obtener string de fecha para nombre de archivo
	 */
	private getDateString(): string {
		const now = new Date();
		return `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}`;
	}

	/**
	 * Escribir entrada de log
	 */
	private writeLog(level: LogLevel, message: string, context?: any, error?: Error): void {
		if (level < this.currentLevel) {
			return;
		}

		const logEntry: LogEntry = {
			timestamp: Date.now(),
			level: LogLevel[level],
			message,
			context: this.sanitizeContext(context)
		};

		if (error) {
			logEntry.error = {
				message: error.message,
				stack: error.stack
			};
		}

		const logLine = JSON.stringify(logEntry) + '\n';

		try {
			// Rotar si el archivo es muy grande
			if (fs.existsSync(this.logFile)) {
				const stats = fs.statSync(this.logFile);
				if (stats.size > this.maxFileSize) {
					this.rotateLogFile();
				}
			}

			fs.appendFileSync(this.logFile, logLine, 'utf8');
		} catch (err) {
			// Fallback a console si no se puede escribir
			console.error('[Logger] Failed to write log:', err);
			console.log(JSON.stringify(logEntry));
		}
	}

	/**
	 * Sanitizar contexto para evitar información sensible
	 */
	private sanitizeContext(context: any): any {
		if (!context) {
			return undefined;
		}

		const sanitized: any = {};
		const sensitiveKeys = ['password', 'token', 'secret', 'key', 'apiKey', 'auth'];

		for (const [key, value] of Object.entries(context)) {
			const lowerKey = key.toLowerCase();
			if (sensitiveKeys.some(sk => lowerKey.includes(sk))) {
				sanitized[key] = '[REDACTED]';
			} else if (typeof value === 'object' && value !== null) {
				sanitized[key] = this.sanitizeContext(value);
			} else {
				sanitized[key] = value;
			}
		}

		return sanitized;
	}

	/**
	 * Rotar archivo de log
	 */
	private rotateLogFile(): void {
		const timestamp = Date.now();
		const rotatedFile = this.logFile.replace(/\.log$/, `-${timestamp}.log`);
		
		if (fs.existsSync(this.logFile)) {
			fs.renameSync(this.logFile, rotatedFile);
		}

		this.logFile = path.join(
			path.dirname(this.logFile),
			`elixide-${this.getDateString()}.log`
		);
	}

	/**
	 * Limpiar logs antiguos (>7 días)
	 */
	private cleanOldLogs(): void {
		const logsDir = path.dirname(this.logFile);
		const retentionTime = Date.now() - (this.retentionDays * 24 * 60 * 60 * 1000);

		try {
			if (!fs.existsSync(logsDir)) {
				return;
			}

			const files = fs.readdirSync(logsDir);
			for (const file of files) {
				if (file.startsWith('elixide-') && file.endsWith('.log')) {
					const filePath = path.join(logsDir, file);
					const stats = fs.statSync(filePath);
					if (stats.mtimeMs < retentionTime) {
						fs.unlinkSync(filePath);
					}
				}
			}
		} catch (error) {
			// Ignorar errores de limpieza
		}
	}

	/**
	 * Establecer nivel de log
	 */
	setLevel(level: LogLevel): void {
		this.currentLevel = level;
	}

	/**
	 * Log nivel TRACE
	 */
	trace(message: string, context?: any): void {
		this.writeLog(LogLevel.TRACE, message, context);
	}

	/**
	 * Log nivel DEBUG
	 */
	debug(message: string, context?: any): void {
		this.writeLog(LogLevel.DEBUG, message, context);
	}

	/**
	 * Log nivel INFO
	 */
	info(message: string, context?: any): void {
		this.writeLog(LogLevel.INFO, message, context);
	}

	/**
	 * Log nivel WARN
	 */
	warn(message: string, context?: any, error?: Error): void {
		this.writeLog(LogLevel.WARN, message, context, error);
	}

	/**
	 * Log nivel ERROR
	 */
	error(message: string, context?: any, error?: Error): void {
		this.writeLog(LogLevel.ERROR, message, context, error);
	}

	/**
	 * Exportar logs para diagnóstico
	 */
	async exportLogs(outputPath: string): Promise<void> {
		const logsDir = path.dirname(this.logFile);
		
		if (!fs.existsSync(logsDir)) {
			return;
		}

		// Copiar todos los logs del día actual
		const todayLog = path.join(logsDir, `elixide-${this.getDateString()}.log`);
		if (fs.existsSync(todayLog)) {
			fs.copyFileSync(todayLog, outputPath);
		}
	}
}

