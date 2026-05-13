export enum ErrorCode {
	SERVICE_NOT_FOUND = "SERVICE_NOT_FOUND",
	SLOT_FULL = "SLOT_FULL",
	ITEM_DUPLICATE = "ITEM_DUPLICATE",
	CART_NOT_FOUND = "CART_NOT_FOUND",
	ITEM_NOT_FOUND = "ITEM_NOT_FOUND",
}

export class AppError extends Error {
	statusCode: number;
	errorCode: ErrorCode | string;
	isOperational: boolean;

	constructor(statusCode: number, errorCode: ErrorCode | string, message: string) {
		super(message);

		this.statusCode = statusCode;
		this.errorCode = errorCode;
		this.isOperational = true;

		Object.setPrototypeOf(this, AppError.prototype);
	}
}
