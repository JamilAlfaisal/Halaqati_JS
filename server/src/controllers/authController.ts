import {Request, Response} from 'express';
import { hashPassword, isMatch } from '../helper/auth';
import { User } from '../model/User';
import { AppDataSource } from '../data-source';
import { Student } from '../model/Student';
import { generateToken } from "../helper/jwt";
import { AuthRequest } from '../middleware/middleware';


const userRepository = AppDataSource.getRepository(User);
const studentRepository = AppDataSource.getRepository(Student);

export const singUp = async (req: Request, res: Response) => {
    const { phone, password, role, email, dob, name} = req.body;

    if(!phone || !password || !role || !dob || !name){
        console.log("❌ http://localhost:3000/api/auth/login/user");
        return res.status(400).json({message:'Missing required field'})
    }

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try{
        const existingUser = await userRepository.findOneBy({phone}); 
        if(existingUser){
            console.log("❌ http://localhost:3000/api/auth/login/user");
            return res.status(400).json({message:'Phone already in use'})
        }

        const hashedPassword = await hashPassword(password);
        const user = userRepository.create({
            name,
            email,
            password:hashedPassword,
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
        if(role == "teacher"){
            await queryRunner.commitTransaction();
            return res.status(201).json({
                token,
                message: "user registered successfully",
                user: savedUser
            });
        }

        const student = studentRepository.create({
            user:savedUser,
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
        
    }catch(e){
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/auth/signup/user");
        console.error(`❌ ${e}`)
        res.status(500).json({message: "Internal server error"})
    } finally {
        await queryRunner.release();
    }
}


export const login = async (req:Request, res:Response) => {
    const {phone, password}  = req.body;

    if (!phone || !password){
        console.log("❌ http://localhost:3000/api/auth/login/user");
        return res.status(400).json({message:"Missing Required Fields"})
    }

    const queryRunner = AppDataSource.createQueryRunner();
    queryRunner.connect();
    queryRunner.startTransaction();

    try{
        const user = await userRepository.findOneBy({phone});

        if(!user){
            console.log("❌ http://localhost:3000/api/auth/login/user");
            return res.status(404).json({message:"User Does not Exist"})
        }

        const isMatched = await isMatch(password, user.password);
        if(!isMatched){
            console.log("❌ http://localhost:3000/api/auth/login/user");
            return res.status(401).json({message:"Incorrect Password"})
        }

        const token = generateToken({
            id: user.id,
            role:user.role,
        });

        const {password:_, ...userWithoutPassword} = user;

        console.log("✅ http://localhost:3000/api/auth/login/user");
        return res.status(200).json({
            message:"Login successful",
            token,
            user:userWithoutPassword
        });

    }catch(e){
        console.log("❌ http://localhost:3000/api/auth/login/user");
        console.error(`❌ ${e}`);
        res.status(500).json({message: "Internal server error"})
    }finally{
        await queryRunner.release();
    }
}

export const verifyUsers = async (req:AuthRequest, res: Response) => {

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try{
        const userId = req.user?.id;
        const role = req.user?.role;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/auth/auth_me/user");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(!role){
            console.log("❌ http://localhost:3000/api/auth/auth_me/user");
            return res.status(400).json({message:"Role is required"})
        }

        const user = await userRepository.findOneBy({id:userId});

        if(!user){
            console.log("❌ http://localhost:3000/api/auth/auth_me/user");
            return res.status(404).json({message:"User Does not Exist"})
        }
        
        const {password:_, ...userWithoutPassword} = user
        if (role == "teacher"){
            console.log("✅ http://localhost:3000/api/auth/auth_me/user");
            return res.status(200).json({
                user: userWithoutPassword
            });
        }else{
            const student = await studentRepository.findOneBy({
                user: {id: userId}
            });

            if(!student){
                console.log("❌ http://localhost:3000/api/auth/auth_me/user");
                return res.status(404).json({message:"Student Does not Exist"})
            }

            console.log("✅ http://localhost:3000/api/auth/auth_me/user");
            return res.status(200).json({
                user: userWithoutPassword,
                memorized_juz: student?.memorized_juz
            });
        }

    }catch(e){
        console.log("❌ http://localhost:3000/api/auth/auth_me/user");
        console.error(`❌ ${e}`);
        res.status(500).json({message: "Internal server error"})
    }finally{
        await queryRunner.release();
    }
}