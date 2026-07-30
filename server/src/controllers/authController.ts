import { Request, Response } from 'express';
import { hashPassword, isMatch } from '../utils/auth';
import { User } from '../model/User';
import { AppDataSource } from '../data-source';
import { Student } from '../model/Student';
import { generateToken } from "../utils/jwt";
import { AuthRequest } from '../middleware/middleware';


const userRepository = AppDataSource.getRepository(User);
const studentRepository = AppDataSource.getRepository(Student);

const executeUserRegistration = async (req: Request, res: Response, roleRestriction?: (role: string) => string | null) => {
    const { phone, password, role, email, dob, name } = req.body;

    if (!phone || !password || !role || !dob || !name) {
        return res.status(400).json({ message: 'Missing required field' })
    }

    if (roleRestriction) {
        const error = roleRestriction(role);
        if (error) {
            return res.status(403).json({ message: error });
        }
    }

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
        const existingUser = await userRepository.findOneBy({ phone });
        if (existingUser) {
            return res.status(400).json({ message: 'Phone already in use' })
        }

        const hashedPassword = await hashPassword(password);
        const user = userRepository.create({
            name,
            email,
            password: hashedPassword,
            phone,
            dob,
            role
        });
        const savedUser = await queryRunner.manager.save(user);
        
        const token = generateToken({
            id: user.id,
            role,
        });

        if (role == "teacher") {
            await queryRunner.commitTransaction();
            return res.status(201).json({
                token,
                message: "user registered successfully",
                user: savedUser
            });
        }

        const student = studentRepository.create({
            user: savedUser,
            id: savedUser.id,
            memorized_juz: []
        })
        await queryRunner.manager.save(student);
        await queryRunner.commitTransaction();

        res.status(201).json({
            token,
            message: "Student registered successfully",
            user: savedUser,
            memorized_juz: student.memorized_juz
        })

    } catch (e) {
        await queryRunner.rollbackTransaction();
        console.error(`❌ ${e}`)
        res.status(500).json({ message: "Internal server error" })
    } finally {
        await queryRunner.release();
    }
}

export const singUp = async (req: Request, res: Response) => {
    return executeUserRegistration(req, res, (role) => {
        if (role === 'admin') {
            return 'Admin registration not allowed via public signup';
        }
        return null;
    });
}

export const adminCreateAccount = async (req: AuthRequest, res: Response) => {
    return executeUserRegistration(req, res, (role) => {
        if (role !== 'teacher' && role !== 'student') {
            return 'Only teacher and student accounts can be created via this endpoint';
        }
        return null;
    });
}


export const login = async (req: Request, res: Response) => {
    const { phone, password } = req.body;

    if (!phone || !password) {
        console.log("❌ http://localhost:3000/api/auth/login/user");
        return res.status(400).json({ message: "Missing Required Fields" })
    }

    console.log(phone);

    const queryRunner = AppDataSource.createQueryRunner();
    queryRunner.connect();
    queryRunner.startTransaction();

    try {
        const user = await userRepository.findOne({
            where: { phone },
            select: {
                id: true,
                phone: true,
                password: true,
                role: true,
                email: true,
                dob: true,
                createdAt: true,
                name: true,
                picProfile: true
            },
        });

        if (!user) {
            console.log("❌ http://localhost:3000/api/auth/login/user");
            return res.status(404).json({ message: "User Does not Exist" })
        }

        const isMatched = await isMatch(password, user.password);
        if (!isMatched) {
            console.log("❌ http://localhost:3000/api/auth/login/user");
            return res.status(401).json({ message: "Incorrect Password" })
        }

        const token = generateToken({
            id: user.id,
            role: user.role,
        });

        const { password: _, ...userWithoutPassword } = user;

        console.log("✅ http://localhost:3000/api/auth/login/user");
        return res.status(200).json({
            message: "Login successful",
            token,
            user: userWithoutPassword
        });

    } catch (e) {
        console.log("❌ http://localhost:3000/api/auth/login/user");
        console.error(`❌ ${e}`);
        res.status(500).json({ message: "Internal server error" })
    } finally {
        await queryRunner.release();
    }
}

export const verifyUsers = async (req: AuthRequest, res: Response) => {

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
        const userId = req.user?.id;
        const role = req.user?.role;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/auth/auth_me/user");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (!role) {
            console.log("❌ http://localhost:3000/api/auth/auth_me/user");
            return res.status(400).json({ message: "Role is required" })
        }

        const user = await userRepository.findOneBy({ id: userId });

        if (!user) {
            console.log("❌ http://localhost:3000/api/auth/auth_me/user");
            return res.status(404).json({ message: "User Does not Exist" })
        }


        if (role == "teacher" || role == "admin") {
            console.log("✅ http://localhost:3000/api/auth/auth_me/user");
            return res.status(200).json({
                user
            });
        } else {

            const student = await studentRepository.findOne({
                where: {
                    user: { id: userId }
                },
                relations: ['user'],
            });

            if (!student) {
                console.log("❌ http://localhost:3000/api/auth/auth_me/user");
                return res.status(404).json({ message: "Student Does not Exist" })
            }

            console.log("✅ http://localhost:3000/api/auth/auth_me/user");
            return res.status(200).json(
                {
                    user: {
                        ...user,
                        memorizedJuz: student?.memorized_juz
                    }
                }
            );
        }

    } catch (e) {
        console.log("❌ http://localhost:3000/api/auth/auth_me/user");
        console.error(`❌ ${e}`);
        res.status(500).json({ message: "Internal server error" })
    } finally {
        await queryRunner.release();
    }
}


export const updateFcmToken = async (req: AuthRequest, res: Response) => {
    try {
        const userId = req.user?.id;
        const { fcmToken } = req.body;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/auth/update-fcm-token");
            return res.status(401).json({ message: "Unauthorized" });
        }

        // 🛑 Validate
        if (!fcmToken) {
            console.log("❌ http://localhost:3000/api/auth/update-fcm-token");
            return res.status(400).json({
                message: "FCM token is required",
            });
        }

        const userRepository = AppDataSource.getRepository(User);

        const user = await userRepository.findOne({
            where: { id: userId },
        });

        if (!user) {
            return res.status(404).json({
                message: "User not found",
            });
        }

        // ✅ Update token
        user.fcmToken = fcmToken;

        await userRepository.save(user);

        return res.status(200).json({
            message: "FCM token updated successfully",
        });
    } catch (error) {
        console.error("FCM TOKEN ERROR:", error);

        return res.status(500).json({
            message: "Internal server error",
        });
    }
};

export const createAdmin = async (req: AuthRequest, res: Response) => {
    const { phone, password, name, dob, email } = req.body;

    if (!phone || !password || !name || !dob) {
        return res.status(400).json({ message: 'Missing required fields' })
    }

    try {
        const userRepository = AppDataSource.getRepository(User);
        const existingUser = await userRepository.findOneBy({ phone });
        if (existingUser) {
            return res.status(400).json({ message: 'Phone already in use' })
        }

        const hashedPassword = await hashPassword(password);
        const adminUser = userRepository.create({
            name,
            email: email || "admin@halaqati.com",
            password: hashedPassword,
            phone,
            dob,
            role: "admin"
        });

        const savedAdmin = await userRepository.save(adminUser);
        const { password: _, ...adminWithoutPassword } = savedAdmin;

        return res.status(201).json({
            message: "Admin created successfully",
            user: adminWithoutPassword
        });

    } catch (e) {
        console.error(`❌ ${e}`);
        res.status(500).json({ message: "Internal server error" })
    }
}

export const updateUser = async (req: AuthRequest, res: Response) => {
    const userId = Number(req.params.id);
    const { name, email, phone, password, picProfile, dob } = req.body;

    if (!userId) {
        return res.status(400).json({ message: 'User ID is required' });
    }

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
        const userRepository = queryRunner.manager.getRepository(User);
        const user = await userRepository.findOneBy({ id: userId });

        if (!user) {
            await queryRunner.rollbackTransaction();
            return res.status(404).json({ message: "User not found" });
        }

        // Check if new phone is already in use by another user
        if (phone && phone !== user.phone) {
            const existingUser = await userRepository.findOneBy({ phone });
            if (existingUser) {
                await queryRunner.rollbackTransaction();
                return res.status(400).json({ message: 'Phone number already in use by another account' });
            }
            user.phone = phone;
        }

        if (name) user.name = name;
        if (email !== undefined) user.email = email;
        if (picProfile !== undefined) user.picProfile = picProfile;
        if (dob !== undefined) user.dob = dob;

        if (password) {
            const hashedPassword = await hashPassword(password);
            user.password = hashedPassword;
        }

        await userRepository.save(user);
        await queryRunner.commitTransaction();

        const { password: _, ...userWithoutPassword } = user;
        return res.status(200).json({
            message: "User updated successfully",
            user: userWithoutPassword
        });

    } catch (e) {
        await queryRunner.rollbackTransaction();
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Internal server error" });
    } finally {
        await queryRunner.release();
    }
}

export const getUserById = async (req: AuthRequest, res: Response) => {
    const userId = Number(req.params.id);
    if (!userId) return res.status(400).json({ message: 'User ID is required' });

    try {
        const userRepository = AppDataSource.getRepository(User);
        const user = await userRepository.findOne({
            where: { id: userId },
            select: ['id', 'name', 'email', 'phone', 'dob', 'picProfile', 'role']
        });

        if (!user) return res.status(404).json({ message: 'User not found' });

        return res.status(200).json(user);
    } catch (e) {
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Internal server error" });
    }
}