import {Request, Response} from 'express';
import { AppDataSource } from '../data-source';
import { User } from '../model/User';
import { Student } from '../model/Student';
import { Class } from '../model/Class';
import { AuthRequest } from '../middleware/middleware';

// const studentRepository = AppDataSource.getRepository(Student);
// const userRepository = AppDataSource.getRepository(User);
// const classRepository = AppDataSource.getRepository(Class);

export const createClass = async (req:AuthRequest, res:Response) => {

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const userRepository = queryRunner.manager.getRepository(User);
    const classRepository = queryRunner.manager.getRepository(Class);

    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        if (!userId) {
            console.log("❌ http://localhost:3000/api/class/create");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/class/create");
            return res.status(403).json({message:"Forbidden"})
        }

        const { startTime, endTime, days, description, location, name } = req.body
        
        if(!name){
            console.log("❌ http://localhost:3000/api/class/create");
            return res.status(400).json({message:"Missing Required Fields"})
        }

        if (!Array.isArray(days)) {
            console.log("❌ http://localhost:3000/api/class/create");
            return res.status(400).json({ message: "Days must be an array" });
        }

        const teacher = await userRepository.findOneBy({id:userId});

        if (!teacher){
            console.log("❌ http://localhost:3000/api/class/create");
            return res.status(404).json({message:"User not found"})
        }

        const newClass = classRepository.create({
            name, days, startTime, endTime, description, teacher, location
        });

        await queryRunner.manager.save(newClass);
        await queryRunner.commitTransaction();

        console.log("✅ http://localhost:3000/api/class/create");
        return res.status(201).json({
            id: newClass.id,
            name: newClass.name,
            description: newClass.description,
            location: newClass.location,
            startTime: newClass.startTime,
            endTime: newClass.endTime,
            days: newClass.days
        });
    }catch(e){
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/class/create");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to create class" });
    }finally{
        await queryRunner.release();
    }

}

export const updateClass = async (req:AuthRequest, res:Response) => {
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const userRepository = queryRunner.manager.getRepository(User);
    const classRepository = queryRunner.manager.getRepository(Class);

    try{

        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(403).json({message:"Forbidden"})
        }

        if (isNaN(classId)) {
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(400).json({ message: "Invalid class id" });
        }

        const { startTime, endTime, days, description, location, name } = req.body
        

        if (days !== undefined && !Array.isArray(days)) {
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(400).json({ message: "Days must be an array" });
        }

        const teacher = await userRepository.findOneBy({id:userId});

        if (!teacher){
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(404).json({message:"User not found"})
        }

        const existingClass = await classRepository.findOne({
            where: { id: classId },
            relations: ["teacher"],
        });

        if (!existingClass) {
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(404).json({ message: "Class not found" });
        }

        if(existingClass.teacher.id != userId){
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(403).json({ message: "Not class owner" });
        }

        if (name !== undefined) existingClass.name = name;
        if (description !== undefined) existingClass.description = description;
        if (location !== undefined) existingClass.location = location;
        if (days !== undefined) existingClass.days = days;
        if (startTime !== undefined) existingClass.startTime = startTime;
        if (endTime !== undefined) existingClass.endTime = endTime;

        await queryRunner.manager.save(existingClass);
        await queryRunner.commitTransaction();

        console.log("✅ http://localhost:3000/api/class/update");
        return res.status(200).json({
            id: existingClass.id,
            name: existingClass.name,
            description: existingClass.description,
            location: existingClass.location,
            startTime: existingClass.startTime,
            endTime: existingClass.endTime,
            days: existingClass.days
        });

    }catch(e){
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/class/update");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to update class" });
    }finally{
        await queryRunner.release();
    }
}

export const deleteClass = async (req:AuthRequest, res:Response) => {
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const userRepository = queryRunner.manager.getRepository(User);
    const classRepository = queryRunner.manager.getRepository(Class);

    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.id);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/class/delete");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/class/delete");
            return res.status(403).json({message:"Forbidden"})
        }
        

        const teacher = await userRepository.findOneBy({id:userId});

        if (!teacher){
            console.log("❌ http://localhost:3000/api/class/delete");
            return res.status(404).json({message:"User not found"})
        }

        const existingClass = await classRepository.findOne({
            where: { id: classId },
            relations: ["teacher"],
        });

        if (!existingClass) {
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(404).json({ message: "Class not found" });
        }

        if(existingClass.teacher.id != userId){
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(403).json({ message: "Not class owner" });
        }

        await queryRunner.manager
            .createQueryBuilder()
            .delete()
            .from('Study_in')
            .where('classId = :classId', {classId})
            .execute();

        await queryRunner.manager
            .createQueryBuilder()
            .delete()
            .from("assignment")
            .where("classId = :classId", { classId })
            .execute();

        await queryRunner.manager
            .createQueryBuilder()
            .delete()
            .from("event")
            .where("classId = :classId", { classId })
            .execute();

        await queryRunner.manager
            .createQueryBuilder()
            .delete()
            .from("attendance")
            .where("classId = :classId", { classId })
            .execute();

        await classRepository.delete(classId);

        await queryRunner.commitTransaction();
        
        console.log("✅ http://localhost:3000/api/class/update");
        return res.status(204).send();

    }catch(e){
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/class/delete");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to delete class" });
    }finally{
        await queryRunner.release();
    }
}

export const getMyClasses = async (req:AuthRequest, res: Response) => {

    const classRepository = AppDataSource.getRepository(Class);
    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        if (!userId) {
            console.log("❌ http://localhost:3000/api/class/get_my_classes");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/class/get_my_classes");
            return res.status(403).json({message:"Forbidden"})
        }

        const allClasses = await classRepository.find({
            where: { teacher: { id: userId } },
        });

        console.log("✅ http://localhost:3000/api/class/get_my_classes");
        return res.status(200).send({
            classes: allClasses
        });
    }catch(e){
        console.log("❌ http://localhost:3000/api/class/get_my_classes");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get your classes" });
    }
}

export const getClassDetails = async (req:AuthRequest, res:Response) => {
    const classRepository = AppDataSource.getRepository(Class);
    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.id);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/class/details");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/class/details");
            return res.status(403).json({message:"Forbidden"})
        }

        const classDetails = await classRepository.findOneBy({
            id: classId
        });

        if (!classDetails){
            console.log("❌ http://localhost:3000/api/class/details");
            return res.status(404).json({message:'Class not found'})
        }

        console.log("✅ http://localhost:3000/api/class/details");
        return res.status(200).send({
            class: classDetails
        });
    }catch(e){
        console.log("❌ http://localhost:3000/api/class/details");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get the class details" });
    }
}