import { Response, NextFunction } from "express";
import { AuthRequest } from "./middleware";

export const requireAdmin = (req: AuthRequest, res: Response, next: NextFunction) => {
    if (req.user?.role !== 'admin') {
        return res.status(403).json({ message: "Forbidden: Admin access required" });
    }
    next();
};
