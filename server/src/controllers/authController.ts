import { Request, Response } from 'express';
import { hashPassword, isMatch } from '../utils/auth';
import { User } from '../model/User';
import { AppDataSource } from '../data-source';
import { Student } from '../model/Student';
import { generateToken } from "../utils/jwt";
import { AuthRequest } from '../middleware/middleware';


const userRepository = AppDataSource.getRepository(User);
const studentRepository = AppDataSource.getRepository(Student);

export const singUp = async (req: Request, res: Response) => {
    const { phone, password, role, email, dob, name } = req.body;

    if (!phone || !password || !role || !dob || !name) {
        console.log("❌ http://localhost:3000/api/auth/login/user");
        return res.status(400).json({ message: 'Missing required field' })
    }

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
        const existingUser = await userRepository.findOneBy({ phone });
        if (existingUser) {
            console.log("❌ http://localhost:3000/api/auth/login/user");
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
        console.log("user saved successfully")
        const token = generateToken({
            id: user.id,
            role,
        });

        console.log("✅ http://localhost:3000/api/auth/signup/user");
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
        console.log("❌ http://localhost:3000/api/auth/signup/user");
        console.error(`❌ ${e}`)
        res.status(500).json({ message: "Internal server error" })
    } finally {
        await queryRunner.release();
    }
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


        if (role == "teacher") {
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


export const updateFcmToken = async (req: Request, res: Response) => {
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