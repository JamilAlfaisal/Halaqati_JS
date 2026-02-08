import {Request, Response} from 'express';
import { AppDataSource } from '../data-source';
import { User } from '../model/User';
import { Student } from '../model/Student';
import { Class } from '../model/Class';
import { Assignment } from '../model/Assignment';
import { Event } from '../model/Events';
import { AuthRequest } from '../middleware/middleware';

export const createEvent = async (req:AuthRequest, res:Response) => {

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const userRepository = queryRunner.manager.getRepository(User);
    const classRepository = queryRunner.manager.getRepository(Class);
    const assignmentRepository = queryRunner.manager.getRepository(Assignment);

    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(403).json({message:"Forbidden"})
        }

        const { startTime, endTime, days, description, location, name } = req.body
        
        if(!name){
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(400).json({message:"Missing Required Fields"})
        }

        if (!Array.isArray(days)) {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(400).json({ message: "Days must be an array" });
        }

        const teacher = await userRepository.findOneBy({id:userId});

        if (!teacher){
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(404).json({message:"User not found"})
        }

        const newClass = classRepository.create({
            name, days, startTime, endTime, description, teacher, location
        });

        await queryRunner.manager.save(newClass);
        await queryRunner.commitTransaction();

        console.log("✅ http://localhost:3000/api/assignment/create");
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

export const updateEvent = async (req:AuthRequest, res:Response) => {
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const userRepository = queryRunner.manager.getRepository(User);
    const classRepository = queryRunner.manager.getRepository(Class);
    const assignmentRepository = queryRunner.manager.getRepository(Assignment);

    try{

        const userId = req.user?.id;
        const role = req.user?.role;
        const assignmentId = Number(req.params.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(403).json({message:"Forbidden"})
        }

        if (isNaN(assignmentId)) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(400).json({ message: "Invalid assignment id" });
        }

        const { createdAt, dueDate, days, description, pages, title, type , students} = req.body
        

        if (days !== undefined && !Array.isArray(days)) {
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(400).json({ message: "Days must be an array" });
        }

        const teacher = await userRepository.findOneBy({id:userId});

        if (!teacher){
            console.log("❌ http://localhost:3000/api/class/update");
            return res.status(404).json({message:"User not found"})
        }

        const existingAssignment = await assignmentRepository.findOne({
            where: { id: assignmentId },
            relations: ["teacher" , "class", "students"],
        });

        if (!existingAssignment) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(404).json({ message: "assignment not found" });
        }

        if(existingAssignment.teacher.id != userId){
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(403).json({ message: "Not assignment owner" });
        }

        if (title !== undefined) existingAssignment.title = title;
        if (description !== undefined) existingAssignment.description = description;
        if (pages !== undefined) existingAssignment.pages = pages;
        if (createdAt !== undefined) existingAssignment.createdAt = createdAt;
        if (dueDate !== undefined) existingAssignment.dueDate = dueDate;
        if (type !== undefined) existingAssignment.type = type;
        // if (students !== undefined) existingAssignment.students = students;

        await queryRunner.manager.save(existingAssignment);
        await queryRunner.commitTransaction();

        console.log("✅ http://localhost:3000/api/assignment/update");
        return res.status(200).json({
            id: existingAssignment.id,
            title: existingAssignment.title,
            description: existingAssignment.description,
            // students: existingAssignment.students,
            createdAt: existingAssignment.createdAt,
            dueDate: existingAssignment.dueDate,
            type: existingAssignment.type,
            pages: existingAssignment.pages,
            classId: existingAssignment.class.id,
        });

    }catch(e){
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/assignment/update");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to update assignment" });
    }finally{
        await queryRunner.release();
    }
}

export const deleteEvent = async (req:AuthRequest, res:Response) => {
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const userRepository = queryRunner.manager.getRepository(User);
    const classRepository = queryRunner.manager.getRepository(Class);
    const assignmentRepository = queryRunner.manager.getRepository(Assignment);

    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        const assignmentId = Number(req.params.id);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/delete");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/assignment/delete");
            return res.status(403).json({message:"Forbidden"})
        }
        

        const teacher = await userRepository.findOneBy({id:userId});

        if (!teacher){
            console.log("❌ http://localhost:3000/api/assignment/delete");
            return res.status(404).json({message:"User not found"})
        }

        const existingClass = await classRepository.findOne({
            where: { id: assignmentId },
            relations: ["teacher"],
        });

        if (!existingClass) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(404).json({ message: "Class not found" });
        }

        if(existingClass.teacher.id != userId){
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(403).json({ message: "Not assignment owner" });
        }

        await queryRunner.manager
            .createQueryBuilder()
            .delete()
            .from("student_assignment")
            .where("attendanceId = :attendanceId", { assignmentId })
            .execute();

        await assignmentRepository.delete(assignmentId);

        await queryRunner.commitTransaction();
        
        console.log("✅ http://localhost:3000/api/assignment/delete");
        return res.status(204).send();

    }catch(e){
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/assignment/delete");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to delete assignment" });
    }finally{
        await queryRunner.release();
    }
}

export const getEvents = async (req:AuthRequest, res: Response) => {

    const assignmentRepository = AppDataSource.getRepository(Assignment);
    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/get");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/assignment/get");
            return res.status(403).json({message:"Forbidden"})
        }

        const allAssignments = await assignmentRepository.find({
            where: { teacher: { id: userId } },
        });

        console.log("✅ http://localhost:3000/api/assignment/get");
        return res.status(200).send({
            assignments: allAssignments
        });
    }catch(e){
        console.log("❌ http://localhost:3000/api/assignment/get");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get your assignments" });
    }
}

export const getEventDetails = async (req:AuthRequest, res:Response) => {
    const classRepository = AppDataSource.getRepository(Class);
    const assignmentRepository = AppDataSource.getRepository(Assignment);
    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        const assignmentId = Number(req.params.id);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/details");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/assignment/details");
            return res.status(403).json({message:"Forbidden"})
        }

        const assignment = await assignmentRepository.findOneBy({
            id: assignmentId
        });

        if (!assignment){
            console.log("❌ http://localhost:3000/api/assignment/details");
            return res.status(404).json({message:'assignment not found'})
        }

        console.log("✅ http://localhost:3000/api/assignment/details");
        return res.status(200).send({
            assignment: assignment
        });
    }catch(e){
        console.log("❌ http://localhost:3000/api/assignment/details");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get the assignment details" });
    }
}