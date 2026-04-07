import {Response} from 'express';
import { AppDataSource } from '../data-source';
import { User } from '../model/User';
import { Student } from '../model/Student';
import { Class } from '../model/Class';
import { StudyIn } from '../model/Study_in';
import { AuthRequest } from '../middleware/middleware';


export const addStudentToClass = async (req:AuthRequest, res: Response) => {

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const studyInRepository = queryRunner.manager.getRepository(StudyIn);
    const classRepository = queryRunner.manager.getRepository(Class);
    const studentRepository = queryRunner.manager.getRepository(Student);

    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.id);
        console.log(classId);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if(role != "teacher"){
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(403).json({message:"Forbidden"})
        }

        if (isNaN(classId)){
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(400).json({message:"Invalid class id"});
        }

        const teacherClass = await classRepository.findOne({
            where: {id:classId},
            relations: ['teacher']
        });

        if(!teacherClass){
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(404).json({message:"class was not found"});
        }

        if (teacherClass.teacher.id != userId){
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(403).json({message:"You do not have permission to add students to this class."});
        }

        const { phone } = req.body

        if (!phone){
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(400).json({message:"Missing Required Fields"})
        }

        const user = await AppDataSource.getRepository(User).findOneBy({phone});

        if (!user){
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(404).json({message:'User not found'});
        }

        if (user.role != 'student'){
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(400).json({message:'The provided phone does not belong to student'});
        }

        const student = await studentRepository.findOne({
            where: { user: { id: user.id } },
            relations: ["user"],
        });

        if (!student){
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(404).json({message:'Student does not exist'});
        }

        const studyIn = await studyInRepository.findOne({
            where: {
                class: {id: classId},
                student: {id: student.id}
            }
        });

        if (studyIn){
            console.log("❌ http://localhost:3000/api/student_class/add");
            return res.status(409).json({message:'Student already in the class'});
        }

        const newStudyIn  = studyInRepository.create({
            class: teacherClass,
            student
        });

        await queryRunner.manager.save(newStudyIn);

        const allStudyIn = await studyInRepository.find({
            where: {
                class: {id: classId},
            },
            relations: ['student', 'student.user']
        });

        await queryRunner.commitTransaction();

        const users = allStudyIn.map(({ student }) => {
            const { password, ...userWithoutPassword } = student.user;
            return userWithoutPassword;
        });

        console.log("✅ http://localhost:3000/api/student_class/add");
        return res.status(201).json({
            students: users
        });

    }catch(e){
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/student_class/add");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to add student to the class" });
    }finally{
        await queryRunner.release();
    }
}

export const removeStudentFromClass = async (req:AuthRequest, res:Response) => {

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const studyInRepository = queryRunner.manager.getRepository(StudyIn);
    const classRepository = queryRunner.manager.getRepository(Class);
    const userRepository = queryRunner.manager.getRepository(User);

    try{
        const userId = req.user?.id;
        const classId = Number(req.params.id);
        const role = req.user?.role;

        if (role !== "teacher") {
            console.log("❌ http://localhost:3000/api/student_class/get");
            return res.status(403).json({ message: "Forbidden" });
        }

        if (!userId) {
            console.log("❌ http://localhost:3000/api/student_class/remove");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (isNaN(classId)){
            console.log("❌ http://localhost:3000/api/student_class/remove");
            return res.status(400).json({message:"Invalid class id"});
        }

        const teacherClass = await classRepository.findOne({
            where: {id:classId},
            relations: ['teacher']
        });

        if(!teacherClass){
            console.log("❌ http://localhost:3000/api/student_class/remove");
            return res.status(404).json({message:"class was not found"});
        }

        if (teacherClass.teacher.id != userId){
            console.log("❌ http://localhost:3000/api/student_class/remove");
            return res.status(403).json({message:"You do not have permission to remove students from this class."});
        }

        const { phone } = req.body

        if (!phone){
            console.log("❌ http://localhost:3000/api/student_class/remove");
            return res.status(400).json({message:"Missing Required Fields"})
        }

        const student = await userRepository.findOne({
            where: {phone},
            relations: ["student"]
        })

        if (!student){
            console.log("❌ http://localhost:3000/api/student_class/remove");
            return res.status(404).json({
                message:"The student you are trying to remove does not exist"
            })
        }

        const enrollment = await studyInRepository.findOne({
            where: {
                student: { id: student.student.id },
                class: { id: classId }
            }
        });

        if (!enrollment) {
            console.log("❌ Student not found in this class");
            return res.status(404).json({ 
                message: "The student you are trying to remove is not enrolled in this class." 
            });
        }

        const subQuery = queryRunner.manager
            .createQueryBuilder()
            .subQuery()
            .select("a.id")
            .from("assignment", "a")
            .where("a.classId = :classId")
            .getQuery();

        // 2. use it in delete
        await queryRunner.manager
            .createQueryBuilder()
            .delete()
            .from("have_assignment")
            .where("studentId = :studentId", { studentId: student.student.id })
            .andWhere(`assignmentId IN ${subQuery}`)
            .setParameter("classId", classId)
            .execute();

        await studyInRepository.delete(enrollment.id);
        await queryRunner.commitTransaction();

        console.log("✅ http://localhost:3000/api/student_class/remove");
        return res.status(204).send();

    }catch(e){
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/student_class/remove");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to add remove student from the class" });
    }finally{
        await queryRunner.release();
    }
}

export const getClassStudents = async (req:AuthRequest, res: Response) => {

    const studyInRepository = AppDataSource.getRepository(StudyIn);
    const classRepository = AppDataSource.getRepository(Class);
    try{
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/student_class/get");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role !== "teacher") {
            console.log("❌ http://localhost:3000/api/student_class/get");
            return res.status(403).json({ message: "Forbidden" });
        }

        if (isNaN(classId)){
            console.log("❌ http://localhost:3000/api/student_class/get");
            return res.status(400).json({message:"Invalid class id"});
        }

        const existingClass = await classRepository.findOne({
            where: {id:classId},
            relations: ['teacher']
        });

        if (!existingClass){
            console.log("❌ http://localhost:3000/api/student_class/get");
            return res.status(404).json({message:"Getting students of non-existing class"});
        }

        if (existingClass.teacher.id != userId){
            console.log("❌ http://localhost:3000/api/student_class/get");
            return res.status(403).json({message:"Not allowed to access these informations"});
        }

        const studyInStudents = await studyInRepository.find({
            where: {class: {id: classId}},
            relations: ["student", "student.user"]
        });
        
        
        const students = studyInStudents.map((studyIn) => {
            return {"memorizedJuz":studyIn.student.memorized_juz, "registeredAt":studyIn.registeredAt,...studyIn.student.user};
        });

        console.log("✅ http://localhost:3000/api/student_class/get");
        return res.status(200).send({
            students
        });

    }catch(e){
        console.log("❌ http://localhost:3000/api/student_class/get");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get students of class" });
    }
}