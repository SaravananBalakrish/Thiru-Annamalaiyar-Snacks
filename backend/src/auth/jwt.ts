import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET ?? 'please-change-me';

export const signToken = (userId: number, expiresIn = '1h') => {
    return jwt.sign({ sub: String(userId) }, JWT_SECRET, { expiresIn } as any);
};

export const verifyToken = (token: string) => {
    try {
        const decoded = jwt.verify(token, JWT_SECRET) as { sub?: string };
        return decoded;
    } catch (err) {
        return null;
    }
};
