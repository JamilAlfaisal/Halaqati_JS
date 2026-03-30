import {Request, Response} from 'express';
import { AppDataSource } from '../data-source';
import { User } from '../model/User';
import { Student } from '../model/Student';
import { Class } from '../model/Class';
import { AuthRequest } from '../middleware/middleware';
import { StudyIn } from '../model/Study_in';

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
        console.log(days);
        
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
            days: newClass.days,
            students: []
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
            relations: ["teacher", "studyInRecords", "studyInRecords.student"],
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
            days: existingClass.days,
            students: existingClass.studyInRecords.map((s) => {
                return {
                    id: s.student.id,
                    registeredAt: s.registeredAt
                }
            }),
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
            console.log("❌ http://localhost:3000/api/class/delete");
            return res.status(404).json({ message: "Class not found" });
        }

        if(existingClass.teacher.id != userId){
            console.log("❌ http://localhost:3000/api/class/delete");
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
        
        console.log("✅ http://localhost:3000/api/class/delete");
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

export const getTeacherClasses = async (req:AuthRequest, res: Response) => {

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
            relations: [
                'teacher', 
                'events',
                'attendances',
                'assignments',
                'assignments.haveAssignment', 
                'assignments.haveAssignment.student',
                'assignments.haveAssignment.student.user',
                'studyInRecords',
                'studyInRecords.student'
            ]
        });

        const properJson = allClasses.map((classes) => {
            return {
                id: classes.id,
                name:classes.name,
                description: classes.description,
                days: classes.days,
                teacherId: classes.teacher.id,
                startTime: classes.startTime,
                endTime: classes.endTime,
                location: classes.location,
                events: classes.events.map(event => ({
                    eventId: event.id,
                    title: event.title,
                    dueDate: event.dueDate,
                    createdDate: event.createdAt,
                    description: event.description
                })),
                assignments: classes.assignments.map(assignment => ({
                    assignmentId: assignment.id,
                    title: assignment.title,
                    description: assignment.description,
                    dueDate: assignment.dueDate,
                    pages: assignment.pages,
                    type: assignment.type,
                    createdAt: assignment.createdAt,
                    haveAssignment: assignment.haveAssignment.map(record => ({
                        isComplete: record.isComplete,
                        studentId: record.student.id,
                        memorizedJuz: record.student.memorized_juz,
                        studentName: record.student.user.name,
                        picProfile: record.student.user.picProfile
                        
                    })),
                })),
                attendances: classes.attendances.map(attendance => ({
                    attendanceId: attendance.id,
                    date: attendance.date
                })),
                students: classes.studyInRecords.map((record)=>record.student)
            }
        });

        console.log("✅ http://localhost:3000/api/class/get_my_classes");
        return res.status(200).send({
            classes: properJson,
        });
    }catch(e){
        console.log("❌ http://localhost:3000/api/class/get_my_classes");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get your classes" });
    }
}

export const getClassDetails = async (req:AuthRequest, res:Response) => {
    const classRepository = AppDataSource.getRepository(Class);
    const studyInRepository = AppDataSource.getRepository(StudyIn);
    // const studentRepository = AppDataSource.getRepository(Student);
    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.id);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/class/details");
            return res.status(401).json({ message: "Unauthorized" });
        }

        const classDetails = await classRepository.findOne({
           where: {id: classId},
            relations: ["teacher"],
        });

        if (!classDetails){
            console.log("❌ http://localhost:3000/api/class/details");
            return res.status(404).json({message:'Class not found'})
        }
        if (role === "teacher") {
            if (classDetails.teacher.id !== userId) {
                console.log("❌ http://localhost:3000/api/class/details");
                return res.status(403).json({ message: "Forbidden" });
            }
            console.log("✅ http://localhost:3000/api/class/details");
            return res.status(200).json({ class: classDetails });
        }

        if (role === "student") {
            const enrollment = await studyInRepository.findOne({
                where: { student: { user: { id: userId } }, class: { id: classId } },
            });

            if (!enrollment) {
                console.log("❌ http://localhost:3000/api/class/details");
                return res.status(403).json({ message: "Forbidden" });
            }
            console.log("✅ http://localhost:3000/api/class/details");
            return res.status(200).json({ class: classDetails });
        }

        console.log("❌ http://localhost:3000/api/class/details");
        return res.status(403).json({ message: "Forbidden" });

    }catch(e){
        console.log("❌ http://localhost:3000/api/class/details");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get the class details" });
    }
}

export const getStudentClasses = async (req: AuthRequest, res: Response) => {
    const studyInRepository = AppDataSource.getRepository(StudyIn);
    const studentRepository = AppDataSource.getRepository(Student);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/class/get_student_classes");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role !== "student") {
            console.log("❌ http://localhost:3000/api/class/get_student_classes");
            return res.status(403).json({ message: "Forbidden" });
        }

        const student = await studentRepository.findOne({
            where: { user: { id: userId } },
        });

        if (!student) {
            console.log("❌ http://localhost:3000/api/class/get_student_classes");
            return res.status(404).json({ message: "Student not found" });
        }

        const studyInRecords = await studyInRepository.find({
            where: { student: { id: student.id } },
            relations: ["class", "class.teacher"],
        });

        const classes = studyInRecords.map((record) => ({
            id: record.class.id,
            name: record.class.name,
            description: record.class.description,
            location: record.class.location,
            startTime: record.class.startTime,
            endTime: record.class.endTime,
            days: record.class.days,
            teacher: {
                id: record.class.teacher.id,
                name: record.class.teacher.name,
                phone: record.class.teacher.phone
            },
        }));

        console.log("✅ http://localhost:3000/api/class/get_student_classes");
        return res.status(200).json({
            classes,
        });
    } catch (e) {
        console.log("❌ http://localhost:3000/api/class/get_student_classes");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get student classes" });
    }
};