import jwt,{SignOptions, Secret } from "jsonwebtoken";

const JWT_SECRET: string = process.env.JWT_SECRET as string;
const JWT_EXPIRES_IN: string = process.env.JWT_EXPIRES_IN as string;

interface JwtPayload{
    id: number;
    role: string;
}

export const generateToken = (payload: JwtPayload) => {
    return jwt.sign(payload, JWT_SECRET as Secret,{
        expiresIn: JWT_EXPIRES_IN
    } as SignOptions)
}

export const verifyToken = (token: string) => {
    return jwt.verify(token, JWT_SECRET);
};