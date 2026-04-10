import { Request, Response, NextFunction } from "express";
import { verifyToken } from "../utils/jwt";
import jwt from "jsonwebtoken"

export interface AuthRequest extends Request {
    user?: any
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ message: "Unauthorized" })
    }
    const token = authHeader.split(" ")[1];
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET as string) as any;
        req.user = decoded;
        next();
    } catch (e) {
        return res.status(401).json({ message: "Invalid Token" })
    }
}