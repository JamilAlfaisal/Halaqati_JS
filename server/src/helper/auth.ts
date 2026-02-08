import bcrypt from 'bcrypt';

const rounds = 10;

export const hashPassword = async (password:string): Promise<string> => {
    return await bcrypt.hash(password, rounds);
}

export const isMatch = (password:string, storedPassword:string): Promise<boolean> => {
    return bcrypt.compare(password, storedPassword);
}